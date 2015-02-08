# -*- coding: utf-8 -*-
### BEGIN LICENSE
#Copyright (C) 2015 Core Comic <core.comic@gmail.com>

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
### END LICENSE


"""
Python wrapper file for pithos-mobile, using PyOtherSide

"""

__version__ = "0.1.0"


import sys
import os
import logging
import urllib.request, urllib.error, urllib.parse

try:
    import configparser
except Exception as exp:
    pass

try:
    import pyotherside
except ImportError:
    # Allow testing Python backend alone.
    # print("PyOtherSide not found, continuing anyway!")
    pass


from pandora import *
from pandora.data import *


# FOR TESTING
logging.basicConfig(level=logging.INFO)


class PithosMobile(object):
    def __init__(self):
        # Initialize Config File for Settings
        self.config = configparser.ConfigParser()

        config_folder = os.path.join(os.environ.get('HOME'), ".config/harbour-pyrrha/")
        self.config_file = os.path.join(config_folder, "config.ini")

        # Create config folder
        if not os.path.exists(config_folder):
            os.makedirs(config_folder)
        if not os.path.isdir(config_folder):
            raise Exception("'%s' must be a folder" % config_folder)

        # Initialize Variables
        self.playing = False
        self.current_station = None
        self.current_song = None
        self.current_song_index = None

        self.waiting_for_playlist = False

        self.stations_model = []
        self.songs_model = []

        # Initialize Pandora
        self.pandora = make_pandora()

        if not self.read_configuration() or 'account' not in self.config.sections():
            config = self.get_configuration()
            self.save_configuration(config)

        self.set_proxy()
        self.set_audio_quality()


    def init(self):
        pyotherside.send('hello', __version__)
        pyotherside.send('config-changed')
        logging.info("PithosMobile initialized...")

    def read_configuration(self):
        """ Read configuration file """
        try:
            self.config.read(self.config_file)
        except Exception as exp:
            print(exp)
            return False
        return True

    def get_configuration(self):
        """ Get all configurations """
        default_config = {
          'account': {'email': '', 'password': '', 'pandora_one': 'False'},
          'audio': {'quality': 'lowQuality'},
          'proxy': {'global_url': '', 'control_url': ''}
        }
        if not self.read_configuration():
            return default_config
        if 'account' not in self.config.sections():
            return default_config

        # NOTE: might use a better way, as this is not documented.
        return self.config._sections

    def save_configuration(self, configuration):
        """ Save all configurations """
        if not self.read_configuration():
            return
        self.config.read_dict(configuration)
        with open(self.config_file,'w') as config_f:
            self.config.write(config_f)

    def get_proxy(self):
        """ Get HTTP proxy, first trying preferences then system proxy """

        if 'proxy' in self.config.sections():
            return self.config['proxy'].get('global_url', None)

        system_proxies = urllib.request.getproxies()
        if 'http' in system_proxies:
            return system_proxies['http']

        return None

    def set_proxy(self):
        # proxy preference is used for all Pithos HTTP traffic
        # control proxy preference is used only for Pandora traffic and
        # overrides proxy
        #
        # If neither option is set, urllib2.build_opener uses urllib.getproxies()
        # by default

        handlers = []
        global_proxy = self.config['proxy'].get('global_url', '')
        if global_proxy:
            handlers.append(urllib.request.ProxyHandler({'http': global_proxy, 'https': global_proxy}))
        global_opener = urllib.request.build_opener(*handlers)
        urllib.request.install_opener(global_opener)

        control_opener = global_opener
        control_proxy = self.config['proxy'].get('control_url', '')
        if control_proxy:
            control_opener = urllib.request.build_opener(urllib.request.ProxyHandler({'http': control_proxy, 'https': control_proxy}))

        self.pandora.set_url_opener(control_opener)

    def set_audio_quality(self):
        self.pandora.set_audio_quality(self.config['audio'].get('quality', 'mediumQuality'))

    def error_callback(self, e):
        if isinstance(e, PandoraAuthTokenInvalid): # and not self.auto_retrying_auth:
            logging.info("Automatic reconnect after invalid auth token")
            self.pandora_connect()
        elif isinstance(e, PandoraAPIVersionError):
            logging.error("From time to time, Pandora makes an API change that breaks Pyrrha.\
                As an unofficial client, Pyrrha has no prior notice about these changes.")
            pyotherside.send('connection-error', "Incompatible Pandora API version")
        elif isinstance(e, PandoraError):
            logging.error(e.message)
            logging.error(e.submsg)
            pyotherside.send('connection-error', str(e.submsg))
        else:
            logging.warn(e.traceback)
            pyotherside.send('connection-error', str(e))

    def pandora_connect(self, callback=None):
        if self.config['account'].get('pandora_one') == 'True':
            client = client_keys[default_one_client_id]
        else:
            client = client_keys[default_client_id]

        user = self.config['account'].get('email', '')
        password = self.config['account'].get('password', '')

        try:
            self.pandora.connect(client, user, password)
            pyotherside.send('connected')
            self.process_stations()
        except Exception as e:
            self.error_callback(e)

    def process_stations(self):
        for i in self.pandora.stations:
            if i.isQuickMix and i.isCreator:
                self.stations_model.append((i, "QuickMix"))
        self.stations_model.append((None, 'sep'))
        for i in self.pandora.stations:
            if not (i.isQuickMix and i.isCreator):
                self.stations_model.append((i, i.name))

    def get_station_list(self):
        stations_list = []
        for item in self.stations_model:
            if item[1] == 'QuickMix':
                stations_list.append({'name': item[1], 'section': 'mix'})
            elif item[1] == 'sep':
                pass
            else:
                stations_list.append({'name': item[1], 'section': 'station'})

        return stations_list

    def station_changed(self, station_name, reconnecting=False):
        for item in self.stations_model:
            if item[1] == station_name:
                station = item[0]
                break

        if station is self.current_station:
            logging.info('In station_changed: same station...')
            return False

        self.waiting_for_playlist = False
        if not reconnecting:
            #self.stop()
            self.current_song_index = None
            self.songs_model = []
        logging.info("Selecting station %s; total = %i" % (station.id, len(self.stations_model)))
        self.current_station = station
        #if not reconnecting:
        #    self.get_playlist(start = True)
        return True

    def get_playlist(self):
        if self.waiting_for_playlist: return

        self.waiting_for_playlist = True
        try:
            songs = self.current_station.get_playlist()

            for i in songs:
                i.index = len(self.songs_model)
                self.songs_model.append((i, '', '', ''))

            self.waiting_for_playlist = False

        except Exception as e:
            logging.error(e)

    def get_song_list(self):
        song_list = []
        for song in self.songs_model:
                song_list.append({'name': song[0].songName,
                                  'album': song[0].album,
                                  'artist': song[0].artist,
                                  'audioURL': song[0].audioUrl,
                                  'artURL': song[0].artRadio})


        return song_list



pyrrha = PithosMobile()

#pyotherside.atexit(gpotherside.atexit)
#pyotherside.send('hello', gpodder.__version__, __version__, podcastparser.__version__)

# Exposed API Endpoints for calls from QML
init = pyrrha.init
get_configuration = pyrrha.get_configuration
save_configuration = pyrrha.save_configuration
pandora_connect = pyrrha.pandora_connect
get_station_list = pyrrha.get_station_list
get_song_list = pyrrha.get_song_list
get_playlist = pyrrha.get_playlist
station_changed = pyrrha.station_changed


## TESTING ##
if __name__ == "__main__":
    print('Hi World')
    pyrrha.init()
    pyrrha.pandora_connect()
    pyrrha.station_changed('QuickMix')
    songs = pyrrha.get_song_list()
    print(songs)


