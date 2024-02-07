import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './provider.dart';
import './manifest.dart';
import './utils.dart';
import './globalkeys.dart';

part 'scheduleselector.g.dart';

class ScheduleSelectorRoute extends ConsumerWidget {
  ScheduleSelectorRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScheduleSelector(firstRun: false);
  }
}

Widget getScheduleSelectorButton(BuildContext context, WidgetRef ref, RefreshCallback refreshSchedule) {
    final prefs = ref.watch(settingsProvider).value!; //ref.listen(settingsProvider, (previous, next) {}).read().value!;

    final String universityId = prefs.getString('universityName') ?? prefs.getString('universityId')!;
    final String facultyId = prefs.getString('facultyName') ?? prefs.getString('facultyId')!;
    final String yearId = prefs.getString('yearId')!;
    final String groupId = prefs.getString('groupName') ?? prefs.getString('groupId')!;

    return ElevatedButton(
        child: Text('${groupId} группа $yearId курса $facultyId $universityId'),
        onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    //TODO barrierLabel: 'Назад',
                    builder: (context) {
                        return ScheduleSelectorRoute();
                    }
                )
            ).then((_) {
                    /*TODO: none need if invalidate(groupProvider) in ScheduleSelectorRoute() */
                    refreshSchedule();
            });
        },
    );
}

class ManifestEntry {
    String name;
    String label;

    ManifestEntry({required this.name, required this.label});
}

typedef ManifestData = List<ManifestEntry>;

ManifestData manifestDataEmpty() {
    return [ManifestEntry(name: '', label: '')];
}

class Manifest {
  Manifest({required this.data});
  final ManifestData data;

  factory Manifest.fromJson(Map<String, dynamic> json) {
      var d = json.entries.map((e) => ManifestEntry(name: e.key, label: e.value.toString())).toList(growable: true);
      return Manifest(data: d);
  }
}

Future<ManifestData> downloadManifest(WidgetRef ref, String path) async {
    return await downloadFileByUri(Uri.https(globalUniScheduleManifest.serverIp, path))
        .then((value)   { return Manifest.fromJson(jsonDecode(value)).data; })
        .catchError((e) { return Future<ManifestData>.error('Не удалось загрузить список'); });
}

class Menu {
    Menu({required this.enabled, this.id = null, this.name = null, this.manifest = null, required this.getManifest, this.entries = null});
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

    return await downloadManifest(ref, globalUniScheduleManifest.schedulePathPrefix + path + '/manifest.json');
}

//TODO load manifest here, but not below
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
    final bool firstRun;
    const ScheduleSelector({required this.firstRun, super.key});

    @override
    ConsumerState<ScheduleSelector> createState() => _ScheduleSelectorState(firstRun);
}

class _ScheduleSelectorState extends ConsumerState<ScheduleSelector> {
    final bool firstRun;
    SharedPreferences? prefs;

    _ScheduleSelectorState(this.firstRun);

    // TODO
    // Do initialization in build to avoid troubles because of setState() and sequences tree rebuilding.
    bool initialized = false;

    bool canLoadSchedule = false;

    late Menu university;
    late Menu faculty;
    late Menu year;
    late Menu group;

    bool allDone() {
        return canLoadSchedule && university.id != null && faculty.id != null && year.id != null && group.id != null;
    }

    @override
    Widget build(BuildContext context) {
        if (!initialized) {
            initialized = true;
            prefs = ref.watch(settingsProvider).value;

            String? universityId = prefs?.getString('universityId');
            String? facultyId    = prefs?.getString('facultyId');
            String? yearId       = prefs?.getString('yearId');
            String? groupId      = prefs?.getString('groupId');

            university = Menu(enabled: true,                 id: universityId, getManifest: () => getManifest(ref: ref));
            faculty    = Menu(enabled: universityId != null, id: facultyId,    getManifest: () { return university.id != null ? getManifest(ref: ref, university: university.id) : null; });
            year       = Menu(enabled: facultyId != null,    id: yearId,       getManifest: () { return faculty.id    != null ? getManifest(ref: ref, university: university.id, faculty: faculty.id) : null; });
            group      = Menu(enabled: yearId != null,       id: groupId,      getManifest: () { return year.id       != null ? getManifest(ref: ref, university: university.id, faculty: faculty.id, year: year.id) : null; });
        }

        DropdownMenu getDropDownMenu(String label, Menu menu, ManifestData manifest, void callback(String a, String b, List<DropdownMenuEntry> dropDownMenu)) {
            final entries = manifest.map((e) => DropdownMenuEntry(value: e.name, label: e.label)).cast<DropdownMenuEntry>().toList() as List<DropdownMenuEntry>;

            return DropdownMenu(
                enabled: menu.enabled,
                requestFocusOnTap: entries.length > 3,
                initialSelection: menu.enabled ? menu.id : null,
                label: Text(label),
                leadingIcon: const Icon(Icons.search),
                width: 240.0,
                menuHeight: 300.0,
                inputDecorationTheme: const InputDecorationTheme(
                    border: null,
                    filled: true,
                    //contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                ),
                dropdownMenuEntries: menu.entries ?? entries,
                onSelected: (value) {
                    setState(
                        () {
                            callback(value, manifest.firstWhere((element) => element.name == value).label, entries);
                        }
                    );
                },
            );
        }

        List<Widget> getMenu(AsyncValue<dynamic> manifest, String name, Menu menu, void callback(String name, String label, ManifestData)) {
            return manifest.when<List<Widget>>(
                loading: () => <Widget>[
                    SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                    ),
                ],

                error: (e, st) {
                    canLoadSchedule = false;

                    return <Widget>[
                        const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
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
                        Container(
                            alignment: Alignment.center,
                            child: SizedBox(
                                child: getDropDownMenu(
                                    name,
                                    menu,
                                    list,
                                    (value, label, entries) {
                                        callback(value, label, entries);
                                    },
                                )
                            )
                        ),
                    ];
                }
            );
        }

        return Scaffold(
            appBar: AppBar(
                title: Text('Поиск расписания'),
            ),
            body: RefreshIndicator(
                onRefresh: () {
                    GlobalKeys.hideWarningBanner();
                    setState(() => initialized = false);
                    return Future<void>.value();
                },
                child: LayoutBuilder(
                    builder: (context, constraints) => ListView(
                        children: [
                            Container(
                                constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                ),
                                child: Center(child: Wrap(
                                        //mainAxisAlignment: MainAxisAlignment.center,
                                        //runAlignment: WrapAlignment.center,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        //runSpacing: 20,
                                        direction: Axis.vertical,
                                        spacing: 20,
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
                                                    padding: EdgeInsets.all(24.0),
                                                ),
                                                onPressed: !allDone()
                                                ? null
                                                : () {
                                                    final prefs = ref.watch(settingsProvider).value!;

                                                    prefs.setString('initialized', '1');
                                                    prefs.setString('universityId', university.id!);
                                                    prefs.setString('facultyId', faculty.id!);
                                                    prefs.setString('yearId', year.id!);
                                                    prefs.setString('groupId', group.id!);

                                                    if (university.name != null) {
                                                        prefs.setString('universityName', university.name!);
                                                    }

                                                    if (faculty.name != null) {
                                                        prefs.setString('facultyName', faculty.name!);
                                                    }

                                                    if (group.name != null) {
                                                        prefs.setString('groupName', group.name!);
                                                    }

                                                    prefs.remove('fallbackSchedule');

                                                    ref.invalidate(settingsProvider);

                                                    if (!firstRun) {
                                                        Navigator.pop(context);
                                                    }
                                                },
                                                child: Text('Загрузить расписание'),
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
