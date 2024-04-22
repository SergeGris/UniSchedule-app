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
                padding: const EdgeInsets.symmetric(
                    vertical: 1,
                    horizontal: 4
                ),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                    number < strings.length ? strings[number - 1] + ' пара' : '$number пара',
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

        List<Widget> classTeachersAndRooms(List<TeacherAndRoom?> teachersAndRooms) {
            final tr = teachersAndRooms.nonNulls.where((e) => (e.room != null || e.teacher != null));

            return tr.map(
                (tr) => Text(
                    [ tr.room, tr.teacher ].nonNulls.join(' — '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                    ),
                )
            )
            .cast<Widget>()
            .toList();
        }

        Widget classNote(String note) => Text(
            note,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
            )
        );

        // Use it to make all columns with time same width
        double textWidth(String text, TextStyle style) {
            final TextPainter textPainter = TextPainter(
                text: TextSpan(text: text, style: style),
                maxLines: 1,
                textDirection: TextDirection.ltr
            )
            ..layout(minWidth: 0, maxWidth: double.infinity);
            return textPainter.width;
        }

        // TODO Remove
        double max(double a, double b) {
            return a >= b ? a : b;
        }

        double getTimeWidth() => textWidth(
            const TimeOfDay(hour: 0, minute: 0).format(context),
            TextStyle(
                fontSize: Theme.of(context).textTheme.titleMedium?.fontSize ?? 16.0,
                color: Theme.of(context).colorScheme.primary,
            )
        ) * max(1.0, getScale(context, Theme.of(context).textTheme.titleMedium?.fontSize ?? 16.0)) + 8; // FUCK TODO fucking magic constant. Pay attention to <https://stackoverflow.com/a/62536187>

        return Card(
            color: color,
            elevation: 0, // We do many magic with colors and theirs opacity, so set elevation to zero to get more control on color.
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
            child: Row(
                children: <Widget>[
                    const SizedBox(width: 12),

                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            const SizedBox(height: 12),

                            Container(
                                alignment: Alignment.center,
                                width: getTimeWidth(),
                                child: Text(
                                    begin,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                    ),
                                ),
                            ),

                            Container(
                                alignment: Alignment.center,
                                width: getTimeWidth(),
                                child: Text(
                                    end,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.secondary,
                                    ),
                                ),
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
                            ? <Widget>[
                                classNumber(number),
                                className('Окно'),
                            ]
                            : <Widget>[
                                const SizedBox(height: 8),

                                Row(
                                    children: <Widget>[
                                        classNumber(number),

                                        if (type != null)
                                        ...[
                                            const Spacer(),

                                            Icon(
                                                Icons.circle,
                                                color: type!.color,
                                                size: MediaQuery.textScalerOf(context).scale(Theme.of(context).textTheme.bodySmall?.fontSize ?? 14.0)
                                            ),

                                            const SizedBox(width: 3),

                                            Text(
                                                type!.name,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Theme.of(context).colorScheme.secondary,
                                                )
                                            ),
                                        ],
                                    ],
                                ),

                                className(name!),

                                if (teachersAndRooms.nonNulls.isNotEmpty)
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: classTeachersAndRooms(teachersAndRooms),
                                ),

                                if (building != null)
                                Text(
                                    building!,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.secondary,
                                    )
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
    const ClassCard({super.key,
                     required this.classes,
                     required this.index,
                     required this.showProgress,
                     required this.number,
                     required this.horizontalMargin,
                     required this.borderRadius});

    final List<Class> classes;
    final int index;
    final int number;
    final bool showProgress;
    final double horizontalMargin;
    final double borderRadius;

    @override
    Widget build(BuildContext context) {
        final class0 = classes[index];
        final bool haveClass = class0.name != null;
        final begin = haveClass ? class0.start.format(context) : (index > 0                  ? classes[index - 1].end.format(context)   : null);
        final end   = haveClass ? class0.end.format(context)   : (index + 1 < classes.length ? classes[index + 1].start.format(context) : null);
        final cardColor = primaryContainerColor(context);

        final card = ClassCardTile(
            haveClass: haveClass,
            color: showProgress ? Colors.transparent : cardColor,
            number: number,
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
                            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                            child: LinearProgressIndicator(
                                backgroundColor: cardColor,
                                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.15),
                                value: TimeOfDay.now().differenceInMinutes(class0.start) / class0.end.differenceInMinutes(class0.start),
                                borderRadius: BorderRadius.circular(borderRadius),
                            )
                        )
                    ),
                    card,
                ],
            );
        }
    }
}
