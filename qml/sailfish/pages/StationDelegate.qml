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


ListItem {
    id: listItem
    menu: contextMenu

    readonly property bool isCurrentlyPlaying: player.currentStation >= 0 && player.currentStation === index

    Label {
        text: name

        anchors {
            left: parent.left
            right: parent.right
            margins: Theme.paddingLarge
            verticalCenter: parent.verticalCenter
        }

        color: highlighted || isCurrentlyPlaying ? Theme.highlightColor : Theme.primaryColor
    }

    Component {
        id: contextMenu

        ContextMenu {
            MenuItem {
                text: qsTr("Edit")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("EditStation.qml"),
                                                {old_name: stationListModel.get(index).name})
                }
            }

            MenuItem {
                text: qsTr("Remove")
                onClicked: listItem.remove()
            }
        }
    }

    onClicked: {
        player.currentStation = index;
        stationListModel.stationChanged(stationListModel.get(index).name)
    }

    function remove() {
        if(isCurrentlyPlaying){
            player.stop()
        }

        remorseAction(qsTr("Deleting"), function() {
            stationListModel.deleteStation(stationListModel.get(index).name)
        });
    }
}
