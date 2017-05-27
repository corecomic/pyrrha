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
import QtFeedback 5.0
import org.nemomobile.notifications 1.0
import Sailfish.Media 1.0
import org.nemomobile.policy 1.0

import "sailfish/pages"

ApplicationWindow
{
    id: appWindow
    bottomMargin: quickControls.visibleSize

    initialPage: Component { Main { id: mainPage } }
    cover: Qt.resolvedUrl("sailfish/cover/CoverPage.qml")

    property bool grabKeys: keysResource.acquired

    property bool showFullControls: false
    onShowFullControlsChanged: {
        if(showFullControls) {
            quickControls.open = false
            pageStack.push(fullControls, undefined, PageStackAction.Immediate)
        } else {
            pageStack.pop()
            if(player.song && !quickControls.open)
                quickControls.open = true
        }
    }

    Python { id: py }

    QuickControls {
        id: quickControls
    }

    FullControls {
        id: fullControls
    }

    MediaPlayback {
        id: player
    }

    MprisControls {
        id: mprisPlayer
    }

    Session {
        id: pandoraSession
    }

    ThemeEffect {
        id: pressEffect
        effect: "Press"
    }

    Notification {
        id: notification
        appName: "Pyrrha"
        summary: ""
        previewSummary: summary
        expireTimeout: 2
    }

    Permissions {
        enabled: true
        applicationClass: "player"

        Resource {
            id: keysResource
            type: Resource.HeadsetButtons
            optional: true
        }
    }

    MediaKey {
        enabled: grabKeys
        key: Qt.Key_MediaTogglePlayPause
        onReleased: player.togglePause()
    }

    MediaKey {
        enabled: grabKeys
        key: Qt.Key_MediaPlay
        onReleased: player.togglePause()
    }

    MediaKey {
        enabled: grabKeys
        key: Qt.Key_MediaPause
        onReleased: player.togglePause()
    }

    MediaKey {
        enabled: grabKeys
        key: Qt.Key_MediaStop
        onReleased: player.stop()
    }

    MediaKey {
        enabled: grabKeys
        key: Qt.Key_MediaNext
        onReleased: player.playNext()
    }

    MediaKey {
        enabled: grabKeys
        key: Qt.Key_ToggleCallHangup
        onReleased: player.togglePause()
    }

}


