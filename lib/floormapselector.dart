import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            hint: 'Выберете корпус',
            alignment: Alignment.center,

            items: buildingsNames.toList(
                (e) => DropdownMenuItem<String>(
                    value: e.key,
                    child: Container(
                        alignment: Alignment.center,
                        child: Text(e.value, maxLines: 1),
                    ),
                ),
            )
            .toList(),

            initialSelection: prefs.getString('buildingId'),

            onSelected: (String? value) {
                if (prefs.getString('buildingId') != value) {
                    prefs.setString('buildingId', value!);
                    prefs.setString('buildingName', buildingsNames[value]!);
                    ref.invalidate(buildingProvider);
                }
            },
        );
    }
}
