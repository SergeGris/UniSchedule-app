
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//TODO import 'package:flutter_rustore_update/const.dart';
//TODO import 'package:flutter_rustore_update/flutter_rustore_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../pages/home.dart';
import '../pages/schedule.dart';
import '../pages/services.dart';

import '../configuration.dart';
import '../provider.dart';
import '../scheduleselector.dart';
import '../utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
    const HomeScreen({super.key});

    @override
    ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class WeekNumberWidget extends ConsumerWidget {
    WeekNumberWidget({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final weekIndex = ref.watch(scheduleProvider).unwrapPrevious().when<int?>(
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
            style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium?.fontSize)
        );
    }
}

enum UniSchedulePages {
    main,
    schedule,
    services,
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
    int  _selPage     = UniSchedulePages.main.index;
    bool showNextWeek = DateTime.now().weekday == DateTime.sunday;
    bool warningShown = false;

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
    }

    @override
    Widget build(BuildContext context) {
        if (!warningShown && UniScheduleConfiguration.manifestUpdated) {
            warningShown = true;

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

        // Set to default if user toggled a page.
        if (_selPage != UniSchedulePages.schedule.index) {
            showNextWeek = DateTime.now().weekday == DateTime.sunday;
        }

        return Scaffold(
            appBar: AppBar(
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        Text(dateTitle()),
                        WeekNumberWidget(),
                    ],
                ),

                shadowColor: Theme.of(context).shadowColor,

                bottom: const Tab(child: ScheduleSelectorButton()) // TODO Tab?
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

            floatingActionButton: (_selPage != UniSchedulePages.schedule.index)
            ? null
            : ElevatedButton(
                onPressed: () => setState(() => showNextWeek ^= true),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        Icon(
                            showNextWeek ? Icons.arrow_back : Icons.arrow_forward,
                            size: Theme.of(context).textTheme.titleLarge?.fontSize
                        ),

                        const SizedBox(width: 8),

                        Text(
                            showNextWeek ? 'К текущей неделе' : 'К следующей неделе',
                            style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium?.fontSize)
                        ),
                    ],
                ),
            ),
        );
    }

    ///////// TODO!!!!!
    // vvv RUSTORE IN APP UPDATE CODE
    // int availableVersionCode = 0;
    // int installStatus = 0;
    // String packageName = "";
    // int updateAvailability = 0;
    // String infoErr = "";
    // int bytesDownloaded = 0;
    // int totalBytesToDownload = 0;
    // int installErrorCode = 0;
    // String completeErr = "";
    // int installCode = 0;
    // String updateError = "";
    // String silentError = "";
    // String immediateError = "";

    // @override
    // void initState(){
    //     super.initState();

    //     info();

    //     Future(() async {
    //             showDialog(
    //                 context: context,
    //                 builder: (BuildContext context) => AlertDialog(
    //                     title: const Text('ТЕСТ!'),
    //                     content: Text('${availableVersionCode}, ${installStatus}, ${packageName}, ${updateAvailability}, ${infoErr}, ${bytesDownloaded}, ${totalBytesToDownload}, ${installErrorCode}, ${completeErr}, ${installCode}, ${updateError}, ${silentError}, ${immediateError}'),
    //                     actions: <Widget>[
    //                         TextButton(
    //                             onPressed: () { Navigator.pop(context); },
    //                             child: const Text('Понятно'),
    //                         ),
    //                     ],
    //                 ),
    //             );
    //         }
    //     );

    //     if (infoErr != '') {
    //         Future(() async {
    //                 showDialog(
    //                     context: context,
    //                     builder: (BuildContext context) => AlertDialog(
    //                         title: const Text('Возникла ошибка!'),
    //                         content: const Text('Для упрощения обновления приложения установите последнюю версию RuStore'),
    //                         actions: <Widget>[
    //                             TextButton(
    //                                 onPressed: () { update(); Navigator.pop(context); },
    //                                 child: const Text('Понятно'),
    //                             ),
    //                         ],
    //                     ),
    //                 );
    //             }
    //         );
    //     }

    //     if (updateAvailability == UPDATE_AILABILITY_AVAILABLE) {
    //         Future(() async {
    //                 showDialog(
    //                     context: context,
    //                     builder: (BuildContext context) => AlertDialog(
    //                         title: const Text('Доступна новая версия!'),
    //                         content: const Text('Установить?'),
    //                         actions: <Widget>[
    //                             TextButton(
    //                                 onPressed: () { update(); Navigator.pop(context); },
    //                                 child: const Text('Да'),
    //                             ),
    //                             TextButton(
    //                                 onPressed: () => Navigator.pop(context),
    //                                 child: const Text('Нет'),
    //                             ),
    //                         ],
    //                     ),
    //                 );
    //             }
    //         );
    //     }
    // }

    // void info(){
    //     RustoreUpdateClient.info().then((info) {
    //             setState(() {
    //                     availableVersionCode = info.availableVersionCode;
    //                     installStatus = info.installStatus;
    //                     packageName = info.packageName;
    //                     updateAvailability = info.updateAvailability;
    //             });
    //     }).catchError((err) {
    //             setState(() {
    //                     infoErr = err.message;
    //             });
    //     });
    // }

    // void update(){
    //     RustoreUpdateClient.info().then((info) {
    //             setState(() {
    //                     availableVersionCode = info.availableVersionCode;
    //                     installStatus = info.installStatus;
    //                     packageName = info.packageName;
    //                     updateAvailability = info.updateAvailability;
    //             });
    //             if (info.updateAvailability == UPDATE_AILABILITY_AVAILABLE) {
    //                 RustoreUpdateClient.listener((value) {
    //                         setState(() {
    //                                 installStatus = value.installStatus;
    //                                 bytesDownloaded = value.bytesDownloaded;
    //                                 totalBytesToDownload = value.totalBytesToDownload;
    //                                 installErrorCode = value.installErrorCode;
    //                         });
    //                         if (value.installStatus == INSTALL_STATUS_DOWNLOADED) {
    //                             RustoreUpdateClient.complete().catchError((err) {
    //                                     setState(() {
    //                                             completeErr = err.message;
    //                                     });
    //                             });
    //                         }
    //                 });
    //                 RustoreUpdateClient.download().then((value) {
    //                         setState(() {
    //                                 installCode = value.code;
    //                         });
    //                         if (value.code == ACTIVITY_RESULT_CANCELED) {
    //                         }
    //                 }).catchError((err) {
    //                         setState(() {
    //                                 updateError = err.message;
    //                         });
    //                 });
    //             }
    //     }).catchError((err) {
    //             setState(() {
    //                     infoErr = err.message;
    //             });
    //     });
    // }

    // void immediate(){
    //     RustoreUpdateClient.info().then((info) {
    //             setState(() {
    //                     availableVersionCode = info.availableVersionCode;
    //                     installStatus = info.installStatus;
    //                     packageName = info.packageName;
    //                     updateAvailability = info.updateAvailability;
    //             });
    //             if (info.updateAvailability == UPDATE_AILABILITY_AVAILABLE) {
    //                 RustoreUpdateClient.listener((value) {
    //                         setState(() {
    //                                 installStatus = value.installStatus;
    //                                 bytesDownloaded = value.bytesDownloaded;
    //                                 totalBytesToDownload = value.totalBytesToDownload;
    //                                 installErrorCode = value.installErrorCode;
    //                         });
    //                         if (value.installStatus == INSTALL_STATUS_DOWNLOADED) {
    //                             RustoreUpdateClient.complete().catchError((err) {
    //                                     setState(() {
    //                                             completeErr = err.message;
    //                                     });
    //                             });
    //                         }
    //                 });
    //                 RustoreUpdateClient.immediate().then((value) {
    //                         setState(() {
    //                                 installCode = value.code;
    //                         });
    //                 }).catchError((err) {
    //                         setState(() {
    //                                 immediateError = err.message;
    //                         });
    //                 });
    //             }
    //     }).catchError((err) {
    //             setState(() {
    //                     infoErr = err.message;
    //             });
    //     });
    // }

    // void silent(){
    //     RustoreUpdateClient.info().then((info) {
    //             setState(() {
    //                     availableVersionCode = info.availableVersionCode;
    //                     installStatus = info.installStatus;
    //                     packageName = info.packageName;
    //                     updateAvailability = info.updateAvailability;
    //             });
    //             if (info.updateAvailability == UPDATE_AILABILITY_AVAILABLE) {
    //                 RustoreUpdateClient.listener((value) {
    //                         setState(() {
    //                                 installStatus = value.installStatus;
    //                                 bytesDownloaded = value.bytesDownloaded;
    //                                 totalBytesToDownload = value.totalBytesToDownload;
    //                                 installErrorCode = value.installErrorCode;
    //                         });
    //                         if (value.installStatus == INSTALL_STATUS_DOWNLOADED) {
    //                             RustoreUpdateClient.complete().catchError((err) {
    //                                     setState(() {
    //                                             completeErr = err.message;
    //                                     });
    //                             });
    //                         }
    //                 });
    //                 RustoreUpdateClient.silent().then((value) {
    //                         setState(() {
    //                                 installCode = value.code;
    //                         });
    //                 }).catchError((err) {
    //                         setState(() {
    //                                 silentError = err.message;
    //                         });
    //                 });
    //             }
    //     }).catchError((err) {
    //             setState(() {
    //                     infoErr = err.message;
    //             });
    //     });
    // }

    // ^^^ RUSTORE IN APP UPDATE CODE
}
