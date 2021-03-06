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
    id: dialog

    property string old_name: ''
    property string new_name

    Column {
        width: parent.width

        DialogHeader { }

        TextField {
            id: nameField
            width: parent.width
            placeholderText: qsTr("Station name")
            label: qsTr("Name")
            text: old_name
        }
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            py.call('pyrrha.rename_station', [dialog.old_name, nameField.text], function(result) {});
        }
    }
}
