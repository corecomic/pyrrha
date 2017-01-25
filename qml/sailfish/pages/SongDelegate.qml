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


BackgroundItem {
    id: listItem

    property variant listModel
    property string songName: model.name
    property string artistAndAlbum: model.artist + " | " + model.album
    property string duration: Format.formatDuration(model.trackLength, Formatter.DurationShort)
    property string coverURL: ""
    property bool isFinished: false
    readonly property bool isPlaying: player.songIndex === index

    height: Theme.itemSizeSmall
    width: parent.width

    Rectangle {
        id: coverContainer
        width: Theme.iconSizeMedium; height: width
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.secondaryColor
        opacity: listItem.isFinished ? 0.2 : 1.0
        Image {
            id: coverImage
            anchors.fill: parent
            source: listItem.coverURL
        }
    }
    Column {
        anchors.left: coverContainer.right
        anchors.leftMargin: Theme.paddingLarge
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        opacity: listItem.isFinished ? 0.3 : 1.0

        Item {
            height: mainText.height
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            Label {
                id: mainText
                text: listItem.songName
                anchors.left: parent.left
                anchors.right: parent.right
                color: (highlighted || isPlaying) ? Theme.highlightColor : Theme.primaryColor
                truncationMode: TruncationMode.Fade
                clip: true
            }
        }
        Item {
            height: subText.height
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            Label {
                id: subText
                text: listItem.artistAndAlbum
                anchors.left: parent.left
                anchors.right: timing.left
                anchors.rightMargin: Theme.paddingLarge
                font.pixelSize: Theme.fontSizeSmall
                color: (highlighted || isPlaying) ? Theme.secondaryHighlightColor : Theme.secondaryColor
                truncationMode: TruncationMode.Fade
                clip: true
                visible: text != ""
            }
            Label {
                id: timing
                text: listItem.duration
                font.pixelSize: Theme.fontSizeSmall
                color: (highlighted || isPlaying) ? Theme.secondaryHighlightColor : Theme.secondaryColor
                anchors.right: parent.right
                visible: text != ""
            }
        }
    }
}
