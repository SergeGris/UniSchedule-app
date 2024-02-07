import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './provider.dart';
import './models/schedule.dart';
import './utils.dart';
import './globalkeys.dart';

class ScheduleLoader extends ConsumerWidget {
    ScheduleLoader(this.child);

    final Widget Function(Schedule) child;
    late Schedule? fallback = null;

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final AsyncValue<Schedule> schedule = ref.watch(scheduleProvider).unwrapPrevious();

        return RefreshIndicator(
            onRefresh: () => refreshSchedule(ref),
            child: schedule.when(
                loading: () {
                    return getLoadingIndicator(() => refreshSchedule(ref));
                },
                error: (e, st) {
                    GlobalKeys.showWarningBanner('Не удалось загрузить расписание');

                    final prefs = ref.watch(settingsProvider).value!;

                    String? fallbackSchedule = prefs.getString('fallbackSchedule');
                    String? groupId = prefs.getString('groupId');

                    if (groupId != null && fallbackSchedule != null) {
                        try {
                            fallback = Schedule.fromJson(jsonDecode(fallbackSchedule) as Map<String, dynamic>);
                        } catch (e) {
                            return getErrorContainer('Не удалось загрузить расписание');
                        };
                        return child(fallback!);
                    } else {
                        return getErrorContainer('Не удалось загрузить расписание');
                    }
                },
                data: (value) {
                    fallback = value;
                    return child(value);
                }
            )
        );
    }
}