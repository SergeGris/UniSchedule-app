
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/class_card.dart';
import '../scheduleloader.dart';
import '../utils.dart';
import '../provider.dart';

class HomePage extends ConsumerWidget {
    const HomePage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        return ScheduleLoader(
            (schedule) {
                final date = ref.watch(datetimeProvider).unwrapPrevious();

                return date.when(
                    skipLoadingOnReload: true,
                    loading: () => getLoadingIndicator(() => refreshSchedule(ref)),
                    error: (e, st) => getErrorContainer('БАГ: Не удалось загрузить ВРЕМЯ!'),
                    data: (date) {
                        final day = date.weekday - 1;
                        final weekParity = getWeekParity(date: date, schedule: schedule, showCurrentWeek: false);//TODO(getWeekIndex(date, schedule) ?? 0) % schedule.weeks.length;
                        final week = schedule.weeks[weekParity];

                        late Iterable<ClassCard> nextClasses;
                        late String listTitle;

                        if (day >= week.days.length
                            || week.days[day].classes.isEmpty
                            || (schedule.studiesBegin?.isAfter(date) ?? false)
                            || (schedule.studiesEnd?.isBefore(date) ?? false)) {
                            listTitle = 'Сегодня пар нет';
                            nextClasses = [];
                        } else {
                            final time = TimeOfDay.fromDateTime(date);
                            final classes = week.days[day].classes
                                .where((class0) => class0.end.isNotBeforeThan(time))
                                .toList();

                            final skipped = week.days[day].classes.length - classes.length;

                            nextClasses = classes
                                .mapIndexed(
                                    (class0, index) => ClassCard(
                                        classes: classes,
                                        index: index,
                                        number: index + skipped + 1,
                                        showProgress: true,
                                        horizontalMargin: 8.0,
                                        borderRadius: 8.0
                                    )
                                )
                                .toList()
                                .nonNulls;

                            if (nextClasses.isNotEmpty) {
                                final untilBegin = classes[0].start.differenceInMinutes(time);

                                if (untilBegin < 0) { // Пара уже началась и идёт
                                    final untilEnd = classes[0].end.differenceInMinutes(time);
                                    final hours   = untilEnd ~/ 60;
                                    final minutes = untilEnd % 60;

                                    if (hours == 0 && minutes == 0) {
                                        listTitle = 'Пара закончилась';
                                    } else {
                                        final h = hours   > 0 ? ' $hours ${  plural(hours,   ["час",    "часа",   "часов"])}' : '';
                                        final m = minutes > 0 ? ' $minutes ${plural(minutes, ["минуту", "минуты", "минут"])}' : '';

                                        listTitle = 'Идёт ' + (classes[0].type?.name.toLowerCase() ?? 'пара') + ', до конца —$h$m';
                                    }
                                } else {
                                    final hours   = untilBegin ~/ 60;
                                    final minutes = untilBegin % 60;

                                    if (hours == 0 && minutes == 0) {
                                        listTitle = 'Пара началась';
                                    } else {
                                        final h = hours   > 0 ? ' $hours ${  plural(hours,   ["час",    "часа",   "часов"])}' : '';
                                        final m = minutes > 0 ? ' $minutes ${plural(minutes, ["минуту", "минуты", "минут"])}' : '';

                                        listTitle = 'Следующая пара через$h$m';
                                    }
                                }
                            } else {
                                listTitle = 'Сегодня пар больше нет';
                            }
                        }

                        return ListView(
                            children: [
                                nextClasses.isEmpty
                                    ? Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.all(8.0),
                                        width: 80,
                                        height: 80,
                                        //TODO decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
                                        child: Text(
                                            listTitle,
                                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                color: Theme.of(context).colorScheme.primary,
                                            ),
                                            overflow: TextOverflow.ellipsis
                                        )
                                    )
                                    : ListTile(
                                        title: Center(
                                            child: Text(
                                                listTitle,
                                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                    color: Theme.of(context).colorScheme.primary
                                                ),
                                                overflow: TextOverflow.ellipsis)
                                        )
                                    ), // TODO ellipsis?
                                ...nextClasses,
                            ],
                        );
                    }
                );
            }
        );
    }
}
