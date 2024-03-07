import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './globalkeys.dart';
import './configuration.dart';
import './provider.dart';
import './scheduleselector.dart';
import './screens/home.dart';
import './utils.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const ProviderScope(child: UniScheduleApp()));
}

class UniScheduleApp extends ConsumerWidget {
    const UniScheduleApp({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final prefs = ref.watch(settingsProvider).value;
        final theme = uniScheduleThemes[prefs?.getString('theme') ?? 'system']!;
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

        Widget preloadConfiguration(Widget callback()) {
            Widget wrapper(List<Widget> callback()) {
                return Scaffold(
                    body: ListView(
                        children: [
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: callback(),
                            )
                        ]
                    )
                );
            }

            final configuration = ref.watch(uniScheduleConfigurationProvider);

            return configuration.when(
                loading: () => Scaffold(
                    body: getLoadingIndicator(() => Future.value())
                ),

                // wrapper(
                //     () => [
                //         const Padding(
                //             padding: EdgeInsets.only(top: 16),
                //             child: SizedBox(
                //                 width: 60,
                //                 height: 60,
                //                 child: CircularProgressIndicator(),
                //             )
                //         )
                //     ]
                // ),

                error: (e, st) => wrapper(
                    () => [
                        const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text('${configuration.error}'),
                        ),
                    ]
                ),

                data: (value) {
                    globalUniScheduleConfiguration = value;
                    return callback();
                }
            );
        }

        return MaterialApp(
            // TODO debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: GlobalKeys.globalScaffoldKey,
            themeMode: theme.themeMode,

            theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                colorSchemeSeed: theme.colorSchemeSeed,

                dropdownMenuTheme: DropdownMenuThemeData(
					inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                        isDense: true,
                        //border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        contentPadding: const EdgeInsets.all(8),
                    ),
                    menuStyle: MenuStyle(
                        shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                        ),
                    ),
                ),
            ),
            darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                colorSchemeSeed: theme.colorSchemeSeed,

                dropdownMenuTheme: DropdownMenuThemeData(
					inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                        isDense: true,
                        //border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        contentPadding: const EdgeInsets.all(8),
                    ),
                    menuStyle: MenuStyle(
                        shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                        ),
                    ),
                ),
            ),


            home: preloadConfiguration(
                () => firstRun
                    ? const ScheduleSelector(firstRun: true)
                    : const HomeScreen()
            ),
            // // // // TODO
            //  builder: (context, child) {
            //      final mediaQueryData = MediaQuery.of(context);
            //      final scale = 1.3;//TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! mediaQueryData.textScaleFactor.clamp(1.0, 1.3);
            //      return MediaQuery(
            //          child: child!,
            //          data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
            //      );
            //  },
        );
    }
}
