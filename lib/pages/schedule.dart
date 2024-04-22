import 'package:UniSchedule/widgets/class_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../scheduleloader.dart';
import '../utils.dart';

class SchedulePage extends ConsumerWidget {
    const SchedulePage({super.key, required this.showNextWeek});
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

        DateTime getScheduleDay(int index) {
            return date.add(
                Duration(days: index + 1 - (currentWeekDay + 1) + (showNextWeek ? 7 : 0))
            );
        }

        return ScheduleLoader(
            (schedule) {
                return ScaffoldMessenger(
                    child: Builder(
                        builder: (context) {
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
                                            style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium?.fontSize),
                                        ),
                                        Text(
                                            '${dayDate.day}',
                                            overflow: TextOverflow.fade,
                                            style: TextStyle(fontSize: Theme.of(context).textTheme.titleSmall?.fontSize)
                                        ),
                                        Text(
                                            monthAbbrs[dayDate.month - 1],
                                            overflow: TextOverflow.fade,
                                            style: TextStyle(fontSize: Theme.of(context).textTheme.bodySmall?.fontSize)
                                        )
                                    ];

                                    // double computeHeight(String? text, TextStyle? textStyle) {
                                    //     final Size size = (TextPainter(
                                    //             text: TextSpan(text: text, style: textStyle),
                                    //             maxLines: 1,
                                    //             textScaleFactor: MediaQuery.of(context).textScaleFactor,
                                    //             textDirection: TextDirection.ltr)
                                    //         ..layout())
                                    //     .size;

                                    //     return size.height * (textStyle?.height ?? 1.0);
                                    //     //return (style!.fontSize ?? 1) * (style!.height ?? 1);
                                    // }

                                    // final textHeight = tabText.fold(10.0, (previous, element) => previous + computeHeight(element.data, element.style));

                                    // print('$textHeight');

                                    return Tab(
                                        // FUCK TODO fucking magic constant. Pay attention to <https://stackoverflow.com/a/62536187>
                                        height: 60.0 * getScale(context, Theme.of(context).textTheme.titleMedium?.fontSize ?? 16.0),
                                        child: Column(
                                            children: tabText
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
                                    appBar: AppBar(
                                        toolbarHeight: 0,
                                        bottom: TabBar(tabs: weekdayTabs),
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
                                                        number: index + 1,
                                                        horizontalMargin: horizontalMargin,
                                                        borderRadius: borderRadius,
                                                    ),
                                                    separatorBuilder: (context, index) => const Divider(
                                                        indent: horizontalMargin + borderRadius,
                                                        endIndent: horizontalMargin + borderRadius,
                                                    ),
                                                ),
                                            ),
                                        ).toList(),
                                    ),
                                ),
                            );
                        }
                    ),
                );
            }
        );
    }
}
