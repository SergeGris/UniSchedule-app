
// Copyright (C) 2024 Sergey Sushilin <sushilinsergey@yandex.ru>.
// This file is part of UniSchedule.

// UniSchedule is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.

// UniSchedule is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with UniSchedule.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './widgets/dropdownbutton.dart';
import './provider.dart';
import './utils.dart';

const buildingsNames = {
    'SAB':  'Второй гуманитарный корпус',
    'PHYS': 'Физический корпус',
    'BIO':  'Биологический корпус',
};

const buildingsFloors = {
    'SAB':  [1, 2],
    'PHYS': [-1, 1, 2, 3, 4, 5],
    'BIO':  [1],
};

class FloorMapSelectorButton extends ConsumerWidget {
    const FloorMapSelectorButton({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        ref.watch(buildingProvider);
        final prefs = ref.watch(settingsProvider).value!;

        return UniScheduleDropDownButton(
            hint: 'Выберите корпус',
            alignment: Alignment.center,

            items: buildingsNames.toList(
                (e) => DropdownMenuItem<String>(
                    value: e.key,
                    child: Container(
                        alignment: Alignment.center,
                        child: Text(e.value, maxLines: 1, overflow: TextOverflow.fade),
                    ),
                ),
            )
            .toList(),

            initialSelection: prefs.getString('buildingId'),

            onSelected: (String? value) async {
                if (prefs.getString('buildingId') != value) {
                    await prefs.setString('buildingId', value!);
                    await prefs.setString('buildingName', buildingsNames[value]!);
                    ref.invalidate(buildingProvider);
                }
            },
        );
    }
}
