import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_linkify/flutter_linkify.dart';

import '../provider.dart';
import '../configuration.dart';
import '../utils.dart';

class SettingsPage extends ConsumerWidget {
    const SettingsPage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final prefs = ref.watch(settingsProvider).value;

        return ListView(
            children: [
                ListTile(
                    title: Text(
                        'Тема приложения:',
                        style: Theme.of(context).textTheme.titleMedium
                    ),
                    trailing: DropdownMenu(
                        initialSelection: prefs!.getString('theme') ?? 'system',
                        enableSearch: false,
                        inputDecorationTheme: const InputDecorationTheme(
                            border: null,
                        ),
                        requestFocusOnTap: false,
                        dropdownMenuEntries: uniScheduleThemes.map(
                            (t) => DropdownMenuEntry(value: t.key, label: t.label)
                        ).toList(),
                        onSelected: (value) {
                            prefs!.setString('theme', value!);
                            ref.invalidate(settingsProvider);
                        },
                    )
                ),

                ListTile(
                    title: Text(
                        'Автор:',
                        style: Theme.of(context).textTheme.titleMedium
                    ),
                    trailing: Text(
                        'Сергей Сушилин, ВМК МГУ',
                        style: Theme.of(context).textTheme.titleMedium
                    )
                ),

                if (globalUniScheduleConfiguration.channelLink != null)
                ListTile(
                    title: Text(
                        'Канал в Telegram:',
                        style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: Linkify(
                        onOpen: (link) => launchUrl(context, link.url),
                        text: globalUniScheduleConfiguration.channelLink!,
                        style: Theme.of(context).textTheme.titleMedium,
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
                                        title: const Text('Поддержать проект'),
                                        content: Text(globalUniScheduleConfiguration.supportGoals),
                                        actions: globalUniScheduleConfiguration.supportVariants?.map(
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
