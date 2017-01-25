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
import org.nemomobile.mpris 1.0

MprisPlayer {
    id: mprisPlayer

    property string artist
    property string song

    function updateMprisMetadata(){
        mprisPlayer.song = player.song ? player.song.name : ""
        mprisPlayer.artist = player.song ? player.song.artist : ""
        updatePlaybackStatus()
    }

    function updatePlaybackStatus(){
        switch (player.playbackState) {
        case MediaPlayer.PlayingState:
            mprisPlayer.playbackStatus = Mpris.Playing
            break;
        case MediaPlayer.PausedState:
            mprisPlayer.playbackStatus = Mpris.Paused
            break;
        case MediaPlayer.StoppedState:
            mprisPlayer.playbackStatus = Mpris.Paused
            break;
        default:
            mprisPlayer.playbackStatus = Mpris.Paused
        }
    }

    serviceName: "harbour-pyrrha"

    // Mpris2 Root Interface
    identity: "Pyrrha"
    supportedUriSchemes: ["file"]
    supportedMimeTypes: ["audio/x-wav", "audio/x-vorbis+ogg", "audio/mpeg", "audio/mp4a-latm", "audio/x-aiff"]

    // Mpris2 Player Interface
    canControl: true

    canGoNext: true
    canGoPrevious: false
    canPause: true
    canPlay: true
    canSeek: false

    playbackStatus: Mpris.Paused
    loopStatus: Mpris.None
    shuffle: false
    volume: 1

    onPauseRequested: {
        console.log('MRIS: pause requested')
        player.togglePause()
    }

    onPlayRequested: {
        console.log('MRIS: play requested')
        if(!player.song){
            player.currentStation = 0;
            py.call('pyrrha.station_changed', ["QuickMix"], function(result) {
                if (result) {
                    player.songIndex = 0
                    player.songList.loadSongs(true)
                }
            });
        } else {
            player.togglePause()
        }
    }

    onPlayPauseRequested: {
        console.log('MRIS: play/pause requested')
        player.togglePause()
    }

    onStopRequested: {
        console.log('MRIS: stop requested')
        player.stop()
    }

    onNextRequested: {
        console.log('MRIS: next requested')
        player.playNext()
    }

    onArtistChanged: {
        var metadata = mprisPlayer.metadata

        metadata[Mpris.metadataToString(Mpris.Artist)] = [artist]

        mprisPlayer.metadata = metadata
    }

    onSongChanged: {
        var metadata = mprisPlayer.metadata

        metadata[Mpris.metadataToString(Mpris.Title)] = song

        mprisPlayer.metadata = metadata
    }
}
