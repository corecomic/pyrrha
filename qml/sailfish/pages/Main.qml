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
    id: mainPage

    property bool loading: true

    Component.onCompleted: {
        pandoraSession.connect()
        loadStationList()
    }

    function createPlayerPage() {
        console.log("Player Created..!")
        if (player.songID != 0) {
        }
    }

    function loadStationList    () {
        stationListModel.clear();
        py.call('pyrrha.get_station_list', [], function(result) {
            // Load the received data into the list model
            for (var i=0; i<result.length; i++) {
                stationListModel.append(result[i]);
            }
            loading = false;
        });
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaListView {
        id: listView
        anchors.fill: parent

        VerticalScrollDecorator { flickable: listView }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    loading = true
                    if (!pandoraSession.isConnected)
                        pandoraSession.connect()
                    loadStationList()
                }
            }
        }

        header: PageHeader {
            title: qsTr("Pyrrha")
        }

        model: ListModel {
            id: stationListModel
        }

        delegate: ListItem {
            id: listItem
            height: Theme.itemSizeSmall

            Label {
                text: name
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            onClicked: {
                py.call('pyrrha.station_changed', [stationListModel.get(index).name], function(result) {
                    if (result) {
                        player.songIndex = 0
                        player.getSongList(true)
                    }
                });
                if (!quickControls.open)
                    quickControls.open = true
            }
        }

        section.property: 'section'
        section.delegate: ListItem {
            height: Theme.paddingMedium
        }
//        Separator {
//            width: parent.width
//            anchors.horizontalCenter: parent.horizontalCenter
//        }

        ViewPlaceholder {
            id: pagePlaceholder

            enabled: stationListModel.count == 0 && py.ready
            text: qsTr('No stations')
            hintText: {
                if (pandoraSession.settings && pandoraSession.settings['account']['email'] === '')
                    return pagePlaceholder.hintText = qsTr("No account configured!")
                else
                    return pandoraSession.connectionError
            }
            _hintLabel.font.pixelSize: Theme.fontSizeExtraSmall
        }

        BusyIndicator {
            size: BusyIndicatorSize.Medium
            anchors.centerIn: parent
            visible: !py.ready || loading
            running: visible
        }
    }
}


