
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
import 'package:package_info_plus/package_info_plus.dart';

import '../pages/home.dart';
import '../pages/schedule.dart';
import '../pages/services.dart';

import '../configuration.dart';
import '../provider.dart';
import '../scheduleloader.dart';
import '../scheduleselector.dart';
import '../utils.dart';

// TODO
import '../pages/creator.dart';

// Возвращает строку в формате "День-недели, число месяц"
class DateTitle extends StatelessWidget {
    const DateTitle({super.key});

    @override
    Widget build(BuildContext context) {
        final date = DateTime.now();

        // Именительный падеж (кто?/что?)
        const weekdays = [
            'Понедельник',
            'Вторник',
            'Среда',
            'Четверг',
            'Пятница',
            'Суббота',
            'Воскресенье',
        ];

        // Винительный падеж (кого?/чего?)
        const months = [
            'января',
            'февраля',
            'марта',
            'апреля',
            'мая',
            'июня',
            'июля',
            'августа',
            'сентября',
            'октября',
            'ноября',
            'декабря',
        ];

        final weekday = weekdays[date.weekday - 1];
        final day     = date.day;
        final month   = months[date.month - 1];

        return Text(
            '$weekday, $day $month',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary
            ),
        );
    }
}

class WeekNumber extends ConsumerWidget {
    const WeekNumber({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final weekIndex = ref.watch(scheduleProvider).when<int?>(
            loading: ()             => null,
            error:   (error, stack) => null,
            data:    (value)        => getWeekIndex(DateTime.now(), value),
        );

        //if (weekIndex != null)
        //Text('Учебная неделя №${weekIndex + 1}', style: Theme.of(context).textTheme.titleMedium)
        //TODO!!! else
        //Text('Учёба ещё не началась', style: Theme.of(context).textTheme.titleMedium!)

        if (weekIndex == null) {
            return const SizedBox.shrink(); // Do nothing if we do not know the week
        }

        return Text(
            'Идёт ${weekIndex + 1} учебная неделя',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary
            ),
        );
    }
}

enum UniSchedulePages {
    main(Icons.home, 'Главная'),
    schedule(Icons.schedule, 'Расписание'),
    services(Icons.more_horiz, 'Сервисы');

    const UniSchedulePages(this.icon, this.label);
    final IconData icon;
    final String label;
}

class HomeScreen extends ConsumerStatefulWidget {
    const HomeScreen({super.key});

    @override
    ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
    // TODO: does not work properly good (on big scale factors title isn't fit. Returns height of appbar...).
    GlobalKey _titleKey = GlobalKey();
    double? _titleHeight;

    int  _selPage     = UniSchedulePages.main.index;
    bool showNextWeek = DateTime.now().weekday == DateTime.sunday;

    final pagesNavigation = const {
        UniSchedulePages.main:     NavigationDestination(icon: Icon(Icons.home),       label: 'Главная'),
        UniSchedulePages.schedule: NavigationDestination(icon: Icon(Icons.schedule),   label: 'Расписание'),
        UniSchedulePages.services: NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Сервисы'),
    };

    @override
    void initState() {
        super.initState();

        Future(
            () async {
                final packageInfo = await PackageInfo.fromPlatform();
                final version = Version.fromString(packageInfo.version);

                if (UniScheduleConfiguration.updateVariants.isNotEmpty
                 && (UniScheduleConfiguration.latestApplicationVersion?.greaterThan(version) ?? false)) {
                    await showDialog<void>(
                        context: context,
                        builder: (final context) => AlertDialog(
                            title: const Text('Доступно обновление!'),
                            content: const Text('Установить новую версию?'),
                            actions: <Widget>[
                                ...UniScheduleConfiguration.updateVariants.map(
                                    (e) => ElevatedButton(
                                        child: Text(e.label),
                                        onPressed: () => launchLink(context, e.link),
                                    ),
                                ),

                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Не сейчас'),
                                ),
                            ],
                        ),
                    );
                }
            }
        );

        if (UniScheduleConfiguration.manifestUpdated) {
            Future(
                () async => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                        title: const Text('Внимание!'),
                        content: const Text('Обновите приложение. Скоро ваше приложение перестанет поддерживать формат расписания'),
                        actions: <Widget>[
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Хорошо'),
                            ),
                        ],
                    ),
                ),
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        // Set to default if user toggled a page.
        if (_selPage != UniSchedulePages.schedule.index) {
            showNextWeek = DateTime.now().weekday == DateTime.sunday;
        }

        WidgetsBinding.instance.addPostFrameCallback(
            (_) {
                final RenderBox renderBox = _titleKey.currentContext?.findRenderObject() as RenderBox;
                // Get the height after layout
                setState(() => _titleHeight = renderBox.size.height);
            },
        );

        return Scaffold(
            appBar: AppBar(
                scrolledUnderElevation: 0,
                title: Column(
                    key: _titleKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        const DateTitle(),
                        const WeekNumber(),
                    ],
                ),

                // Make it enough sized to contain to lines of title.
                toolbarHeight: _titleHeight,

                // TODO: Something else, not tab?
                bottom: const Tab(child: ScheduleSelectorButton()),

                // actions: <Widget>[
                //     //TODO
                //     IconButton(
                //         icon: const Icon(Icons.edit),
                //         onPressed: () => AnimatedNavigator.push<void>(
                //             context,
                //             (context) => ScheduleLoader((schedule) => EditSchedulePage(schedule: schedule))
                //         ),
                //     ),
                // ],
            ),

            bottomNavigationBar: NavigationBar(
                destinations: UniSchedulePages.values.map(
                    (p) => NavigationDestination(icon: Icon(p.icon), label: p.label)
                ).toList(),
                selectedIndex: _selPage,
                onDestinationSelected: (index) => setState(() => _selPage = index),
            ),

            body: AnimatedSwitcher(
                duration: kAnimationDuration,
                reverseDuration: kAnimationDuration,
                transitionBuilder: (Widget child, Animation<double> animation) {
                    // Use a fade transition.
                    return FadeTransition(
                        opacity: animation,
                        child: child

                        // ScaleTransition(
                        //     scale: animation,
                        //     child: child,
                        // ),
                    );
                },
                child: <Widget Function()>[
                    // Keys needed to allow AnimatedSwitcher() know that widgets are different and enable animation between pages.
                    () => ScheduleLoader(key: const ValueKey(0), (schedule) => HomePage(schedule: schedule)),
                    () => ScheduleLoader(key: const ValueKey(1), (schedule) => SchedulePage(schedule: schedule, showNextWeek: showNextWeek)),
                    () => const ServicesPage(key: ValueKey(2)),
                ][_selPage](),
            ),

            // body: {
            //     UniSchedulePages.main:     () => ScheduleLoader((schedule) => HomePage(schedule: schedule)),
            //     UniSchedulePages.schedule: () => ScheduleLoader((schedule) => SchedulePage(schedule: schedule, showNextWeek: showNextWeek)),
            //     UniSchedulePages.services: () => const ServicesPage(),
            // }[UniSchedulePages.values[_selPage]]!(),

            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

            floatingActionButton: _selPage != UniSchedulePages.schedule.index
            ? null
            : ElevatedButton(
                onPressed: () => setState(() => showNextWeek = !showNextWeek),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        Icon(
                            showNextWeek ? Icons.arrow_back : Icons.arrow_forward,
                            size: MediaQuery.textScalerOf(context).scale(Theme.of(context).textTheme.titleLarge?.fontSize ?? 16.0),
                            color: Theme.of(context).colorScheme.primary
                        ),

                        const SizedBox(width: 8),

                        Text(
                            showNextWeek ? 'К текущей неделе' : 'К следующей неделе',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary
                            )
                        ),
                    ],
                ),
            ),
        );
    }
}
