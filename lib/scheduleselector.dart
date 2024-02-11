import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './provider.dart';
import './configuration.dart';
import './utils.dart';
import './globalkeys.dart';

part 'scheduleselector.g.dart';

class ScheduleSelectorRoute extends ConsumerWidget {
    const ScheduleSelectorRoute({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) => const ScheduleSelector(firstRun: false);
}

class ScheduleSelectorButton extends ConsumerWidget {
    const ScheduleSelectorButton({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final prefs = ref.watch(settingsProvider).value!;

        final String university = prefs.getString('universityName') ?? prefs.getString('universityId')!;
        final String faculty    = prefs.getString('facultyName')    ?? prefs.getString('facultyId')!;
        final String year       = prefs.getString('yearName')       ?? prefs.getString('yearId')!;
        final String group      = prefs.getString('groupName')      ?? prefs.getString('groupId')!;

        return ElevatedButton(
            child: Text('$group группа $year курса $faculty $university'),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    // TODO barrierLabel: 'Назад',
                    builder: (context) => const ScheduleSelectorRoute()
                )
            ).then((_) => refreshSchedule(ref))
        );

    }
}

class ManifestEntry {
    ManifestEntry({required this.name, required this.label});

    String name;
    String label;
}

typedef ManifestData = List<ManifestEntry>;

ManifestData manifestDataEmpty() => [ManifestEntry(name: '', label: '')];

class Manifest {
  Manifest({required this.data});

  factory Manifest.fromJson(Map<String, dynamic> json) => Manifest(
      data: json.entries.map(
          (e) => ManifestEntry(name: e.key, label: e.value.toString())
      ).toList()
  );

  final ManifestData data;
}

Future<ManifestData> downloadManifest(WidgetRef ref, String path) async {
    return downloadFileByUri(Uri.https(globalUniScheduleConfiguration.serverIp, path))
        .then((value)   { return Manifest.fromJson(jsonDecode(value)).data; })
        .catchError((e) { return Future<ManifestData>.error('Не удалось загрузить список'); });
}

class Menu {
    Menu({required this.enabled, this.id, this.name, this.manifest, required this.getManifest, this.entries});
    bool enabled;
    String? id;
    String? name;
    Future<ManifestData>? manifest;
    List<DropdownMenuEntry>? entries;
    Future<ManifestData>? Function() getManifest;
}

Future<ManifestData> getManifest({required WidgetRef ref, String? university = null, String? faculty = null, String? year = null}) async {
    String path = '/$scheduleFormatVersion';

    if (university != null) {
        path += '/' + university;

        if (faculty != null) {
            path += '/' + faculty;

            if (year != null) {
                path += '/' + year;
            }
        }
    }

    return downloadManifest(ref, globalUniScheduleConfiguration.schedulePathPrefix + path + '/manifest.json');
}

@riverpod
Future<ManifestData> manifest(ManifestRef ref, Menu which) async {
    if (which.manifest == null) {
        final m = which.getManifest();

        if (m == null) {
            return manifestDataEmpty();
        }

        which.manifest = m;
        return m;
    }

    return which.manifest!;
}

class ScheduleSelector extends ConsumerStatefulWidget {
    const ScheduleSelector({required this.firstRun, super.key});

    final bool firstRun;

    @override
    ConsumerState<ScheduleSelector> createState() => _ScheduleSelectorState(firstRun: firstRun);
}

class _ScheduleSelectorState extends ConsumerState<ScheduleSelector> {
    _ScheduleSelectorState({required this.firstRun});

    final bool firstRun;
    SharedPreferences? prefs;

    // Do initialization in build to avoid troubles because of setState() and sequences tree rebuilding.
    bool initialized = false;

    bool canLoadSchedule = false;

    late Menu university;
    late Menu faculty;
    late Menu year;
    late Menu group;

    bool allDone() => canLoadSchedule && university.id != null && faculty.id != null && year.id != null && group.id != null;

    @override
    Widget build(BuildContext context) {
        if (!initialized) {
            initialized = true;
            prefs = ref.watch(settingsProvider).value;

            final universityId = prefs?.getString('universityId');
            final facultyId    = prefs?.getString('facultyId');
            final yearId       = prefs?.getString('yearId');
            final groupId      = prefs?.getString('groupId');

            final universityName = prefs?.getString('universityName');
            final facultyName    = prefs?.getString('facultyName');
            final yearName       = prefs?.getString('yearName');
            final groupName      = prefs?.getString('groupName');

            university = Menu(enabled: true,                 id: universityId, name: universityName, getManifest: () => getManifest(ref: ref));
            faculty    = Menu(enabled: universityId != null, id: facultyId,    name: facultyName,    getManifest: () => university.id != null ? getManifest(ref: ref, university: university.id) : null);
            year       = Menu(enabled: facultyId    != null, id: yearId,       name: yearName,       getManifest: () => faculty.id    != null ? getManifest(ref: ref, university: university.id, faculty: faculty.id) : null);
            group      = Menu(enabled: yearId       != null, id: groupId,      name: groupName,      getManifest: () => year.id       != null ? getManifest(ref: ref, university: university.id, faculty: faculty.id, year: year.id) : null);
        }

        DropdownMenu getDropDownMenu(String label,
                                     Menu menu,
                                     ManifestData manifest,
                                     void callback(String a, String b, List<DropdownMenuEntry> dropDownMenu)) {
            final entries = manifest.map((e) => DropdownMenuEntry(value: e.name, label: e.label)).cast<DropdownMenuEntry>().toList();

            return DropdownMenu(
                enabled: menu.enabled,
                requestFocusOnTap: entries.length > 3,
                initialSelection: menu.enabled ? menu.id : null,
                label: Text(label),
                leadingIcon: const Icon(Icons.search),
                width: 184.0,
                menuHeight: 200.0,
                inputDecorationTheme: const InputDecorationTheme(
                    border: null,
                ),
                dropdownMenuEntries: menu.entries ?? entries,
                onSelected: (value) => setState(
                    () => callback(
                        value,
                        manifest.firstWhere((element) => element.name == value).label,
                        entries
                    )
                )
            );
        }

        List<Widget> getMenu(AsyncValue<dynamic> manifest, String name, Menu menu, void callback(String name, String label, List<DropdownMenuEntry> manifestData)) {
            const size = 64.0;

            return manifest.when<List<Widget>>(
                loading: () {
                    canLoadSchedule = false;

                    return <Widget>[
                        const SizedBox(
                            width: size,
                            height: size,
                            child: CircularProgressIndicator(),
                        ),
                    ];
                },

                error: (e, st) {
                    canLoadSchedule = false;

                    return <Widget>[
                        const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: size,
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text('${manifest.error}'),
                        ),
                    ];
                },

                data: (list) {
                    canLoadSchedule = true;

                    return <Widget>[
                        SizedBox(
                            height: size,
                            // Width is specified in getDropDownMenu().
                            child: getDropDownMenu(
                                name,
                                menu,
                                list,
                                (value, label, entries) {
                                    callback(value, label, entries);
                                },
                            )
                        ),
                    ];
                }
            );
        }

        return Scaffold(
            appBar: AppBar(
                title: const Text('Поиск расписания'),
            ),

            body: RefreshIndicator(
                onRefresh: () {
                    GlobalKeys.hideWarningBanner();
                    setState(() => initialized = false);
                    return Future<void>.value();
                },

                child: LayoutBuilder(
                    builder: (context, final constraints) => ListView(
                        children: [
                            Container(
                                constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                ),
                                child: Center(
                                    child: Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        direction: Axis.vertical,
                                        spacing: 24,
                                        children: [
                                            ...getMenu(
                                                ref.watch(manifestProvider(university)),
                                                'Университет',
                                                university,
                                                (value, label, entries) {
                                                    university = Menu(enabled: true, id: value, name: label, manifest: university.manifest, getManifest: university.getManifest, entries: entries);
                                                    faculty    = Menu(enabled: true,                                                        getManifest: faculty.getManifest);
                                                    year       = Menu(enabled: false,                                                       getManifest: year.getManifest);
                                                    group      = Menu(enabled: false,                                                       getManifest: group.getManifest);
                                                    ref.invalidate(manifestProvider(faculty));
                                                }
                                            ),

                                            ...getMenu(
                                                ref.watch(manifestProvider(faculty)),
                                                'Факультет',
                                                faculty,
                                                (value, label, entries) {
                                                    faculty = Menu(enabled: true, id: value, name: label, manifest: faculty.manifest, getManifest: faculty.getManifest, entries: entries);
                                                    year    = Menu(enabled: true,                                                     getManifest: year.getManifest);
                                                    group   = Menu(enabled: false,                                                    getManifest: group.getManifest);
                                                    ref.invalidate(manifestProvider(year));
                                                }
                                            ),

                                            ...getMenu(
                                                ref.watch(manifestProvider(year)),
                                                'Курс',
                                                year,
                                                (value, label, entries) {
                                                    year  = Menu(enabled: true, id: value, name: label, manifest: year.manifest, getManifest: year.getManifest, entries: entries);
                                                    group = Menu(enabled: true,                                                  getManifest: group.getManifest);
                                                    ref.invalidate(manifestProvider(group));
                                                }
                                            ),

                                            ...getMenu(
                                                ref.watch(manifestProvider(group)),
                                                'Группа',
                                                group,
                                                (value, label, entries) {
                                                    group = Menu(enabled: true, id: value, name: label, manifest: group.manifest, getManifest: group.getManifest, entries: entries);
                                                }
                                            ),

                                            TextButton(
                                                style: TextButton.styleFrom(
                                                    textStyle: const TextStyle(fontSize: 20.0),
                                                    padding: const EdgeInsets.all(20.0),
                                                ),
                                                onPressed: !allDone()
                                                ? null
                                                : () {
                                                    final prefs = ref.watch(settingsProvider).value!;

                                                    prefs.setString('initialized',  '1');
                                                    prefs.setString('universityId', university.id!);
                                                    prefs.setString('facultyId',    faculty.id!);
                                                    prefs.setString('yearId',       year.id!);
                                                    prefs.setString('groupId',      group.id!);

                                                    if (university.name != null) {
                                                        prefs.setString('universityName', university.name!);
                                                    } else {
                                                        prefs.remove('universityName');
                                                    }

                                                    if (faculty.name != null) {
                                                        prefs.setString('facultyName', faculty.name!);
                                                    } else {
                                                        prefs.remove('facultyName');
                                                    }

                                                    if (year.name != null) {
                                                        prefs.setString('yearName', year.name!);
                                                    } else {
                                                        prefs.remove('yearName');
                                                    }

                                                    if (group.name != null) {
                                                        prefs.setString('groupName', group.name!);
                                                    } else {
                                                        prefs.remove('groupName');
                                                    }

                                                    prefs.remove('fallbackSchedule');
                                                    ref.invalidate(settingsProvider);

                                                    if (!firstRun) {
                                                        Navigator.pop(context);
                                                    }
                                                },
                                                child: const Text('Загрузить расписание'),
                                            ),
                                        ]
                                    )
                                )
                            )
                        ]
                    )
                )
            )
        );
    }
}
