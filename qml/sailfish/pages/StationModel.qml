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


ListModel{
    id: stationModel

    function loadStations() {
        stationModel.clear();
        py.call('pyrrha.get_station_list', [], function(result) {
            // Load the received data into the list model
            for (var i=0; i<result.length; i++) {
                stationModel.append(result[i]);
            }
            pandoraSession.isLoading = false;
        });
    }

    function hasStations() {
        return stationModel.count > 0
    }

    function stationChanged(stationName) {
        py.call('pyrrha.station_changed', [stationName], function(result) {
            if (result) {
                player.songIndex = 0
                player.songList.loadSongs(true)
            }
        });
        if (!quickControls.open)
            quickControls.open = true
    }

    function deleteStation(stationName) {
        py.call('pyrrha.delete_station', [stationName], function(result) {});
    }

    function renameStation(stationName, newName) {
        console.log('Rename from ' + stationName + ' to ' + newName)
        py.call('pyrrha.rename_station', [stationName, newName], function(result) {});
    }
}
