import 'package:flutter/material.dart';

import '../models/schedule.dart';
import '../utils.dart';

class ClassCardTile extends StatelessWidget {
    ClassCardTile({required this.haveClass,
                   required this.color,
                   required this.number,
                   required this.begin,
                   required this.end,
                   required this.name,
                   required this.teachersAndRooms,
                   required this.building,
                   required this.type,
                   required this.note,
                   required this.borderRadius,
                   required this.horizontalMargin,
                   super.key});

    bool haveClass;
    Color color;
    int number;
    String begin;
    String end;
    String? name;
    List<TeacherAndRoom?> teachersAndRooms;
    String? building;
    ClassType? type;
    String? note;
    double borderRadius;
    double horizontalMargin;

    @override
    Widget build(BuildContext context) {
        Widget classNumber(int number) {
            const strings = [
                'Первая',
                'Вторая',
                'Третья',
                'Четвёртая',
                'Пятая',
                'Шестая',
                'Седьмая',
                'Восьмая',
                'Девятая',
                'Десятая',
                'Одиннадцатая',
                'Двенадцатая',
            ];

            return Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 1,
                    horizontal: 4
                ),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                    number < strings.length ? strings[number - 1] + ' пара' : '$number пара',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall!
                ),
            );
        }

        Widget className(String name) => Text(
            name,
            maxLines: 2,
            softWrap: true,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary
            )
        );

        //TODO return list of texts?
        Widget classTeachersAndRooms(List<TeacherAndRoom?> teachersAndRooms) => Text(
            teachersAndRooms
            .nonNulls
            .map((tr) => [ tr.teacher, tr.room ].nonNulls.join(' — '))
            .join('\n'),
            style: Theme.of(context).textTheme.bodySmall!
        );

        Widget classNote(String note) => Text(
            note,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary,
            )
        );

        return Card(
            color: color,
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
            child: Row(children: [
                    const SizedBox(width: 12),

                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            const SizedBox(height: 12),

                            Text(
                                begin,
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                )
                            ),

                            Text(
                                end,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                )
                            ),

                            const SizedBox(height: 12),
                        ],
                    ),

                    const SizedBox(width: 12),

                    Expanded( // Need for Spacer() in Row() widget.
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: !haveClass
                            ? [
                                classNumber(number),
                                className('Окно'),
                            ]
                            : [
                                const SizedBox(height: 8),

                                Row(children: [
                                        classNumber(number),

                                        if (type != null)
                                        ...[
                                            const Spacer(),

                                            Icon(
                                                Icons.circle,
                                                color: type!.color,
                                                size: Theme.of(context).textTheme.bodySmall!.fontSize
                                            ),

                                            const SizedBox(width: 3),

                                            Text(
                                                type!.name,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context).textTheme.bodySmall!
                                            ),
                                        ],
                                    ],
                                ),

                                className(name!),

                                if (teachersAndRooms.nonNulls.isNotEmpty)
                                classTeachersAndRooms(teachersAndRooms),

                                if (building != null)
                                Text(
                                    building!,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall!
                                ),

                                if (note != null)
                                classNote(note!),

                                const SizedBox(height: 8),
                            ],
                        ),
                    ),

                    const SizedBox(width: 12),
                ],
            ),
        );
    }
}

class ClassCard extends StatelessWidget {
    const ClassCard({required this.classes,
                     required this.index,
                     required this.showProgress,
                     required this.number,
                     required this.horizontalMargin,
                     required this.borderRadius,
                     super.key});

    final List<Class> classes;
    final int index;
    final int number;
    final bool showProgress;
    final double horizontalMargin;
    final double borderRadius;

    @override
    Widget build(BuildContext context) {
        final time = TimeOfDay.now();
        final class0 = classes[index];
        final bool haveClass = (class0.name != null);
        final begin = haveClass ? class0.start.format(context) : (index > 0                  ? classes[index - 1].end.format(context)   : null);
        final end =   haveClass ? class0.end.format(context)   : (index + 1 < classes.length ? classes[index + 1].start.format(context) : null);

        final cardColor = Theme.of(context).brightness == Brightness.dark
            ? [ // Dark
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2), // Even
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1), // Odd
            ]
            : [ // Light
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8), // Even
                Theme.of(context).colorScheme.primaryContainer.withOpacity(1.0), // Odd
            ];

        // TODO
        // Text(
        //     condimentList,
        //     style: TextStyle(color:Colors.grey),
        //     maxLines: 1,
        //     overflow: TextOverflow.ellipsis,
        // ),

        return Column(
            children: [
                if (begin != null && end != null)
                ClassCardTile(
                    haveClass: haveClass,
                    color: cardColor[index % 2],
                    number: number,
                    begin: begin,
                    end: end,
                    name: class0.name,
                    teachersAndRooms: class0.teachersAndRooms,
                    building: class0.building,
                    type: class0.type,
                    note: class0.note,
                    borderRadius: borderRadius,
                    horizontalMargin: horizontalMargin,
                )
                else if (index + 1 < classes.length)
                Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(8.0),
                    child: Text(
                        'Пары нет',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                        )
                    )
                ),
                if (showProgress)
                Padding(
                    padding: EdgeInsets.only(
                        left: borderRadius + horizontalMargin,
                        right: borderRadius + horizontalMargin,
                        top: 0.0,
                        bottom: horizontalMargin
                    ),
                    child: LinearProgressIndicator(
                        value: time.differenceInMinutes(class0.start) / class0.end.differenceInMinutes(class0.start),
                        borderRadius: BorderRadius.circular(borderRadius),
                        // value: ((time.hour * 60 + time.minute) - (class0.start.hour * 60 + class0.start.minute))
                        //      / ((class0.end.hour * 60 + class0.end.minute) - (class0.start.hour * 60 + class0.start.minute)),
                    ),
                ),
            ],
        );
    }
}
