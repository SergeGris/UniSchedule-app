import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './utils.dart';
import './provider.dart';

const buildingsNames = {
    'SAB':  'Второй гуманитарный корпус',
    'PHYS': 'Физический корпус',
    'BIO':  'Биологический корпус'
};

const buildingsFloors = {
    'SAB':  [1, 2],
    'PHYS': [-1, 1, 2, 3, 4, 5],
    'BIO':  [1],
};

class FloorMapSelectorButton extends ConsumerStatefulWidget {
    FloorMapSelectorButton({super.key});

    @override
    ConsumerState<FloorMapSelectorButton> createState() => _FloorMapSelectorState();
}

class _FloorMapSelectorState extends ConsumerState<FloorMapSelectorButton> {
    _FloorMapSelectorState();

    String? buildingName;
    String? buildingId;

    @override
    Widget build(BuildContext context) {
        final prefs = ref.watch(settingsProvider).value!;

        return UniScheduleDropDownButton(
            hint: 'Выберете корпус',
            alignment: Alignment.center,
            items: buildingsNames.toList(
                (e) => DropdownMenuItem<String>(
                    value: e.key,
                    child: Text(e.value),
                )
            )
            .toList(),
            initialSelection: prefs.getString('buildingId'),
            onSelected: (String? value) {
                prefs.setString('buildingId', value!);
                prefs.setString('buildingName', buildingsNames[value!]!);
                ref.invalidate(settingsProvider);
            },
        );
    }
}
