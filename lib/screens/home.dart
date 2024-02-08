
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//TODO import 'package:flutter_rustore_update/const.dart';
//TODO import 'package:flutter_rustore_update/flutter_rustore_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../pages/home.dart';
import '../pages/schedule.dart';
//import '../pages/map.dart';
import '../pages/settings.dart';

import '../utils.dart';
import '../provider.dart';
import '../scheduleselector.dart';
import '../configuration.dart';

class HomeScreen extends ConsumerStatefulWidget {
    const HomeScreen({super.key});

    @override
    ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class UniSchedulePages {
    static const int main     = 0;
    static const int schedule = 1;
    static const int settings = 2;
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
    int _selPage = UniSchedulePages.main;
    bool showCurrentWeek = DateTime.now().weekday != DateTime.sunday;
    bool warningShown = false;

    @override
    Widget build(BuildContext context) {
        if (!warningShown && globalUniScheduleConfiguration.manifestUpdated) {
            warningShown = true;

            Future(() async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                            title: const Text('Внимание!'),
                            content: const Text('Обновите приложение. Скоро ваше приложение перестанет поддерживать формат расписания'),
                            actions: <Widget>[
                                TextButton(
                                    onPressed: () { Navigator.pop(context); },
                                    child: const Text('Хорошо'),
                                ),
                            ],
                        ),
                    );
                }
            );
        }

        // Set to default if user toggled a page.
        if (_selPage != UniSchedulePages.schedule) {
            showCurrentWeek = DateTime.now().weekday != DateTime.sunday;
        }

        var weekNumber = ref.watch(scheduleProvider).unwrapPrevious().when<int?>(
            loading: () => null,
            error: (e, st) => null,
            data: (value) => getWeekNumber(DateTime.now().add(const Duration(days: 1)), value),
        );

        return Scaffold(
            appBar: AppBar(
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(dateTitle(ref)),
                        if (weekNumber != null)
                        Text('Учебная неделя №${weekNumber + 1}', style: Theme.of(context).textTheme.titleMedium!)
                        //TODO!!! else
                        //Text('Учёба ещё не началась', style: Theme.of(context).textTheme.titleMedium!)
                    ]
                ),
                // [
                //     Text("Расписание на сегодня"),
                //     Text("Текущее расписание"),
                //     // Text("Карта"), // TBI
                //     Text("Настройки"),
                // ][_selPage],
                shadowColor: Theme.of(context).shadowColor,

                bottom: const Tab(
                    child: Padding(
                        padding: EdgeInsets.all(3),
                        child: OverflowBar(
                            overflowAlignment: OverflowBarAlignment.center,
                            alignment: MainAxisAlignment.center,
                            overflowSpacing: 3.0,
                            children: <Widget>[
                                ScheduleSelectorButton(),
                            ],
                        ),
                    ),
                ),
            ),

            bottomNavigationBar: NavigationBar(
                destinations: const [
                    NavigationDestination(icon: Icon(Icons.home),     label: 'Главная'),
                    NavigationDestination(icon: Icon(Icons.schedule), label: 'Расписание'),
                    // NavigationDestination(icon: Icon(Icons.map), label: 'Карта'), // TBI
                    NavigationDestination(icon: Icon(Icons.settings), label: 'Настройки')
                ],
                selectedIndex: _selPage,
                onDestinationSelected: (index) {
                    setState(
                        () {
                            _selPage = index;
                        }
                    );
                },
            ),
            body: <Widget>[
                const HomePage(),
                SchedulePage(showCurrentWeek: showCurrentWeek),
                // MapPage(), // TBI
                const SettingsPage(),
            ][_selPage],

            floatingActionButton: (_selPage != UniSchedulePages.schedule)
            ? null
            : ElevatedButton(
                onPressed: () {
                    setState(
                        () {
                            showCurrentWeek ^= true;
                        }
                    );
                },
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Icon(
                            showCurrentWeek ? Icons.arrow_forward_sharp : Icons.arrow_back_sharp,
                            size: Theme.of(context).textTheme.titleMedium!.fontSize
                        ),

                        const SizedBox(width: 8),

                        Text(
                            showCurrentWeek ? 'К следующей неделе' : 'К текущей неделе',
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: Theme.of(context).colorScheme.primary)
                        ),
                    ],
                ),
            ),
        );
    }

    bool compareVersions(List<int> first, List<int> second, bool comparator(int a, int b)) {
        final length = first.length <= second.length ? first.length : second.length;

        for (int i = 0; i < length; i++) {
            if (first[i] != second[i]) {
                return comparator(first[i], second[i]);
            }
        }

        return false;
    }

    @override
    void initState() {
        super.initState();

        Future(() async {
                PackageInfo packageInfo = await PackageInfo.fromPlatform();
                List<int> version = packageInfo.version.split('.').map((v) => int.parse(v)).toList();

                if (globalUniScheduleConfiguration.updateVariants.isNotEmpty
                 && globalUniScheduleConfiguration.latestApplicationVersion != null
                 && compareVersions(version, globalUniScheduleConfiguration.latestApplicationVersion!, (a, b) => (a < b))) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                            title: const Text('Доступно обновление!'),
                            content: const Text('Установить новую версию?'),
                            actions: <Widget>[
                                ...globalUniScheduleConfiguration.updateVariants.map(
                                    (e) => ElevatedButton(
                                        child: Text(e.label),
                                        onPressed: () => launchUrl(context, e.link),
                                    ),
                                ),

                                TextButton(
                                    onPressed: () { Navigator.pop(context); },
                                    child: const Text('Не сейчас'),
                                ),
                            ],
                        ),
                    );
                }
            }
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
