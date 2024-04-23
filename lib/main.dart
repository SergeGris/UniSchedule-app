
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
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './globalkeys.dart';
import './pages/webview/util.dart';
import './provider.dart';
import './scheduleselector.dart';
import './screens/home.dart';
import './utils.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Webview works only on this platforms
    if (Util.isAndroid() || Util.isIOS()) {
        // Plugin must be initialized before using
        await FlutterDownloader.initialize(
            debug: false,   // optional: set to false to disable printing logs to console (default: true)
            ignoreSsl: true // option: set to false to disable working with http links (default: false)
        );
    }

    runApp(const ProviderScope(child: UniScheduleApp()));
}

class UniScheduleApp extends ConsumerWidget {
    const UniScheduleApp({super.key});

    @override
    Widget build(final BuildContext context, final WidgetRef ref) {
        final prefs = ref.watch(settingsProvider).value;
        bool firstRun = (prefs?.getString('initialized') == null);

        // Check that all preferences available.
        if (!firstRun) {
            if (prefs?.getString('universityId') == null
             || prefs?.getString('facultyId')    == null
             || prefs?.getString('yearId')       == null
             || prefs?.getString('groupId')      == null) {
                prefs?.clear();
                firstRun = true;
            }
        }

        ref.watch(themeProvider);
        final theme = (uniScheduleThemes[prefs?.getString('theme')] ?? () => uniScheduleThemeSystem)();
        final themeMode = prefs?.getString('custom.theme.mode');

        uniScheduleThemeCustom.colorSchemeSeed = Color(prefs?.getInt('custom.color.scheme.seed') ?? Colors.indigoAccent.value);
        uniScheduleThemeCustom.themeMode = (themeMode != null)
            ? (themeMode == 'light' ? ThemeMode.light : ThemeMode.dark)
            : theme.themeMode;

        ThemeData getThemeData(final Brightness brightness) => ThemeData(
            useMaterial3: true,
            brightness: brightness,
            colorSchemeSeed: theme.colorSchemeSeed,

            tabBarTheme: Theme.of(context).tabBarTheme.copyWith(
                indicatorSize: TabBarIndicatorSize.tab
            ),

            dropdownMenuTheme: DropdownMenuThemeData(
				inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.all(8.0),
                ),

                menuStyle: MenuStyle(
                    shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)
                        )
                    ),
                ),
            ),
        );

        debugPrint('h: ${MediaQuery.of(context).size.height}\nw: ${MediaQuery.of(context).size.width}');

        //TODO
        ref.read(scheduleProvider);//TODO.init();

        return MaterialApp(
            title: 'UniSchedule',
            // TODO debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: GlobalKeys.globalScaffoldKey,
            themeMode: theme.themeMode,

            theme: getThemeData(Brightness.light),
            darkTheme: getThemeData(Brightness.dark),

            home: ref.watch(uniScheduleConfigurationProvider).when(
                loading: () => Scaffold(
                    body: Center(
                        child: SizedBox(
                            height: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.75,
                            width: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.75 ,
                            child: Image.asset('assets/images/icon.png') //getLoadingIndicator(() => Future.value())
                        ),
                    ),
                ),

                error: (error, stack) => Scaffold(
                    body: ListView(
                        children: <Widget>[
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                    const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 60,
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Text('${error}'),
                                    ),
                                ],
                            ),
                        ],
                    ),
                ),

                data: (_) {
                    return firstRun ? const ScheduleSelector(firstRun: true) : const HomeScreen();
                }
            ),

            //// If you want to test scaled version on app on computer, uncomment this code below
            // builder: (context, child) {
            //     final mediaQueryData = MediaQuery.of(context);
            //     final scale = 2.0; // mediaQueryData.textScaleFactor.clamp(1.0, 1.3);
            //     return MediaQuery(
            //         child: child!,
            //         data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
            //     );
            // },
        );
    }
}
