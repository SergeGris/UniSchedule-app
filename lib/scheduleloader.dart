
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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './provider.dart';
import './models/schedule.dart';
import './utils.dart';

class ScheduleLoader extends ConsumerWidget {
    const ScheduleLoader(this.builder, {super.key});

    final Widget Function(Schedule) builder;

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        return RefreshIndicator(
            onRefresh: () async => refreshSchedule(ref),
            child: ref.watch(scheduleProvider).when(
                loading: ()           => getLoadingIndicator(() async => refreshSchedule(ref)),
                error: (error, stack) => getErrorContainer('Не удалось отобразить расписание'),
                data: builder,
            )
        );
    }
}
