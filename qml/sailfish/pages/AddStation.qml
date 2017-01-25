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

Page {
    id: searchPage

    property bool isSearching: false
    property alias query: searchField.text

    Component.onCompleted: {
        if(query != ''){
            searchPage.isSearching = true;
            search();
        } else {
            searchField.forceActiveFocus()
        }

    }

    function search() {
        parent.focus = true //Make sure the keyboard closes and the text is updated
        py.call('pyrrha.search_station', [searchField.text], function(result) {
            // Clear the data in the list model
            listModel.clear();
            // Load the received data into the list model
            for (var i=0; i<result.length; i++) {
                listModel.append(result[i]);
            }
            searchPage.isSearching = false;
        });
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}


        Column {
            id: column
            width: searchPage.width

            PageHeader {
                title: qsTr("Add station")
            }

            SearchField {
                id: searchField

                width: parent.width
                placeholderText: qsTr("Search")
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText

                EnterKey.onClicked: {
                    if (text != "")
                        searchField.focus = false;
                    searchPage.isSearching = true;
                    search();
                }
            }

            Repeater {
                width: parent.width

                model: ListModel {
                    id: listModel
                }

                delegate: BackgroundItem {
                    width: parent.width
                    contentHeight: Theme.itemSizeSmall


                    Image {
                        id: coverImage
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.horizontalPageMargin
                        width: Theme.iconSizeMedium; height: width
                        source: model.type === 'song' ? "image://theme/icon-m-music" : "image://theme/icon-m-people"
                        opacity: 0.5
                    }

                    Column {
                        anchors.left: coverImage.right
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Theme.paddingSmall
                        anchors.rightMargin: Theme.horizontalPageMargin

                        Label {
                            id: mainText
                            width: parent.width
                            text: model.artist
                            truncationMode: TruncationMode.Fade
                            clip: true
                        }

                        Label {
                            id: subText
                            width: parent.width
                            text: model.title
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.secondaryColor
                            truncationMode: TruncationMode.Fade
                            clip: true
                            visible: text != ""
                        }

                    }
                    onClicked: {
                        py.call('pyrrha.add_station', [model.musicId], function() {});
                        pageStack.pop();
                    }
                }
            }
        }

        BusyIndicator {
            size: BusyIndicatorSize.Medium
            anchors {
                top: parent.top
                topMargin: 10*Theme.paddingLarge
                horizontalCenter: parent.horizontalCenter
            }
            visible: isSearching
            running: visible
        }
    }
}
