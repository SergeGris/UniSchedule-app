
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/schedule.dart';
import '../utils.dart';
import '../widgets/class_card.dart';

class HomePage extends ConsumerStatefulWidget {
    const HomePage({super.key, required this.schedule});

    final Schedule schedule;

    @override
    ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
    List<Class> getClassesForDate(DateTime date) {
        final day = date.weekday - 1;
        final weekParity = getWeekParity(date, widget.schedule);
        final week = widget.schedule.weeks[weekParity];

        if (day >= week.days.length
            || week.days[day].classes.isEmpty
            || (widget.schedule.studiesBegin?.isAfter(date) ?? false)
            || (widget.schedule.studiesEnd?.isBefore(date) ?? false)) {
            return [];
        }

        return week.days[day].classes;
    }

    @override
    Widget build(BuildContext context) {
        final date = DateTime.now();

        // Rebuild widget each minute.
        Timer(
            Duration(
                // Update when minute number changed.
                seconds: 60 - date.second
            ),
            () {
                // If widget is not mounted (i.e. we are on other page),
                // then do nothing, otherwise rebuild widget.
                if (mounted) {
                    setState(() {});
                }
            },
        );

        final time = TimeOfDay.fromDateTime(date);
        var showProgress = true;
        var initialClasses = getClassesForDate(date).where((c) => c.name != null);
        var pendingClasses = initialClasses.where((c) => c.end.isAfterThan(time)).toList();

        late String listTitle;
        String? listSubTitle;

        if (initialClasses.isEmpty) {
            listTitle = 'Свободный день';
        } else if (pendingClasses.isEmpty) {
            listTitle = 'Пары закончились';
        } else if (pendingClasses.isNotEmpty) {
            final untilBegin = pendingClasses[0].start.differenceInMinutes(time);

            if (untilBegin < 0) { // Пара уже началась и идёт
                final untilEnd = pendingClasses[0].end.differenceInMinutes(time);
                final hours    = untilEnd ~/ 60;
                final minutes  = untilEnd % 60;

                listTitle    = 'Идёт ${pendingClasses[0].type?.label.toLowerCase() ?? "пара"}';
                listSubTitle = 'До конца ${timeToPrettyView(hours, minutes)}';
            } else {
                final hours   = untilBegin ~/ 60;
                final minutes = untilBegin % 60;

                if (pendingClasses.length == initialClasses.length) {
                    listTitle = 'Пары ещё не начались';
                } else {
                    listTitle = 'Перерыв';
                }

                if (hours == 0 && minutes == 0) {
                    listTitle = 'Пара началась';
                } else {
                    listSubTitle = 'До начала ${timeToPrettyView(hours, minutes)}';
                }
            }
        } else {
            listTitle = 'Сегодня пар больше нет';
        }

        if (pendingClasses.isEmpty) {
            int daysToSkip = 0;

            do {
                daysToSkip++;
                initialClasses = getClassesForDate(date.add(Duration(days: daysToSkip)));
            } while (initialClasses.isEmpty && daysToSkip < 30);

            pendingClasses = initialClasses.where((c) => c.name != null).toList();

            if (pendingClasses.isNotEmpty) {
                showProgress = false;
                listSubTitle = 'Ближайшие пары '
                + (daysToSkip == 1
                    ? 'завтра'
                    : (daysToSkip == 2
                        ? 'послезавтра'
                        : numberToWords(daysToSkip - 1) + ' ' + plural(daysToSkip - 1, [ 'день', 'дня', 'дней' ])));
            } else {
                listSubTitle = 'В ближайший месяц пар нет';
            }
        }

        return Column(
            children: <Widget>[
                SizedBox(
                    height: getScheduleTabHeight(context),
                    child: Center(
                        child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            minTileHeight: 0,
                            horizontalTitleGap: 0,
                            minVerticalPadding: 0,
                            minLeadingWidth: 0,

                            title: AnimatedSwitcher(
                                duration: kAnimationDuration,
                                reverseDuration: kAnimationDuration,
                                transitionBuilder: (Widget child, Animation<double> animation) => FadeTransition(
                                    opacity: animation,
                                    child: child,
                                ),

                                child: Text(
                                    // This key causes the AnimatedSwitcher to interpret this as a 'new'
                                    // child each time the count changes, so that it will begin its animation
                                    // when the count changes.
                                    listTitle,
                                    key: ValueKey<String>(listTitle),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.fade,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                    ),
                                ),
                            ),

                            subtitle: AnimatedSwitcher(
                                duration: kAnimationDuration,
                                reverseDuration: kAnimationDuration,
                                transitionBuilder: (Widget child, Animation<double> animation) => FadeTransition(
                                    opacity: animation,
                                    child: child,
                                ),
                                child: listSubTitle == null
                                ? const SizedBox.shrink(key: ValueKey(null))
                                : Text(
                                    listSubTitle,
                                    key: ValueKey<String>(listSubTitle),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.fade,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.secondary,
                                    ),
                                ),
                            ),
                        ),
                    ),
                ),

                Expanded(
                    child: ListView.separated(
                        padding: const EdgeInsets.only(top: 8.0),
                        itemCount: pendingClasses.length,
                        itemBuilder: (context, index) => ClassCard(
                            classes: pendingClasses,
                            index: index,
                            showProgress: showProgress,
                            horizontalMargin: kClassCardHorizontalMargin,
                            borderRadius: kClassCardBorderRadius,
                        ),
                        separatorBuilder: (context, index) => const Divider(
                            indent: kClassCardHorizontalMargin + kClassCardBorderRadius,
                            endIndent: kClassCardHorizontalMargin + kClassCardBorderRadius,
                        ),
                    ),
                ),
            ],
        );
    }
}
