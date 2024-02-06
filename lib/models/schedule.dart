import 'package:flutter/material.dart';

DateTime? studiesDateFromJson(Map<String, dynamic>? json) {
    if (json == null || json.toString() == 'null') {
        return null;
    }

    return DateTime(json['y'], json['m'], json['d']);
}

class Schedule {
    Schedule(this.studiesBegin, this.studiesEnd, this.weeks);

    Schedule.fromJson(final Map<String, dynamic> json)
        : studiesBegin = studiesDateFromJson(json['studies.begin']),
          studiesEnd   = studiesDateFromJson(json['studies.end']),
          weeks = json['schedule'].map((e) => Week.fromJson(e)).cast<Week>().toList();

    final DateTime? studiesBegin;
    final DateTime? studiesEnd;
    final List<Week> weeks;
}

class Week {
    Week.fromJson(final List json)
        : days = [...json.map((e) => Day.fromJson(json.indexOf(e) + 1, e))]; // TODO USE MAPINDEXED

    final List<Day> days;
}

class Day {
    Day(this.dayNum, this.classes);

    Day.fromJson(this.dayNum, final List json)
        : classes = [...json.map((e) => Class.fromJson(e))];

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

    String? teacher;
    String? room;
}

class ClassType {
    const ClassType({required this.name, required this.color});
    final String name;
    final Color color;
}

ClassType? classTypeFromString(String type) {
    final typeTranslateMap = const {
        'лекция':       'lecture',
        'семинар':      'seminar',
        'практикум':    'practicum',
        'лабораторная': 'lab',
        'консультация': 'consultation',

    };

    final typesMap = const {
        'lecture':      ClassType(name: 'Лекция',       color: Colors.green),
        'seminar':      ClassType(name: 'Семинар',      color: Colors.yellow),
        'practicum':    ClassType(name: 'Практикум',    color: Colors.red),
        'lab':          ClassType(name: 'Лабораторная', color: Colors.blue),
        'consultation': ClassType(name: 'Консультация', color: Colors.purple),
    };

    String t = typeTranslateMap.keys.contains(type.toLowerCase())
        ? typeTranslateMap[type.toLowerCase()]! : type;

    return (typesMap.keys.contains(t)) ? typesMap[t] : (t != null ? ClassType(name: t, color: Colors.pink) : null);
}

class Class {
    Class({
            required this.start,
            required this.end,
            this.name = null,
            this.teachersAndRooms = const [null],
            this.building = null,
            this.type = null,
            this.note = null,
    });

    Class.fromJson(final Map<String, dynamic> json)
        : start = TimeOfDay(
            hour:   int.parse(json['begin'].toString().split(':')[0]),
            minute: int.parse(json['begin'].toString().split(':')[1])
        ),
        end = TimeOfDay(
            hour:   int.parse(json['end'].toString().split(':')[0]),
            minute: int.parse(json['end'].toString().split(':')[1])
        ),
        name = json['name'] != 'null' ? json['name'] : null,
        teachersAndRooms = [
            ...((json['teachersAndRooms'] ?? [ null ])
                .map(
                    (tr) {
                        if (tr != null) {
                            String t = tr[0].toString();
                            String r = tr[1].toString();

                            return TeacherAndRoom(
                                teacher: t == 'null' || t == '' ? null : t,
                                room:    r == 'null' || r == '' ? null : r
                            );
                        }
                    }
                )
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
}
