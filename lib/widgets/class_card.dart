
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

class _ClassNumber extends StatelessWidget {
    const _ClassNumber({required this.number});

    final int number;

    @override
    Widget build(BuildContext context) {
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

        return Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            margin: EdgeInsets.zero,
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 6.0),
                child: Text(
                    '${number <= strings.length ? strings[number - 1] : number} пара',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                ),
            ),
        );

        return Container(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.textScalerOf(context).scale(1.0),
                horizontal: MediaQuery.textScalerOf(context).scale(6.0),
            ),
            decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MediaQuery.textScalerOf(context).scale(16.0)),
                ),
            ),
            child: Text(
                '${number <= strings.length ? strings[number - 1] : number} пара',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall
            ),
        );
    }
}

class _ClassName extends StatelessWidget {
    const _ClassName({required this.name});

    final String name;

    @override
    Widget build(BuildContext context) => Text(
        name,
        maxLines: 2,
        softWrap: true,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
        ),
    );
}

class _ClassTeachersAndRooms extends StatelessWidget {
    const _ClassTeachersAndRooms({required this.teachersAndRooms});

    final List<TeacherAndRoom> teachersAndRooms;

    @override
    Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: teachersAndRooms.where((e) => e.room != null || e.teacher != null).map(
            (tr) => Text(
                [ tr.room, tr.teacher ].nonNulls.join(' — '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                ),
            ),
        )
        .cast<Widget>()
        .toList()
    );
}

class _ClassNote extends StatelessWidget {
    const _ClassNote({required this.note});

    final String note;

    @override
    Widget build(BuildContext context) => Text(
        note,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
        ),
    );
}

class _ClassBuilding extends StatelessWidget {
    const _ClassBuilding({required this.building});

    final String building;

    @override
    Widget build(BuildContext context) => Text(
        building,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
        ),
    );
}

class _ClassTime extends StatelessWidget {
    const _ClassTime({required this.begin, required this.end});

    final String begin;
    final String end;

    // double getTimeWidth() => textWidth(
    //     context,
    //     const TimeOfDay(hour: 0, minute: 0).format24hour(),
    //     Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16.0),
    // );

    @override
    Widget build(BuildContext context) => SizedBox(
        //TODO: width: getTimeWidth() + MediaQuery.textScalerOf(context).scale(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                // TODO: Add TextOverflow.
                Text(
                    begin,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                    ),
                ),
                Text(
                    end,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                    ),
                ),
            ],
        ),
    );
}

class _ClassType extends StatelessWidget {
    const _ClassType({required this.type});

    final ClassType type;

    @override
    Widget build(BuildContext context) => Row(
        children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.textScalerOf(context).scale(4.0)
                ),
                child: Material(
                    type: MaterialType.circle,
                    color: Colors.transparent,
                    elevation: 1,
                    child: ColoredElevatedCircle(
                        color: type.color,
                        size: MediaQuery.textScalerOf(context).scale(
                            Theme.of(context).textTheme.bodySmall?.fontSize ?? 14.0,
                        ),
                    ),
                ),
            ),

            Text(
                type.label,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                ),
            ),
        ],
    );
}

class ClassCardTile extends StatelessWidget {
    ClassCardTile({super.key,
                   required this.haveClass,
                   required this.number,
                   required this.begin,
                   required this.end,
                   required this.name,
                   required this.teachersAndRooms,
                   required this.building,
                   required this.type,
                   required this.note,
                   required this.borderRadius,
                   required this.horizontalMargin});

    final bool haveClass;
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
        final content = !haveClass || name == null
        ? () => <Widget>[
            _ClassNumber(number: number),
            const _ClassName(name: 'Окно'),
        ]
        : () => <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    _ClassNumber(number: number),

                    if (type != null)
                    _ClassType(type: type!),
                ],
            ),

            _ClassName(name: name!),

            if (teachersAndRooms.nonNulls.isNotEmpty)
            _ClassTeachersAndRooms(teachersAndRooms: teachersAndRooms.nonNulls.toList()),

            if (building != null)
            _ClassBuilding(building: building!),

            if (note != null)
            _ClassNote(note: note!),
        ];

        return Padding(
            padding: EdgeInsets.all(MediaQuery.textScalerOf(context).scale(8.0)),
            child: IntrinsicHeight( // TODO: Solve other way, probably very slow. Required for VerticalDivider().
                child: Row(
                    children: <Widget>[
                        _ClassTime(begin: begin, end: end),

                        const VerticalDivider(),

                        Expanded( // Need for spaces between in Row() widget.
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: content()
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}

const kClassCardHorizontalMargin = 8.0;
const kClassCardBorderRadius = 8.0;

class ClassCard extends StatelessWidget {
    const ClassCard({super.key,
                     this.haveClass = true,
                     required this.classes,
                     required this.index,
                     this.showProgress = false,
                     this.horizontalMargin = 0.0,
                     this.borderRadius = 0.0,
                     this.onTap});

    final List<Class> classes;
    final int index;
    final bool showProgress;
    final double horizontalMargin;
    final double borderRadius;
    final bool haveClass;
    final VoidCallback? onTap;

    @override
    Widget build(BuildContext context) {
        final class0 = classes[index];
        final have = haveClass || class0.name != null;
        final begin = have ? class0.start.format24hour() : (index > 0                  ? classes[index - 1].end.format24hour()   : null);
        final end   = have ? class0.end.format24hour()   : (index + 1 < classes.length ? classes[index + 1].start.format24hour() : null);
        final cardColor = Theme.of(context).colorScheme.primaryContainer;
        final borderRadius = MediaQuery.textScalerOf(context).scale(this.borderRadius);
        final horizontalMargin = MediaQuery.textScalerOf(context).scale(this.horizontalMargin);

        final cardTile = ClassCardTile(
            haveClass: have,
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

        final cardContent = !showProgress
        ? cardTile // If not showing progress, then do not build stack with extra unused stuff.
        : Stack(
            children: <Widget>[
                Positioned.fill(
                    child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(1 / 8),
                        value: TimeOfDay.now().differenceInMinutes(class0.start) / class0.end.differenceInMinutes(class0.start),
                        borderRadius: BorderRadius.circular(borderRadius),
                    ),
                ),
                cardTile,
            ],
        );

        return Card(
            color: cardColor,
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
            child: onTap == null
            ? cardContent
            : InkWell(
                borderRadius: BorderRadius.circular(borderRadius),
                onTap: onTap,
                child: cardContent,
            ),
        );

        // return card;

        // return Card(
        //     color: cardColor,
        //     margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        //     child: ClipRRect(
        //         borderRadius: BorderRadius.circular(borderRadius),
        //         child: Material(
        //             color: Colors.transparent,
        //             child: InkWell(
        //                 onTap: onTap,
        //                 child: !showProgress
        //                 ? card // If not showing progress, then do not build stack with extra unused stuff.
        //                 : Stack(
        //                     children: <Widget>[
        //                         Positioned.fill(
        //                             child: LinearProgressIndicator(
        //                                 backgroundColor: Colors.transparent,
        //                                 color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.15),
        //                                 value: TimeOfDay.now().differenceInMinutes(class0.start) / class0.end.differenceInMinutes(class0.start),
        //                                 borderRadius: BorderRadius.circular(borderRadius),
        //                             ),
        //                         ),
        //                         card,
        //                     ],
        //                 ),
        //             ),
        //         ),
        //     ),
        // );
    }
}
