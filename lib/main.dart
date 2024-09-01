
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
import './provider.dart';
import './scheduleselector.dart';
import './screens/home.dart';
import './utils.dart';

class UniScheduleLogo extends StatelessWidget {
    const UniScheduleLogo({super.key});

    @override
    Widget build(BuildContext context) => Scaffold(
        body: Center(
            child: SizedBox.square(
                dimension: MediaQuery.of(context).size.shortestSide * 0.5,
                child: Image.asset('assets/images/icon.png'),
            ),
        ),
    );
}

void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Webview works only on this platforms
    if (OS.isAndroid || OS.isIOS) {
        // Plugin must be initialized before using
        await FlutterDownloader.initialize(
            debug: false,   // Optional: set to false to disable printing logs to console (default: true)
            ignoreSsl: true // Option: set to false to disable working with http links (default: false)
        );
    }

    runApp(const ProviderScope(child: UniScheduleApp()));
}

class UniScheduleApp extends ConsumerWidget {
    const UniScheduleApp({super.key});

    @override
    Widget build(final BuildContext context, final WidgetRef ref) => ref.watch(settingsProvider).when(
        loading: () => const MaterialApp(home: UniScheduleLogo()),

        error: (error, stack) => MaterialApp(
            home: Scaffold(
                body: Center(
                    child: Text(
                        'Не удалось загрузить внутреннюю базу данных: $error',
                        style: Theme.of(context).textTheme.titleLarge
                    ),
                ),
            ),
        ),

        data: (prefs) {
            bool firstRun = (prefs.getString('initialized') == null);

            // Check that all preferences available.
            if (!firstRun) {
                if (prefs.getString('universityId') == null
                 || prefs.getString('facultyId')    == null
                 || prefs.getString('yearId')       == null
                 || prefs.getString('groupId')      == null) {
                    prefs.clear();
                    firstRun = true;
                }
            }

            final theme = ColorTheme.fromString(prefs.getString('theme'));
            final themeMode = prefs.getString('custom.theme.mode');

            CustomColorTheme.colorSchemeSeed = Color(prefs.getInt('custom.color.scheme.seed') ?? theme.colorSchemeSeed.value);

            CustomColorTheme.themeMode = themeMode != null
            ? (themeMode == 'light' ? ThemeMode.light : ThemeMode.dark)
            : theme.themeMode;

            ThemeData getThemeData(final Brightness brightness) {
                final colorScheme = ColorScheme.fromSeed(
                    seedColor: theme.colorSchemeSeed,
                    brightness: brightness,
                );

                return ThemeData(
                    useMaterial3: true,
                    colorScheme: brightness != Brightness.dark
                    ? colorScheme
                    : colorScheme.copyWith(
                        primaryContainer: Color.lerp(
                            colorScheme.primaryContainer,
                            colorScheme.background,
                            3 / 5,
                        ),
                    ),

                    tabBarTheme: Theme.of(context).tabBarTheme.copyWith(
                        indicatorSize: TabBarIndicatorSize.tab,
                    ),

                    appBarTheme: AppBarTheme(
                        // Align title to left in iOS.
                        centerTitle: false,
                        shadowColor: Theme.of(context).shadowColor
                    ),

                    dropdownMenuTheme: DropdownMenuThemeData(
				        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                            isDense: true,
                            isCollapsed: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                            contentPadding: const EdgeInsets.all(16.0),
                            alignLabelWithHint: false,
                        ),

                        menuStyle: MenuStyle(
                            shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0)
                                ),
                            ),

                            shadowColor: MaterialStatePropertyAll<Color>(Theme.of(context).shadowColor),
                            padding: const MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.zero),
                            visualDensity: VisualDensity.comfortable,
                        ),
                    ),
                );
            }

            return MaterialApp(
                title: 'UniSchedule',
                debugShowCheckedModeBanner: false,
                scaffoldMessengerKey: GlobalKeys.globalScaffoldKey,
                themeMode: theme.themeMode,

                theme: getThemeData(Brightness.light),
                darkTheme: getThemeData(Brightness.dark),

                home: ref.watch(uniScheduleConfigurationProvider).when(
                    loading: () => const UniScheduleLogo(),

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
                                            child: Text('$error'),
                                        ),
                                    ],
                                ),
                            ],
                        ),
                    ),

                    data: (_) => firstRun
                        ? const ScheduleSelector(firstRun: true)
                        : OS.isWeb
                            ? const SelectionArea(child: HomeScreen())
                            : const HomeScreen(),
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
    );
}
