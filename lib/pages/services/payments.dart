
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
import 'package:intl/intl.dart';

// TODO move to seperated file
// TODO rename
class PaymentsPage extends StatefulWidget {
    const PaymentsPage({super.key});

    @override
    State<PaymentsPage> createState() => _PaymentsPageState();
}

class SelectButtons extends StatefulWidget {
    const SelectButtons({super.key, required this.select, required this.multiselect, required this.ss});

    final SelectButtonData select;
    final bool multiselect;
    final void Function() ss;

    @override
    State<SelectButtons> createState() => SelectButtonsState();
}

class SelectButtonsState extends State<SelectButtons> {
    @override
    Widget build(BuildContext context) {
        return ToggleButtons(
            direction: Axis.horizontal,
            onPressed: (int index) {
                setState(
                    () {
                        widget.ss();
                        if (widget.multiselect) {
                            widget.select.selected[index] = !widget.select.selected[index];
                        } else {
                            for (int i = 0; i < widget.select.selected.length; i++) {
                                widget.select.selected[i] = i == index;
                            }
                        }
                    }
                );
            },
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            //selectedBorderColor: Colors.red[700],
            //selectedColor: Colors.white,
            //fillColor: Colors.red[200],
            //color: Colors.red[400],
            // constraints: const BoxConstraints(
            //     minHeight: 40.0,
            //     minWidth: 80.0,
            // ),
            isSelected: widget.select.selected,
            children: widget.select.children.map((e) => Text(e)).cast<Widget>().toList(),
        );
    }
}

class SelectButtonData {
    SelectButtonData(this.children)
      : selected = List<bool>.filled(children.length, false, growable: false);
    final List<String> children;
    final List<bool> selected;
}

class _PaymentsPageState extends State<PaymentsPage> {
    final years = SelectButtonData(<String>['1', '2', '3', '4', '1М', '2М']);
    final marks = SelectButtonData(<String>['3', '4', '5']);
    final peresda = SelectButtonData(<String>['Были', 'Не были']);
    final pgas = SelectButtonData(<String>['Получаю', 'Не получаю']);
    final gss = SelectButtonData(<String>['Получаю', 'Не получаю']);
    final profsous = SelectButtonData(<String>['Состою', 'Не состою']);

    bool _allSelected() {
        return marks.selected.any((e) => e);
        return years.selected.any((e) => e)
        && marks.selected.any((e) => e)
        && peresda.selected.any((e) => e)
        && pgas.selected.any((e) => e)
        && gss.selected.any((e) => e)
        && profsous.selected.any((e) => e);
    }

    double _calcMoney() {
        return 2941.00; // О да, деньги в double!
    }

    String formatMoney(double money) {
        return '${NumberFormat.currency(locale: "ru_RU", symbol: "₽").format(money)}';
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Калькулятор стипендии'),
                shadowColor: Theme.of(context).shadowColor,
            ),

            bottomSheet: _allSelected()
            ? BottomSheet(
                enableDrag: false,
                onClosing: (){},
                builder: (BuildContext context) {
                    return Container(
                        // decoration: BoxDecoration(
                        //     // border: Border.all(
                        //     //     color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                        //     // ),
                        //     borderRadius: BorderRadius.circular(8),
                        //     //color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                        // ),

                        //color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.bottomCenter,
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Center(
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                    Text('Итого:', style: Theme.of(context).textTheme.titleMedium),
                                    const Spacer(),
                                    Text(formatMoney(_calcMoney()), style: Theme.of(context).textTheme.titleMedium),
                                ],
                            ),
                        ),
                    );
                }
            )
            : null,

            body: ListView(
                padding: const EdgeInsets.only(top: 8.0, bottom: kFloatingActionButtonMargin + 48.0 /* TODO compute size of floating button. */),
                children: <Widget>[
                    const ServiceSubtitle('Курс обучения'),
                    SelectButtons(select: years, multiselect: false, ss: () => setState(() {})),
                    const SizedBox(height: 16),

                    const ServiceSubtitle('Оценки за последнюю сессию'),
                    SelectButtons(select: marks, multiselect: true, ss: () => setState(() {})),
                    const SizedBox(height: 16),

                    const ServiceSubtitle('Пересдачи за последнюю сессию'),
                    SelectButtons(select: peresda, multiselect: false, ss: () => setState(() {})),
                    const SizedBox(height: 16),

                    const ServiceSubtitle('ПГАС'),
                    SelectButtons(select: pgas, multiselect: false, ss: () => setState(() {})),
                    const SizedBox(height: 16),

                    const ServiceSubtitle('ГСС'),
                    SelectButtons(select: gss, multiselect: false, ss: () => setState(() {})),
                    const SizedBox(height: 16),

                    const ServiceSubtitle('Членство в профсоюзе'),
                    SelectButtons(select: profsous, multiselect: false, ss: () => setState(() {})),
                ]
            )
            //floatingActionButtonLocation: _allSelected() ? FloatingActionButtonLocation.centerDocked : null,
        );
    }
}
