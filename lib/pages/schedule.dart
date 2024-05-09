
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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/class_card.dart';
import '../models/schedule.dart';

import '../utils.dart';

class SchedulePage extends ConsumerWidget {
    const SchedulePage({super.key, required this.schedule, required this.showNextWeek});
    final Schedule schedule;
    final bool showNextWeek;

    @override
    Widget build(final BuildContext context, final WidgetRef ref) {
        final date = DateTime.now();
        final currentWeekDay = date.weekday - 1;

        // Винительный падеж (кого?/чего?)
        const monthAbbrs = [
            'янв',
            'фев',
            'мар',
            'апр',
            'мая',
            'июн',
            'июл',
            'авг',
            'сен',
            'окт',
            'ноя',
            'дек',
        ];

        DateTime getScheduleDay(int index) => date.add(
            Duration(days: index + 1 - (currentWeekDay + 1) + (showNextWeek ? 7 : 0))
        );

        final weekParity = getWeekParity(date, schedule, showNextWeek: showNextWeek);
        final week = schedule.weeks[weekParity];
        final weekdayTabs = week.days.mapIndexed(
            (day, index) {
                final dayDate = getScheduleDay(index); // Дата конкретного дня недели.

                final tabText = <Widget>[
                    // Каждая вкладка имеет следующий вид:
                    //  Пн
                    //   1
                    //  янв
                    Text(
                        day.dayAbbr,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                            fontStyle: Theme.of(context).textTheme.titleMedium?.fontStyle,
                            fontWeight: Theme.of(context).textTheme.titleMedium?.fontWeight,
                        ),
                    ),
                    Text(
                        '${dayDate.day}',
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                            fontStyle: Theme.of(context).textTheme.bodySmall?.fontStyle,
                            fontWeight: Theme.of(context).textTheme.bodySmall?.fontWeight,
                        ),
                    ),
                    Text(
                        monthAbbrs[dayDate.month - 1],
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                            fontStyle: Theme.of(context).textTheme.bodySmall?.fontStyle,
                            fontWeight: Theme.of(context).textTheme.bodySmall?.fontWeight,
                        ),
                    )
                ];

                return Tab(
                    // FUCK TODO fucking magic constant. Pay attention to <https://stackoverflow.com/a/62536187>
                    height: MediaQuery.textScalerOf(context).scale(60.0),
                    child: SizedBox(
                        width: max(
                            MediaQuery.of(context).size.width / week.days.length,
                            MediaQuery.textScalerOf(context).scale(48.0)
                        ),
                        child: Column(children: tabText)
                    ),
                );
            }
        )
        .toList();

        const horizontalMargin = 8.0;
        const borderRadius = 8.0;

        return DefaultTabController(
            initialIndex: currentWeekDay % week.days.length,
            length: week.days.length,
            child: Scaffold(
                appBar: TabBar(
                    tabs: weekdayTabs,
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,

                    // Used for adaptivity.
                    padding: EdgeInsets.zero,
                    indicatorPadding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                ),

                body: TabBarView(
                    children: week.days.mapIndexed(
                        (day, index) => RefreshIndicator(
                            onRefresh: () => refreshSchedule(ref),
                            child: day.classes.isEmpty
                            || (schedule.studiesBegin?.isAfter(getScheduleDay(index)) ?? false)
                            || (schedule.studiesEnd?.isBefore(getScheduleDay(index)) ?? false)
                            ? Center(
                                child: Text(
                                    'Свободный день',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                    ),
                                ),
                            )
                            : ListView.separated(
                                padding: const EdgeInsets.only(top: 8.0, bottom: kFloatingActionButtonMargin + 48.0 /* TODO compute size of floating button. */),
                                itemCount: day.classes.length,
                                itemBuilder: (context, index) => ClassCard(
                                    classes: day.classes,
                                    index: index,
                                    showProgress: false,
                                    horizontalMargin: horizontalMargin,
                                    borderRadius: borderRadius,
                                ),
                                separatorBuilder: (context, index) => const Divider(
                                    indent: horizontalMargin + borderRadius,
                                    endIndent: horizontalMargin + borderRadius,
                                ),
                            ),
                        ),
                    )
                    .toList(),
                ),
            ),
        );
    }
}
