
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

import '../utils.dart';

DateTime? studiesDateFromJson(Map<String, dynamic>? json) {
    if (json == null || json.toString() == 'null') {
        return null;
    }

    return DateTime(json['y'] as int, json['m'] as int, json['d'] as int);
}

class Schedule {
    Schedule(this.studiesBegin, this.studiesEnd, this.weeks);

    Schedule.fromJson(final Map<String, dynamic> json)
        : studiesBegin = studiesDateFromJson(json['studies.begin']),
          studiesEnd   = studiesDateFromJson(json['studies.end']),
          weeks        = json['schedule'].map((e) => Week.fromJson(e)).cast<Week>().toList();

    final DateTime? studiesBegin;
    final DateTime? studiesEnd;
    final List<Week> weeks;
}

class Week {
    Week.fromJson(final List json)
        : days = [...json.mapIndexed((e, i) => Day.fromJson(i + 1, e)).cast<Day>()]; // TODO USE MAPINDEXED

    final List<Day> days;
}

class Day {
    Day(this.dayNum, this.classes);

    Day.fromJson(this.dayNum, final List json)
        : classes = [...json.mapIndexed((e, i) => Class.fromJson(e, i + 1)).cast<Class>()];

    final int dayNum;
    final List<Class> classes;

    String get dayName => [
        'Понедельник',
        'Вторник',
        'Среда',
        'Четверг',
        'Пятница',
        'Суббота',
        'Воскресенье',
    ][dayNum - 1];

    String get dayAbbr => [
        'Пн',
        'Вт',
        'Ср',
        'Чт',
        'Пт',
        'Сб',
        'Вс',
    ][dayNum - 1];
}

//TODO rename?
class TeacherAndRoom {
    TeacherAndRoom({required this.teacher, required this.room});
    final String? teacher;
    final String? room;
}

class ClassType {
    const ClassType({required this.name, required this.color});
    final String name;
    final Color color;
}

ClassType? classTypeFromString(String type) {
    const typeTranslateMap = {
        'лекция':       'lecture',
        'семинар':      'seminar',
        'практикум':    'practicum',
        'лабораторная': 'lab',
        'консультация': 'consultation',
    };

    const typesMap = {
        'lecture':      ClassType(name: 'Лекция',       color: Colors.green),
        'seminar':      ClassType(name: 'Семинар',      color: Colors.yellow),
        'practicum':    ClassType(name: 'Практикум',    color: Colors.red),
        'lab':          ClassType(name: 'Лабораторная', color: Colors.blue),
        'consultation': ClassType(name: 'Консультация', color: Colors.purple),
    };

    final t = typeTranslateMap.keys.contains(type.toLowerCase())
        ? typeTranslateMap[type.toLowerCase()]! : type;

    return (typesMap.keys.contains(t))
        ? typesMap[t]
        : (t != '' ? ClassType(name: t, color: Colors.pink) : null);
}

class Class {
    Class({
            required this.start,
            required this.end,
            this.name,
            this.teachersAndRooms = const [null],
            this.building,
            this.type,
            this.note,
            required this.number,
    });

    Class.fromJson(final Map<String, dynamic> json, this.number)
        : start = TimeOfDay(
            hour:   int.parse(json['begin'].toString().split(':')[0]),
            minute: int.parse(json['begin'].toString().split(':')[1])
        ),
        end = TimeOfDay(
            hour:   int.parse(json['end'].toString().split(':')[0]),
            minute: int.parse(json['end'].toString().split(':')[1])
        ),
        name = json['name'],
        teachersAndRooms = [
            ...(json['teachersAndRooms'] ?? [ null ])
                .map(
                    (tr) {
                        if (tr != null) {
                            // TODO HANDLE Only entry
                            final t = tr[0].toString();
                            final r = tr[1].toString();

                            return TeacherAndRoom(
                                teacher: t == 'null' || t == '' ? null : t,
                                room:    r == 'null' || r == '' ? null : r
                            );
                        }
                    }
                )
        ],
        building = json['building'],
        type     = json['type'] != null ? classTypeFromString(json['type']) : null,
        note     = json['note'];

    final TimeOfDay start;
    final TimeOfDay end;
    final String? name;
    final List<TeacherAndRoom?> teachersAndRooms;
    final String? building;
    final ClassType? type;
    final String? note;
    final int number;
}
