import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_linkify/flutter_linkify.dart';

import '../provider.dart';
import '../manifest.dart';
import '../utils.dart';

class SettingsPage extends ConsumerWidget {
    SettingsPage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final prefs = ref.watch(settingsProvider).value;

        return ListView(
            children: [
                ListTile(
                    title: const Text("Тема приложения:"),
                    trailing: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                        child: DropdownMenu(
                            initialSelection: prefs!.getString('theme') ?? 'system',
                            enableSearch: false,
                            inputDecorationTheme: InputDecorationTheme(
                                border: null,
                            ),
                            requestFocusOnTap: false,
                            dropdownMenuEntries: const [
                                DropdownMenuEntry(value: 'light',  label: "Светлая"),
                                DropdownMenuEntry(value: 'dark',   label: "Тёмная"),
                                DropdownMenuEntry(value: 'system', label: "Системная"),
                            ],
                            onSelected: (value) {
                                prefs!.setString('theme', value!);
                                ref.invalidate(settingsProvider);
                            },
                        )
                    )
                ),

                ListTile(
                    title: const Text('Автор:'),
                    trailing: const Text(
                        style: const TextStyle(fontSize: 14.0),
                        'Сергей Сушилин, ВМК МГУ')
                ),

                if (globalUniScheduleManifest.uniScheduleManifest.channelLink != null)
                ListTile(
                    title: const Text('Канал в Telegram:'),
                    trailing: Linkify(
                        onOpen: (link) => launchUrl(context, link.url),
                        text: globalUniScheduleManifest.uniScheduleManifest.channelLink!,
                        style: const TextStyle(fontSize: 14.0),
                    ),
                ),

                ListTile(
                    title: Container(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                            onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog( // TODO Change to dialog
                                        title: Text('Поддержать проект'),
                                        content: Text(globalUniScheduleManifest.uniScheduleManifest.supportGoals),
                                        actions: globalUniScheduleManifest.uniScheduleManifest.supportVariants.map(
                                            (e) => ElevatedButton(
                                                child: Text(e.label),
                                                onPressed: () => launchUrl(context, e.link),
                                            ),
                                        ).toList()
                                    ),
                                );
                            },
                            child: Text(
                                'Поддержать проект',
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.primary
                                ),
                            ),
                        )
                    )
                )
            ],
        );

        // ListTile(
        //     trailing: ElevatedButton(
        //         child: const Text("CLEAR DATA"),
        //         onPressed: () {
        //             prefs!.clear();
        //             Navigator.push(
        //                 context,
        //                 MaterialPageRoute(builder: (context) { return ScheduleSelectorRoute(); }),
        //             );
        //         },
        //     ),
        // )

        // * For testing
        // ListTile(
        //   trailing: ElevatedButton(
        //     child: const Text("SET"),
        //     onPressed: () {
        //       prefs!.setString(id.text, val.text);
        //     },
        //   ),
        //   title: SizedBox(
        //     width: 150,
        //     child: TextField(controller: val),
        //   ),
        //   leading: SizedBox(
        //     width: 150,
        //     child: TextField(controller: id),
        //   ),
        // )
    }
}
