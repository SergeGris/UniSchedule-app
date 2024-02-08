
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
                    loading: () {
                        return getLoadingIndicator(() => refreshSchedule(ref));
                    },
                    error: (e, st) {
                        return getErrorContainer('ЛОЛ: Не удалось загрузить ВРЕМЯ!');
                    },
                    data: (date) {
                        final day = date.weekday - 1;
                        final weekParity = (getWeekNumber(date, schedule) ?? 0) % schedule.weeks.length;
                        final week = schedule.weeks[weekParity];

                        late Iterable<ClassCard> nextClasses;
                        late String listTitle;

                        if (day >= week.days.length || week.days[day].classes.isEmpty || (schedule.studiesBegin?.isAfter(date) ?? false)) {
                            listTitle = 'Сегодня пар нет';
                            nextClasses = [];
                        } else {
                            final time = TimeOfDay.fromDateTime(date);
                            final classes = week.days[day].classes
                                .where((class0) => class0.end.isNotBeforeThan(time))
                                .toList();

                            int skipped = week.days[day].classes.length - classes.length;

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
                                int diff = classes[0].start.differenceInMinutes(time);

                                if (diff <= 0) {
                                    listTitle = 'Идёт ' + (classes[0].type?.name.toLowerCase() ?? 'пара');
                                } else {
                                    int hours   = diff ~/ 60;
                                    int minutes = diff % 60;

                                    String h = hours   > 0 ? ' $hours ${  plural(hours,   ["час",    "часа",   "часов"])}' : '';
                                    String m = minutes > 0 ? ' $minutes ${plural(minutes, ["минуту", "минуты", "минут"])}' : '';

                                    listTitle = 'Следующая пара через$h$m';
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
                                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                                color: Theme.of(context).colorScheme.primary,
                                            )
                                        )
                                    )
                                    : ListTile(
                                        title: Center(
                                            child: Text(
                                                listTitle,
                                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
