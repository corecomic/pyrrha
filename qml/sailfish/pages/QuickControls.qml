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

DockedPanel {
    id: quickControls

    width: parent.width
    height: 150

    contentHeight: height
    flickableDirection: Flickable.VerticalFlick

    opacity: Qt.inputMethod.visible ? 0.0 : 1.0
    Behavior on opacity { FadeAnimation {}}

    onOpenChanged: {
        if(!open && player.isPlaying && !appWindow.showFullControls)
            player.pause()
    }


    Item {
        anchors.fill: parent

        MouseArea {
            id: opener
            anchors.fill: parent
            //onClicked: if (!fullControls.open) { fullControls.open = true }
        }

        Row {
            id: quickControlsItem
            width: parent.width
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            height: parent.height
            spacing: Theme.paddingLarge

            Image {
                id: cover
                width: quickControls.height
                height: width
                source: player.song ? player.song.artURL : "image://theme/icon-l-music"
            }

            Column {
                id: trackInfo
                width: parent.width - cover.width - Theme.paddingLarge
                height: parent.height
                spacing: -Theme.paddingSmall

                Label {
                    id: trackLabel
                    width: parent.width
                    truncationMode: TruncationMode.Fade
                    text: player.song ? player.song.name : ""
                }
                Label {
                    width: parent.width
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                    color: Theme.secondaryColor
                    text: player.song ? player.song.artist : ""
                }

                Row {
                    id: controls
                    width: parent.width
                    property real itemWidth: width / 4

                    IconButton {
                        width: controls.itemWidth
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: "image://theme/icon-m-up"
                        onClicked: player.loveSong()
                    }

                    IconButton {
                        width: controls.itemWidth
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: "image://theme/icon-m-down"
                        onClicked: player.banSong()
                    }

                    IconButton {
                        width: controls.itemWidth
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: player.isPlaying ? "image://theme/icon-m-pause"
                                                              : "image://theme/icon-m-play"
                        onClicked: player.togglePause()
                    }

                    IconButton {
                        width: controls.itemWidth
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: "image://theme/icon-m-next-song"
                        onClicked: player.playNext()
                    }
                }
            }
        }
    }
}
