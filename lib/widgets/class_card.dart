
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

    final bool haveClass;
    final Color color;
    final int number;
    final String begin;
    final String end;
    final String? name;
    final List<TeacherAndRoom?> teachersAndRooms;
    final String? building;
    final ClassType? type;
    final String? note;
    final double borderRadius;
    final double horizontalMargin;

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
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.textScalerOf(context).scale(1.0),
                    horizontal: MediaQuery.textScalerOf(context).scale(4.0)
                ),
                decoration: ShapeDecoration(
                    color: Theme.of(context).colorScheme.tertiary.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MediaQuery.textScalerOf(context).scale(16.0)),
                    ),
                ),
                child: Text(
                    '${number < strings.length ? strings[number - 1] : number} пара',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                ),
            );
        }

        Widget className(String name) => Text(
            name,
            maxLines: 2,
            softWrap: true,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
            )
        );

        Widget classTeachersAndRooms(List<TeacherAndRoom?> teachersAndRooms) {
            final tr = teachersAndRooms.nonNulls.where((e) => (e.room != null || e.teacher != null));

            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tr.map(
                    (tr) => Text(
                        [ tr.room, tr.teacher ].nonNulls.join(' — '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                        ),
                    )
                )
                .cast<Widget>()
                .toList()
            );
        }

        Widget classNote(String note) => Text(
            note,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
            )
        );

        Widget classType(ClassType type) => Row(
            children: <Widget>[
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.textScalerOf(context).scale(4.0)),
                    child: Icon(
                        Icons.circle,
                        color: type.color,
                        size: MediaQuery.textScalerOf(context).scale(
                            Theme.of(context).textTheme.bodySmall?.fontSize ?? 14.0,
                        ),
                    ),
                ),

                Text(
                    type.name,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                    )
                ),
            ],
        );

        Widget classBuilding(String building) => Text(
            building,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
            )
        );

        double getTimeWidth() => textWidth(
            context,
            const TimeOfDay(hour: 0, minute: 0).format24hour(),
            Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16.0)
        );

        return Card(
            color: color,
            elevation: 0, // We do many magic with colors and theirs opacity, so set elevation to zero to get more control on color.
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.textScalerOf(context).scale(horizontalMargin)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MediaQuery.textScalerOf(context).scale(borderRadius))),
            child: Padding(
                padding: EdgeInsets.all(MediaQuery.textScalerOf(context).scale(8.0)),
                child: Row(
                    children: <Widget>[
                        SizedBox(
                            width: getTimeWidth(),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                    Text(
                                        begin,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                        ),
                                    ),
                                    Text(
                                        end,
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.secondary,
                                        ),
                                    ),
                                ],
                            ),
                        ),

                        SizedBox(width: MediaQuery.textScalerOf(context).scale(8.0)),

                        Expanded( // Need for Spacer() in Row() widget.
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: !haveClass
                                ? <Widget>[
                                    classNumber(number),
                                    className('Окно'),
                                ]
                                : <Widget>[
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                            classNumber(number),
                                            if (type != null)
                                            classType(type!),
                                        ],
                                    ),

                                    className(name!),

                                    if (teachersAndRooms.nonNulls.isNotEmpty)
                                    classTeachersAndRooms(teachersAndRooms),

                                    if (building != null)
                                    classBuilding(building!),

                                    if (note != null)
                                    classNote(note!),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}

class ClassCard extends StatelessWidget {
    const ClassCard({super.key,
                     required this.classes,
                     required this.index,
                     required this.showProgress,
                     required this.horizontalMargin,
                     required this.borderRadius});

    final List<Class> classes;
    final int index;
    final bool showProgress;
    final double horizontalMargin;
    final double borderRadius;

    @override
    Widget build(BuildContext context) {
        final class0 = classes[index];
        final haveClass = class0.name != null;
        final begin = haveClass ? class0.start.format24hour() : (index > 0                  ? classes[index - 1].end.format24hour()   : null);
        final end   = haveClass ? class0.end.format24hour()   : (index + 1 < classes.length ? classes[index + 1].start.format24hour() : null);
        final cardColor = Theme.of(context).colorScheme.primaryContainer;

        final card = ClassCardTile(
            haveClass: haveClass,
            color: showProgress ? Colors.transparent : cardColor,
            number: class0.number,
            begin: begin ?? '--:--',
            end: end ?? '--:--',
            name: class0.name,
            teachersAndRooms: class0.teachersAndRooms,
            building: class0.building,
            type: class0.type,
            note: class0.note,
            borderRadius: borderRadius,
            horizontalMargin: horizontalMargin,
        );

        // If not showing progress, then do not build stack with extra unused stuff.
        if (!showProgress) {
            return card;
        } else {
            return Stack(
                children: <Widget>[
                    Positioned.fill(
                        child: Container(
                            margin: EdgeInsets.symmetric(horizontal: MediaQuery.textScalerOf(context).scale(horizontalMargin)),
                            child: LinearProgressIndicator(
                                backgroundColor: cardColor,
                                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.15),
                                value: TimeOfDay.now().differenceInMinutes(class0.start) / class0.end.differenceInMinutes(class0.start),
                                borderRadius: BorderRadius.circular(MediaQuery.textScalerOf(context).scale(borderRadius)),
                            )
                        )
                    ),
                    card,
                ],
            );
        }
    }
}
