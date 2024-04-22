
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../pages/home.dart';
import '../pages/schedule.dart';
import '../pages/services.dart';

import '../configuration.dart';
import '../provider.dart';
import '../scheduleselector.dart';
import '../utils.dart';
import '../widgets/filledbutton.dart';

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
        final day = date.day;
        final month = months[date.month - 1];

        return Text('$weekday, $day $month', style: Theme.of(context).textTheme.titleLarge);
    }
}

class WeekNumber extends ConsumerWidget {
    const WeekNumber({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final weekIndex = ref.watch(scheduleProvider).when<int?>(
            loading: ()      => null,
            error:   (e, st) => null,
            data:    (value) => getWeekIndex(DateTime.now(), value),
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
            style: Theme.of(context).textTheme.titleMedium
        );
    }
}

enum UniSchedulePages {
    main,
    schedule,
    services,
}

class HomeScreen extends ConsumerStatefulWidget {
    const HomeScreen({super.key});

    @override
    ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
                    await showDialog(
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
                () async => showDialog(
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

        return Scaffold(
            appBar: AppBar(
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        DateTitle(),
                        WeekNumber(),
                    ],
                ),

                shadowColor: Theme.of(context).shadowColor,

                // bottom: PreferredSize(
                //     child: ScheduleSelectorButton(),
                //     preferredSize: Size.fromHeight(20.0 * getScale(context, Theme.of(context).textTheme.titleMedium?.fontSize ?? 16.0))
                // ),

                bottom: const Tab( // TODO: Something else, not tab?
                    //height: 30 * getScale(context, Theme.of(context).textTheme.titleMedium?.fontSize ?? 16.0),
                    child: ScheduleSelectorButton()
                )
            ),

            bottomNavigationBar: NavigationBar(
                destinations: pagesNavigation.values.toList(),
                selectedIndex: _selPage,
                onDestinationSelected: (index) => setState(() => _selPage = index)
            ),

            body: {
                UniSchedulePages.main:     () => const HomePage(),
                UniSchedulePages.schedule: () => SchedulePage(showNextWeek: showNextWeek),
                UniSchedulePages.services: () => const ServicesPage(),
            }[UniSchedulePages.values[_selPage]]!(),

            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

            floatingActionButton: (_selPage != UniSchedulePages.schedule.index)
            ? null
            : ElevatedButton(
                onPressed: () => setState(() => showNextWeek ^= true),
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
