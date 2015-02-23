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
import QtMultimedia 5.0


Audio {
    id: player

    property int songID: 0
    property int songIndex: 0
    property int songsRemaining: 0
    property var song: undefined
    property SongModel songList: SongModel{}

    property int currentStation: -1

    signal songListUpdated()

    property bool isPlaying: playbackState == MediaPlayer.PlayingState


    autoPlay: true

    function togglePause() {
        if (playbackState === MediaPlayer.PlayingState) {
            pause();
        } else if (playbackState === MediaPlayer.PausedState) {
            play();
        }
    }

    function playNext() {
        songIndex = songIndex+1;
        song = songList.get(songIndex);
        playbackSong(song.audioURL)
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


        //if self.current_song.tired or self.current_song.rating == RATE_BAN:
        //    return self.next_song()

        console.log("Starting song: "+song.name)

        player.source = songUrl;

        player.play();
    }

    function loveSong(){

    }

    function banSong(){

    }

    onSongListUpdated: {
        console.log('SongList Updated...')
        playbackSong(songList.get(songIndex).audioURL)
    }


    onPlaybackStateChanged: {

    }

    onStatusChanged: {
        if (status === MediaPlayer.EndOfMedia) {
            playNext()
        }
    }

    onError: {
        console.log("Track unplayable");
        console.log(errorString);
        //playNext();
    }
}
