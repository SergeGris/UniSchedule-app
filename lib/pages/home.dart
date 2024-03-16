import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider.dart';
import '../scheduleloader.dart';
import '../utils.dart';
import '../widgets/class_card.dart';

class HomePage extends ConsumerWidget {
    const HomePage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        return ScheduleLoader(
            (schedule) {
                final date = ref.watch(datetimeProvider).unwrapPrevious();

                return date.when(
                    skipLoadingOnReload: true,
                    loading: () => SizedBox(), //TODO getLoadingIndicator(() => refreshSchedule(ref)),
                    error: (e, st) => getErrorContainer('БАГ: Не удалось загрузить ВРЕМЯ!'),
                    data: (date) {
                        final day = date.weekday - 1;
                        final weekParity = getWeekParity(date, schedule);
                        final week = schedule.weeks[weekParity];

                        late Iterable<ClassCard> nextClasses;
                        late String listTitle;
                        String? listSubTitle;

                        if (day >= week.days.length
                            || week.days[day].classes.isEmpty
                            || (schedule.studiesBegin?.isAfter(date) ?? false)
                            || (schedule.studiesEnd?.isBefore(date) ?? false)) {
                            listTitle = 'Сегодня пар нет';
                            nextClasses = [];
                        } else {
                            final time = TimeOfDay.fromDateTime(date);
                            var classes = week.days[day].classes
                                .where((c) => c.end.isNotBeforeThan(time))
                                .toList();

                            final firstClass = classes.indexWhere((c) => c.name != null);

                            if (firstClass >= 0) {
                                classes = classes.skip(firstClass).toList();
                            }

                            final skipped = week.days[day].classes.length - classes.length;

                            nextClasses = classes
                                .mapIndexed(
                                    (c, index) => ClassCard(
                                        classes: classes,
                                        index: index,
                                        number: index + skipped + 1,
                                        showProgress: true,
                                        horizontalMargin: 8.0,
                                        borderRadius: 8.0
                                    ),
                                )
                                .toList()
                                .nonNulls;

                            String timeToPrettyView(int hours, int minutes) {
                                final ph = plural(hours, ['час',  'часа',  'часов']);
                                final pm = plural(minutes, ['минута', 'минуты', 'минут']);

                                if (hours > 0 && minutes > 0) {
                                    return '$hours ' + ph + ' $minutes ' + pm;
                                } else if (hours > 0) {
                                    return '$hours ' + ph;
                                } else if (minutes > 0) {
                                    return '$minutes ' + pm;
                                } else {
                                    return '';
                                }
                            }

                            if (nextClasses.isNotEmpty) {
                                final untilBegin = classes[0].start.differenceInMinutes(time);

                                if (untilBegin < 0) { // Пара уже началась и идёт
                                    final untilEnd = classes[0].end.differenceInMinutes(time);
                                    final hours   = untilEnd ~/ 60;
                                    final minutes = untilEnd % 60;

                                    listTitle = 'Идёт ' + (classes[0].type?.name.toLowerCase() ?? 'пара');

                                    if (hours == 0 && minutes == 0) {
                                        listSubTitle = 'Пара закончилась';
                                    } else {
                                        listSubTitle = 'До конца ' + timeToPrettyView(hours, minutes);
                                    }
                                } else {
                                    final hours   = untilBegin ~/ 60;
                                    final minutes = untilBegin % 60;

                                    listTitle = 'Сейчас пары нет';

                                    if (hours == 0 && minutes == 0) {
                                        listTitle = 'Пара началась';
                                    } else {
                                        listSubTitle = 'До начала ' + timeToPrettyView(hours, minutes);
                                    }
                                }
                            } else {
                                listTitle = 'Сегодня пар больше нет';
                            }
                        }

                        return ListView(
                            children: [
                                if (nextClasses.isEmpty)
                                Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.all(8.0),
                                    width: 80,
                                    height: 80,
                                    //TODO decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
                                    child: Text(
                                        listTitle,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                    ),
                                )
                                else
                                ListTile(
                                    title: Center(
                                        child: Column(
                                            children: [
                                                Text(
                                                    listTitle,
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                        color: Theme.of(context).colorScheme.primary
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                ),

                                                if (listSubTitle != null)
                                                Text(
                                                    listSubTitle,
                                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                        color: Theme.of(context).colorScheme.primary,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                        ),
                                    ),
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
