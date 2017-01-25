/* -*- coding: utf-8-unix -*-
 *
 * Pyrrha, a cute pandora client.
 * Copyright (C) 2015 Core Comic <core.comic@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtMultimedia 5.4

Audio {
    id: player

    property int songID: 0
    property int songIndex: 0
    property int songsRemaining: 0
    property var song: undefined
    property SongModel songList: SongModel{}

    property int currentStation: -1
    readonly property int playlistValidityTime: 60*60

    signal songListUpdated()

    property bool isPlaying: playbackState == MediaPlayer.PlayingState

    //autoPlay: true

    function isValid() {
        console.log('Expired Time: ', (((new Date().getTime()) + (player.duration - player.position))/1000 - song.playlistTime))
        return (((new Date().getTime()) + (player.duration - player.position))/1000 - song.playlistTime) < playlistValidityTime
    }

    function togglePause() {
        if (playbackState === MediaPlayer.PlayingState) {
            pause();
        } else if (playbackState === MediaPlayer.PausedState) {
            // Check if song is expired
            if (!isValid()) {
                console.log('Playlist expired!');
                notification.summary = qsTr('This song has expired, skipping...');
                notification.publish();
                playNext();
            } else {
                play();
            }
        }
    }

    function playNext() {
        setFinished();
        songIndex = songIndex+1;
        if ((songIndex+1) <= songList.count){
            song = songList.get(songIndex);
            playbackSong(song.audioURL)
        }
    }

    function selectSong(index) {
        songIndex = index;
        song = songList.get(songIndex);
        playbackSong(song.audioURL)
    }

    function playbackSong(songUrl) {
        if (player.source === songUrl) {
            // If the song is already loaded, just start playing
            play();
            return;
        }

        // First, make sure we stop any playing song
        //player.stop();

        songsRemaining = songList.count - (songIndex)

        if (songsRemaining <= 0){
            //self.get_playlist()
            console.log('out of songs...')
            songList.loadSongs(true)
        } else if (songsRemaining == 1){
            //preload next playlist
            console.log('should load next list...')
            songList.loadSongs()
        }

        // Check if song is expired
        if (!isValid()) {
            console.log('Playlist expired!');
            notification.summary = qsTr('This song has expired, skipping...');
            notification.publish();
            playNext();
            return;
        }

        // Check if song is marked as beeing tired of
        if(song.tired){
            console.log('You are tired of this song...');
            notification.summary = qsTr('Skipping, you are tired of this song...');
            notification.publish();
            playNext();
            return;
        }

        console.log("Starting song: "+song.name)

        player.source = songUrl;

        player.play();
    }

    function loveSong(){
        py.call('pyrrha.love_song', [song.audioURL], function(result) {
            songList.readList();
        });
    }

    function banSong(){
        py.call('pyrrha.ban_song', [song.audioURL], function(result) {
            playNext();
        });
    }

    function setTired(){
        py.call('pyrrha.set_tired', [song.audioURL], function(result) {
            songList.readList();
            //playNext();
        });
    }

    function setFinished(){
        py.call('pyrrha.set_finished', [song.audioURL], function(result) {
            songList.readList();
        });
    }

    onPlaybackStateChanged: {
        mprisPlayer.updatePlaybackStatus(); //MPRIS
    }

    onSongListUpdated: {
        console.log('SongList Updated...');
        song = songList.get(songIndex);
        playbackSong(song.audioURL);
    }

    onStatusChanged: {
        //console.log('Status: ', status)
        if (status === MediaPlayer.EndOfMedia) {
            playNext()
        }
        mprisPlayer.updateMprisMetadata(); //MPRIS
    }

    onError: {
        console.log("Track unplayable");
        console.log(errorString);
        //playNext();
        //TODO: catch expired songs..: Forbidden
    }
}




