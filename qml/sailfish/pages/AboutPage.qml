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
    id: aboutPage

    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        VerticalScrollDecorator { flickable: flickable }

        contentWidth: aboutColumn.width
        contentHeight: aboutColumn.height + aboutColumn.spacing

        Column {
            id: aboutColumn

            width: aboutPage.width
            spacing: Theme.paddingMedium


            PageHeader {
                title: qsTr('About Pyrrha')
            }

            Column {
                spacing: Theme.paddingLarge

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                Column {
                    Label {
                        text: 'Pyrrha '
                        color: Theme.highlightColor
                    }

                    Label {
                        text: 'https://github.com/corecomic/pyrrha'
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                    }
                }

                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: [
                        'Copyright © 2017 Core Comic',
                        'Licensed under GNU GPLv3+',
                        '',
                        'Pandora Python library by Kevin Mehall and Christopher Eby from Pithos (http://pithos.github.io)',
                        '',
                        'Pyrrha ' + py.version,
                        'PyOtherSide ' + py.pluginVersion(),
                        'Python ' + py.pythonVersion()
                    ].join('\n')
                }

                Label {
                    anchors.topMargin: Theme.paddingLarge
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    text: 'Pyrrha is not affiliated with or endorsed by Pandora Media, Inc.'
                }
            }
        }
    }
}
