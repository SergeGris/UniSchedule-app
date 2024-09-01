
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

import './provider.dart';
import './utils.dart';

enum Building {
    SAB('Второй гуманитарный корпус', [1, 2]),
    PHYS('Физический корпус',          [-1, 1, 2, 3, 4, 5]),
    BIO('Биологический корпус',       [1]);


    const Building(this.label, this.floors);

    final String label;
    final List<int> floors;
}

const buildingsData = {
    'SAB':  Building.SAB,
    'PHYS': Building.PHYS,
    'BIO':  Building.BIO,
};

class FloorMapSelectorButton extends ConsumerWidget {
    const FloorMapSelectorButton({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        ref.watch(buildingProvider);
        final prefs = ref.watch(settingsProvider).value!;
        final building = prefs.getString('buildingId');

        // // Get the RenderBox of the TextButton
        // final RenderBox button = context.findRenderObject() as RenderBox;

        // // Get the position of the button
        // final Offset buttonPosition = button.localToGlobal(Offset.zero);

        // // Calculate the position for the menu
        // final Offset menuPosition = Offset(buttonPosition.dx, buttonPosition.dy + button.size.height);
        // print(menuPosition);
        // print(MediaQuery.of(context).size);
        // return OutlinedButton(
        //     child: Text('Текс                         т'),
        //     onPressed: () async {
        //         await showMenu<String>(
        //             popUpAnimationStyle: AnimationStyle(
        //                 duration: const Duration(milliseconds: 200)
        //             ),
        //             context: context,
        //             //position: RelativeRect.fromLTRB(0,0,0,0),
        //             position: RelativeRect.fromLTRB(menuPosition.dx, menuPosition.dy, menuPosition.dx, menuPosition.dy),
        //             items: buildingsNames.toList(
        //                     (b) => PopupMenuItem<String>(
        //               value: '123',
        //               child: Text('123'),
        //               )
        //               )
        //         ).then(
        //             (String? value) async {
        //                 if (value != null && building != value) {
        //                     await prefs.setString('buildingId', value!);
        //                     await prefs.setString('buildingName', buildingsNames[value]!);
        //                     ref.invalidate(buildingProvider);
        //                 }
        //             }
        //         );
        //     }
        // );

        // TODO
        // return DropdownButton<String>(
        //     elevation: 1,
        //     onChanged: (value) async {
        //         if (building != value) {
        //             await prefs.setString('buildingId', value!);
        //             await prefs.setString('buildingName', buildingsNames[value]!);
        //             ref.invalidate(buildingProvider);
        //         }
        //     },
        //     value: building,
        //     items: buildingsNames.toList(
        //         (e) => DropdownMenuItem(value: e.key, child: Text(e.value))
        //     ),
        // );

        return DropdownMenu<String>(
            initialSelection: building,
            requestFocusOnTap: false,
            width: MediaQuery.of(context).size.width * Constants.goldenRatio,

            label: const Text('Здание'),

            onSelected: (String? value) async {
                if (value != null && building != value) {
                    await prefs.setString('buildingId', value);
                    await prefs.setString('buildingName', buildingsData[value]!.label);
                    ref.invalidate(buildingProvider);
                }
            },

            dropdownMenuEntries: buildingsData.values.map(
                (e) => DropdownMenuEntry(
                    value: e.name,
                    label: e.label,
                ),
            ).toList(),
        );

        // return UniScheduleDropDownButton(
        //     hint: 'Выберите корпус',
        //     alignment: Alignment.center,

        //     items: buildingsNames.toList(
        //         (e) => DropdownMenuItem<String>(
        //             value: e.key,
        //             child: Container(
        //                 alignment: Alignment.center,
        //                 child: Text(e.value, maxLines: 1, overflow: TextOverflow.fade),
        //             ),
        //         ),
        //     )
        //     .toList(),

        //     initialSelection: prefs.getString('buildingId'),

        //     onSelected: (String? value) async {
        //         if (prefs.getString('buildingId') != value) {
        //             await prefs.setString('buildingId', value!);
        //             await prefs.setString('buildingName', buildingsNames[value]!);
        //             ref.invalidate(buildingProvider);
        //         }
        //     },
        // );
    }
}
