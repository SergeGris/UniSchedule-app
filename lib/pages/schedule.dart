import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:UniSchedule/widgets/class_card.dart';

import '../scheduleloader.dart';
import '../utils.dart';

class SchedulePage extends ConsumerWidget {
    const SchedulePage({required this.showCurrentWeek, super.key});
    final bool showCurrentWeek;

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        List<Widget> dateTitleShort(WidgetRef ref, DateTime date) {
            final month = [
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
            ][date.month - 1];

            //return [ Text('${date.day}, $month', overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall!) ];
            return [
                Text('${date.day}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall!
                ),
                Text('$month',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall!
                )
            ];
        }

        final currentWeekDay = (DateTime.now().weekday - 1);

        DateTime getScheduleDay(int index) => DateTime.now().add(Duration(days: index + 1 - currentWeekDay - 1 + (showCurrentWeek ? 0 : 7)));

        return ScheduleLoader(
            (schedule) {
                return ScaffoldMessenger(
                    child: Builder(builder: (context) {
                            final weekParity = ((getWeekNumber(DateTime.now(), schedule) ?? 0) + (showCurrentWeek ? 0 : 1)) % schedule.weeks.length; // TODO
                            final week = schedule.weeks[weekParity];
                            final weekdayTabs = week.days.mapIndexed(
                                (day, index) => Tab(
                                    height: 60.0 * MediaQuery.of(context).textScaleFactor, // FUCK TODO fucking magic constant. Pay attention to <https://stackoverflow.com/a/62536187>
                                    child: OverflowBar(
                                        overflowAlignment: OverflowBarAlignment.center,
                                        alignment: MainAxisAlignment.center,
                                        overflowSpacing: 1.0,
                                        children: <Widget>[
                                            Column(
                                                children: [
                                                    Text(
                                                        day.dayAbbr,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: Theme.of(context).textTheme.bodyMedium!,
                                                        softWrap: true
                                                    ),
                                                    ...dateTitleShort(
                                                        ref,
                                                        getScheduleDay(index)
                                                    )
                                                ]
                                            )
                                        ]
                                    )
                                )
                            ).toList();

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
                                        children: [
                                            ...week.days.mapIndexed(
                                                (day, index) => RefreshIndicator(
                                                    onRefresh: () => refreshSchedule(ref),
                                                    child: day.classes.isEmpty || (schedule.studiesBegin?.isAfter(getScheduleDay(index)) ?? false)
                                                    ? ListView(
                                                        children: [
                                                            Container(
                                                                alignment: Alignment.center,
                                                                margin: const EdgeInsets.all(8.0),
                                                                child: Text(
                                                                    'Свободный день',
                                                                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                                                        color: Theme.of(context).colorScheme.primary,
                                                                    )
                                                                )
                                                            )
                                                        ]
                                                    )
                                                    : ListView.separated(
                                                        padding: const EdgeInsets.only(top: 8.0, bottom: kFloatingActionButtonMargin + 48.0 /* TODO compute size of floating button. */),
                                                        itemCount: day.classes.length,
                                                        itemBuilder: (context, index) => (
                                                            ClassCard(
                                                                classes: day.classes,
                                                                index: index,
                                                                showProgress: false,
                                                                number: index + 1,
                                                                horizontalMargin: horizontalMargin,
                                                                borderRadius: borderRadius
                                                            )
                                                        ),
                                                        separatorBuilder: (context, index) => const Divider(
                                                            indent: horizontalMargin + borderRadius,
                                                            endIndent: horizontalMargin + borderRadius,
                                                        )
                                                    )
                                                )
                                            )
                                        ]
                                    )
                                )
                            );
                        }
                    )
                );
            }
        );
    }
}
