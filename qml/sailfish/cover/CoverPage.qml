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
import Sailfish.Silica 1.0

CoverBackground {
    Image {
        source: player.song ? player.song.artURL : 'pyrrha_cover.png'
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: parent.height
        fillMode: Image.PreserveAspectCrop
        clip: true
        opacity: 0.5
    }

    Label {
        id: timeLabel
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            margins: Theme.paddingSmall
        }
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeHuge
        text: player.song ? formatDuration(player.position/1000) : ""
    }
    Label {
        id: trackLabel
        anchors {
            top: timeLabel.bottom
            left: parent.left
            right: parent.right
            margins: Theme.paddingMedium
        }
        maximumLineCount: 3
        wrapMode: Text.Wrap
        truncationMode: TruncationMode.Elide
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeLarge
        text: player.song ? player.song.name : ""
    }

    CoverActionList {
        id: coverActionPlaying
        enabled: pandoraSession.isConnected && player.song

        CoverAction {
            iconSource: player.isPlaying ? "image://theme/icon-cover-pause"
                                         : "image://theme/icon-cover-play"
            onTriggered: player.togglePause()
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-next-song"
            onTriggered: player.playNext()
        }
    }
    CoverActionList {
        id: coverActionIdle
        enabled: pandoraSession.isConnected && !player.song

        CoverAction {
            iconSource: "image://theme/icon-cover-shuffle"
            onTriggered: {
                py.call('pyrrha.station_changed', ["QuickMix"])
                player.getSongList(true)
            }
        }
    }

    function formatDuration(duration) {
        if (duration !== 0 && !duration) {
            return ''
        }

        var h = parseInt(duration / 3600) % 24
        var m = parseInt(duration / 60) % 60
        var s = parseInt(duration % 60)

        var hh = h > 0 ? (h < 10 ? '0' + h : h) + ':' : ''
        var ms = (m < 10 ? '0' + m : m) + ':' + (s < 10 ? '0' + s : s)

        return ms
    }
}


