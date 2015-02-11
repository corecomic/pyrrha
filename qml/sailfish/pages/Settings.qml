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

Dialog {
    id: settingsDialog

    canAccept: emailField.text !== '' && passwordField.text !== ''

    onAccepted: {
        py.call('pyrrha.save_configuration', [ {'account': {'email': emailField.text,
                                                      'password': passwordField.text,
                                                      'pandora_one': subscriberSwitch.checked},
                                                  'audio': {'quality': audioQuality.currentItem.text.toLowerCase() + 'Quality'},
                                                  'proxy': {'global_url': proxyURL.text,
                                                      'control_url': controlProxyURL.text}} ])
    }

    Component.onCompleted: {
        if (!pandoraSession.settings) {
            pandoraSession.readConfig();
        }
    }


    SilicaFlickable {
        anchors.fill: parent

        VerticalScrollDecorator { flickable: flickable }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height
        contentWidth: column.width

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: settingsDialog.width
            spacing: Theme.paddingLarge

            DialogHeader {
                title: qsTr("Settings")
                acceptText: qsTr("Save")
            }

            SectionHeader {
                text: qsTr("Account")
            }

            TextField {
                id: emailField
                width: parent.width
                placeholderText: qsTr("Enter e-mail address")
                inputMethodHints: Qt.ImhEmailCharactersOnly
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: passwordField.focus = true

                label: qsTr("E-mail")
                text: pandoraSession.settings['account']['email']
            }

            TextField {
                id: passwordField
                width: parent.width
                placeholderText: qsTr("Enter password")
                inputMethodHints: Qt.ImhNoPredictiveText
                echoMode: TextInput.Password
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false

                label: qsTr("Password")
                text: pandoraSession.settings['account']['password']
            }

            TextSwitch {
                id: subscriberSwitch
                checked: pandoraSession.settings['account']['pandora_one'] === 'True'
                text: qsTr("Pandora One Subscriber")
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeTiny
                onLinkActivated: Qt.openUrlExternally(link)
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.RichText
                text: "<style>a:link { color: " + Theme.highlightColor
                      + "; }</style><a href='http://pandora.com'>Create an account at pandora.com</a>"
            }

            SectionHeader {
                text: qsTr("Audio")
            }

            ComboBox {
                id: audioQuality
                label: qsTr("Audio Quality")
                menu: ContextMenu {
                    id: audioQualityMenu
                    MenuItem { text: "Low"; }
                    MenuItem { text: "Medium"; }
                    MenuItem { text: "High"; }
                }
                currentIndex: pandoraSession.settings['audio']['quality'] === 'lowQuality' ? 0
                                  : pandoraSession.settings['audio']['quality'] === 'mediumQuality' ? 1 : 2
            }

            SectionHeader {
                text: qsTr("Proxy")
            }

            TextField {
                id: proxyURL
                width: parent.width
                placeholderText: qsTr("Enter proxy URL")
                inputMethodHints: Qt.ImhUrlCharactersOnly
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: controlProxyURL.focus = true

                label: qsTr("Proxy URL")
                text: pandoraSession.settings['proxy']['global_url']
            }

            TextField {
                id: controlProxyURL
                width: parent.width
                placeholderText: qsTr("Enter control proxy URL")
                inputMethodHints: Qt.ImhUrlCharactersOnly
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false

                label: qsTr("Control Proxy URL")
                text: pandoraSession.settings['proxy']['control_url']
            }
        }
    }
}
