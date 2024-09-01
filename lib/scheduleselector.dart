
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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import './configuration.dart';
import './globalkeys.dart';
import './provider.dart';
import './utils.dart';

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

        final university = prefs.getString('universityName') ?? prefs.getString('universityId')!;
        final faculty    = prefs.getString('facultyName')    ?? prefs.getString('facultyId')!;
        final year       = prefs.getString('yearName')       ?? prefs.getString('yearId')!;
        final group      = prefs.getString('groupName')      ?? prefs.getString('groupId')!;

        return TextButton(
            child: Text('$group группа $year курса, $faculty $university'),
            onPressed: () async => AnimatedNavigator.push(
                context,
                (context) => const ScheduleSelectorRoute(),
            )
            .then((_) => refreshSchedule(ref))
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

class Menu {
    Menu({required this.enabled, this.id, this.name, this.manifest, required this.getManifest, this.entries});
    bool enabled;
    String? id;
    String? name;
    Future<ManifestData>? manifest;
    List<DropdownMenuEntry<String>>? entries;
    Future<ManifestData>? Function() getManifest;
}

Future<ManifestData> getManifest({required WidgetRef ref, String? university, String? faculty, String? year}) async {
    String path = '/${UniScheduleConfiguration.scheduleFormatVersion}';

    if (university != null) {
        path += '/' + university;

        if (faculty != null) {
            path += '/' + faculty;

            if (year != null) {
                path += '/' + year;
            }
        }
    }

    return http.get(
        Uri.https(
            UniScheduleConfiguration.serverIp,
            UniScheduleConfiguration.schedulePathPrefix + path + '/manifest.json',
        ),
    )
    .then((value)   => Manifest.fromJson(jsonDecode(value.body)).data)
    .catchError((e) => Future<ManifestData>.error('Не удалось загрузить список'));
}

final manifestProvider = FutureProvider.family<ManifestData, Menu>(
    (ref, Menu which) async { // MUST BE ASYNC.
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
);

class ScheduleSelector extends ConsumerStatefulWidget {
    const ScheduleSelector({required this.firstRun, super.key});

    final bool firstRun;

    @override
    ConsumerState<ScheduleSelector> createState() => _ScheduleSelectorState();
}

class _ScheduleSelectorState extends ConsumerState<ScheduleSelector> {
    _ScheduleSelectorState();

    late var prefs;

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
            prefs = ref.watch(settingsProvider).value!;

            final universityId = prefs.getString('universityId');
            final facultyId    = prefs.getString('facultyId');
            final yearId       = prefs.getString('yearId');
            final groupId      = prefs.getString('groupId');

            final universityName = prefs.getString('universityName');
            final facultyName    = prefs.getString('facultyName');
            final yearName       = prefs.getString('yearName');
            final groupName      = prefs.getString('groupName');

            university = Menu(enabled: true,                 id: universityId, name: universityName, getManifest: () async => getManifest(ref: ref));
            faculty    = Menu(enabled: universityId != null, id: facultyId,    name: facultyName,    getManifest: () async => university.id != null ? getManifest(ref: ref, university: university.id) : Future.value(manifestDataEmpty()));
            year       = Menu(enabled: facultyId    != null, id: yearId,       name: yearName,       getManifest: () async => faculty.id    != null ? getManifest(ref: ref, university: university.id, faculty: faculty.id) : Future.value(manifestDataEmpty()));
            group      = Menu(enabled: yearId       != null, id: groupId,      name: groupName,      getManifest: () async => year.id       != null ? getManifest(ref: ref, university: university.id, faculty: faculty.id, year: year.id) : Future.value(manifestDataEmpty()));
        }

        Widget getMenu(AsyncValue<ManifestData> manifest,
                       String name,
                       Menu menu,
                       void Function(String name, String label, List<DropdownMenuEntry<String>> manifestData) callback) {
            final size = MediaQuery.of(context).size.shortestSide / 7;

            return manifest.when(
                loading: () {
                    canLoadSchedule = false;

                    return SizedBox.square(
                        dimension: size,
                        child: const CircularProgressIndicator(),
                    );
                },

                error: (error, stack) {
                    canLoadSchedule = false;

                    return SizedBox(
                        height: size,
                        child: Column(
                            children: <Widget>[
                                const Expanded(
                                    child: Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                    ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Text('${manifest.error}'),
                                ),
                            ],
                        ),
                    );
                },

                data: (manifestData) {
                    canLoadSchedule = true;

                    final entries = menu.entries ?? manifestData.map((e) => DropdownMenuEntry<String>(value: e.name, label: e.label)).toList();

                    // If there is only one value in manifest and dropdown menu is not selected, then
                    // select this the only value.
                    if (entries.length == 1 && menu.id == null) {
                        final value = entries[0].value;

                        callback(
                            value,
                            manifestData.firstWhere((element) => element.name == value).label,
                            entries
                        );
                    }

                    final searchEnabled = entries.length > 5;

                    return DropdownMenu(
                        enabled: menu.enabled && entries.length != 1,
                        requestFocusOnTap: searchEnabled,
                        initialSelection: menu.enabled ? menu.id : null, // TODO preselect only value
                        label: Text(name),
                        width: MediaQuery.of(context).size.width * Constants.goldenRatio,
                        menuHeight: MediaQuery.of(context).size.height * 0.4, // Take no more than 40% of available height
                        leadingIcon: searchEnabled ? const Icon(Icons.search) : null,
                        // inputDecorationTheme: const InputDecorationTheme(
                        //     border: null,
                        //     contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                        // ),
                        dropdownMenuEntries: entries,
                        onSelected: (value) => setState(
                            () => callback(
                                value!,
                                manifestData.firstWhere((element) => element.name == value).label,
                                entries
                            )
                        )
                    );

                    return DropdownMenu(
                        enabled: menu.enabled,
                        requestFocusOnTap: entries.length > 5,
                        initialSelection: menu.enabled ? menu.id : null, // TODO preselect only value
                        label: Text(name),
                        leadingIcon: const Icon(Icons.search),
                        width: MediaQuery.of(context).size.width * Constants.goldenRatio,
                        menuHeight: MediaQuery.of(context).size.height * 0.4, // Take no more than 40% of available height
                        // inputDecorationTheme: const InputDecorationTheme(
                        //     border: null,
                        //     contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                        // ),
                        dropdownMenuEntries: entries,
                        onSelected: (value) => setState(
                            () => callback(
                                value!,
                                manifestData.firstWhere((element) => element.name == value).label,
                                entries
                            ),
                        ),
                    );
                }
            );
        }

        final children = <Widget>[
            const SizedBox.shrink(),

            getMenu(
                ref.watch(manifestProvider(university)),
                'Университет',
                university,
                (value, label, entries) {
                    university = Menu(enabled: true, id: value, name: label, manifest: university.manifest, getManifest: university.getManifest, entries: entries);
                    faculty    = Menu(enabled: true,                                                        getManifest: faculty.getManifest);
                    year       = Menu(enabled: false,                                                       getManifest: year.getManifest);
                    group      = Menu(enabled: false,                                                       getManifest: group.getManifest);
                    ref.invalidate(manifestProvider(faculty));
                },
            ),

            getMenu(
                ref.watch(manifestProvider(faculty)),
                'Факультет',
                faculty,
                (value, label, entries) {
                    faculty = Menu(enabled: true, id: value, name: label, manifest: faculty.manifest, getManifest: faculty.getManifest, entries: entries);
                    year    = Menu(enabled: true,                                                     getManifest: year.getManifest);
                    group   = Menu(enabled: false,                                                    getManifest: group.getManifest);
                    ref.invalidate(manifestProvider(year));
                },
            ),

            getMenu(
                ref.watch(manifestProvider(year)),
                'Курс',
                year,
                (value, label, entries) {
                    year  = Menu(enabled: true, id: value, name: label, manifest: year.manifest, getManifest: year.getManifest, entries: entries);
                    group = Menu(enabled: true,                                                  getManifest: group.getManifest);
                    ref.invalidate(manifestProvider(group));
                },
            ),

            getMenu(
                ref.watch(manifestProvider(group)),
                'Группа',
                group,
                (value, label, entries) {
                    group = Menu(enabled: true, id: value, name: label, manifest: group.manifest, getManifest: group.getManifest, entries: entries);
                },
            ),

            FilledButton(
                child: const Text('Загрузить расписание'),
                style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.titleMedium,
                    padding: const EdgeInsets.all(16.0),
                ),
                onPressed: !allDone()
                ? null
                : () async {
                    final prefs = ref.watch(settingsProvider).value!;

                    await prefs.setString('initialized', '1');

                    final m = [
                        ('university', university),
                        ('faculty',    faculty),
                        ('year',       year),
                        ('group',      group),
                    ];

                    for (final (k, v) in m) {
                        await prefs.setString('${k}Id', v.id!);

                        if (v.name != null) {
                            await prefs.setString('${k}Name', v.name!);
                        } else {
                            await prefs.remove('${k}Name');
                        }
                    }

                    await prefs.remove('fallbackSchedule');
                    ref.invalidate(settingsProvider);

                    if (!widget.firstRun) {
                        Navigator.pop(context);
                    }
                },
            ),
        ];

        return Scaffold(
            appBar: AppBar(title: const Text('Поиск расписания')),

            body: RefreshIndicator(
                onRefresh: () {
                    GlobalKeys.hideWarningBanner();
                    setState(() => initialized = false);
                    return Future<void>.value();
                },

                child: ListView.separated(
                    itemCount: children.length,
                    itemBuilder: (context, index) => Center(child: children[index]),
                    separatorBuilder: (_, __) => SizedBox(
                        height: MediaQuery.of(context).size.height / 12,
                    ),
                ),
            ),
        );
    }
}
