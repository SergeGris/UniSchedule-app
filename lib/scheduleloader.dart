import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './provider.dart';
import './models/schedule.dart';
import './utils.dart';

class ScheduleLoader extends ConsumerWidget {
    const ScheduleLoader(this.child, {super.key});

    final Widget Function(Schedule) child;

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        return RefreshIndicator(
            onRefresh: () => refreshSchedule(ref),
            child: ref.watch(scheduleProvider).unwrapPrevious().when(
                loading: ()           => getLoadingIndicator(() => refreshSchedule(ref)),
                error: (error, stack) => getErrorContainer('Не удалось отобразить расписание'),
                data: (value)         => child(value),
            )
        );
    }
}
