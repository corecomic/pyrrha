/****************************************************************************
**
** Copyright (c) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Yoann Lopes (yoann.lopes@nokia.com)
**
** This file is part of the MeeSpot project.
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions
** are met:
**
** Redistributions of source code must retain the above copyright notice,
** this list of conditions and the following disclaimer.
**
** Redistributions in binary form must reproduce the above copyright
** notice, this list of conditions and the following disclaimer in the
** documentation and/or other materials provided with the distribution.
**
** Neither the name of Nokia Corporation and its Subsidiary(-ies) nor the names of its
** contributors may be used to endorse or promote products derived from
** this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
** FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
** TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
** PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
** LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
** NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: fullControlsPage
    showNavigationIndicator: false
    backNavigation: false
    allowedOrientations: Orientation.All

    Component.onCompleted: {
        flipable.width=Math.min(width, height)
        flipable.height=flipable.width
    }

    Flipable {
        id: flipable
        anchors.left: parent.left
        anchors.top: parent.top

        property bool flipped: false

        transform: Rotation {
            id: rotation
            origin.x: flipable.width/2
            origin.y: flipable.height/2
            axis.x: 0; axis.y: 1; axis.z: 0
            angle: 0
        }

        states: State {
            name: "back"
            PropertyChanges { target: rotation; angle: 180 }
            when: flipable.flipped
        }

        transitions: Transition {
            NumberAnimation { target: rotation; property: "angle"; duration: 350 }
        }

        front: Item {
            anchors.fill: parent
            z: flipable.flipped ? -1 : 1

            SilicaListView {
                id: coverList
                anchors.fill: parent
                boundsBehavior: Flickable.StopAtBounds
                orientation: ListView.Horizontal
                snapMode: ListView.SnapOneItem
                highlightRangeMode: ListView.StrictlyEnforceRange
                cacheBuffer: width * 2
                highlightMoveDuration: 0
                clip: true
                pressDelay: 90

                highlightFollowsCurrentItem: true

                currentIndex: -1
                onMovingChanged: {
                    if (horizontalVelocity == 0){
                        // do nothing
                    } else if (horizontalVelocity < 0){
                        // do not allow going back
                        cancelFlick()
                        coverList.currentIndex = player.songIndex
                    } else {
                        if (!moving)
                            player.selectSong(currentIndex)
                    }
                }

                Connections {
                    target: player
                    onSongChanged: {
                        coverList.currentIndex = player.songIndex
                    }
                }

                model: player.songList
                delegate: Item {
                    width: coverList.width
                    height: coverList.height
                    Image {
                        width: Math.min(coverList.width, coverList.height)
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: player.song ? player.song.artURL + (imageMouseArea.pressed ? "?" + Theme.highlightColor : "")
                                            : ""
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                        smooth: true

                        MouseArea {
                            id: imageMouseArea
                            anchors.fill: parent
                            onClicked: flipable.flipped = true
                        }
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: detailsColumn.height + Theme.paddingLarge
                color: Qt.darker(Theme.secondaryHighlightColor, 2)
                opacity: fullControlsPage.isPortrait ? 0.9 : 0

                Column {
                    id: detailsColumn
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingLarge
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.paddingSmall


                    Label {
                        width: parent.width
                        truncationMode: TruncationMode.Fade
                        opacity: details.opacity
                        text: player.song ? player.song.name : ""
                    }

                    Item {
                        id: details
                        width: parent.width
                        height: column.height
                        opacity: moreMouseArea.pressed ? Theme.highlightBackgroundOpacity : 1.0

                        Column {
                            id: column
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: moreIcon.left
                            anchors.rightMargin: Theme.paddingLarge
                            Label {
                                width: parent.width
                                font.pixelSize: Theme.fontSizeSmall
                                truncationMode: TruncationMode.Fade
                                anchors.left: parent.left
                                anchors.right: parent.right
                                text: player.song ? player.song.artist : ""
                            }
                            Label {
                                width: parent.width
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.secondaryColor
                                truncationMode: TruncationMode.Fade
                                anchors.left: parent.left
                                anchors.right: parent.right
                                text: player.song ? player.song.album : ""
                            }
                        }

                        Image {
                            id: moreIcon
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            source: "image://theme/icon-m-about"
                        }
                    }
                }

                MouseArea {
                    // TODO
                    id: moreMouseArea
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally(player.song.songDetailURL)
                    }
                    enabled: moreIcon.visible
                }
            }
        }

        back: Item {
            anchors.fill: parent
            clip: true
            z: flipable.flipped ? 1 : -1

            PageHeader {
                id: queueHeader
                title: qsTr("Play queue")

                MouseArea {
                    id: queueHeaderMouse
                    anchors.fill: parent
                    onClicked: flipable.flipped = false
                }
            }

            SilicaListView {
                id: queueList
                anchors.top: queueHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                cacheBuffer: 80
                clip: true

                currentIndex: -1

                VerticalScrollDecorator {}

                model: player.songList

                delegate: SongDelegate {
                    songName: name
                    artistAndAlbum: artist + " | " + album
                    coverURL: artURL
                    duration: duration
                    isFinished: finished
                    onClicked: {
                        if(finished)
                            return

                        if(isPlaying && !player.isPlaying)
                            player.play()
                        else
                            player.selectSong(index)

                        if(isPlaying)
                            flipable.flipped = false
                    }

                }

                Connections {
                    target: player
                    onSongIndexChanged: queueList.positionViewAtIndex(player.songIndex , ListView.Center)
                }
            }
        }
    }

    PanelBackground {

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        height: fullControlsPage.isPortrait ? parent.height - flipable.height : parent.height
        width: fullControlsPage.isPortrait ? parent.width : parent.width - flipable.width

        Column {
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingLarge
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            anchors.verticalCenter: parent.verticalCenter
            anchors.topMargin: Theme.paddingLarge
            width: parent.width
            spacing: Theme.paddingSmall
            anchors.top: parent.top
            opacity: fullControlsPage.isPortrait ? 0 : 1

            Label {
                width: parent.width
                truncationMode: TruncationMode.Fade
                text: player.song ? player.song.name : ""
            }
            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                text: player.song ? player.song.artist : ""
            }
            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                truncationMode: TruncationMode.Fade
                text: player.song ? player.song.album : ""
            }
        }


        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: Theme.paddingLarge
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            spacing: Theme.paddingLarge

            Row {
                id: controls
                width: parent.width
                property real itemWidth: width / 4
                IconButton {
                    width: controls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-like?" + (player.song && player.song.rating === 'love'
                                                                 ? Theme.highlightColor
                                                                 : Theme.primaryColor)
                    onClicked: {
                        //pressEffect.play()  //FEEDBACK
                        player.loveSong()
                    }
                }
                IconButton {
                    width: controls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-like"
                    icon.rotation: 180
                    onClicked: {
                        //pressEffect.play()  //FEEDBACK
                        player.banSong()
                    }
                }
                IconButton {
                    width: controls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: player.isPlaying ? "image://theme/icon-l-pause"
                                                  : "image://theme/icon-l-play"
                    onClicked: player.togglePause()
                }
                IconButton {
                    width: controls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-next"
                    onClicked: player.playNext()
                }
            }

            Slider {
                id: slider
                width: parent.width

                enabled: false

                handleVisible: false
                valueText: Format.formatDuration(value/1000, Formatter.DurationShort)

                minimumValue: 0
                maximumValue: player.duration
                value: player.position
            }


            Row {
                id: moreControls
                width: parent.width
                property real itemWidth : width / 5

                IconButton {
                    width: moreControls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-add"
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("AddStation.qml"), { query: player.song.artist + ' ' + player.song.name })
                    }
                }

                IconButton {
                    width: moreControls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: ""
                    onClicked: {
                        // Move to another Station
                    }
                }

                IconButton {
                    width: moreControls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-remove?" + (player.song && player.song.tired
                                                                   ? Theme.highlightColor
                                                                   : Theme.primaryColor)
                    onClicked: player.setTired()
                }

                IconButton {
                    width: moreControls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: ""
                    onClicked: {
                        // Bookmark this song
                    }
                }

                IconButton {
                    width: moreControls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-down"
                    onClicked: {
                        appWindow.showFullControls = !appWindow.showFullControls
                    }
                }
            }
        }
    }
}
