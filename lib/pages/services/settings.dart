import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/dropdownbutton.dart';
import '../../provider.dart';
import '../../utils.dart';

class SettingsPage extends ConsumerWidget {
    const SettingsPage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final prefs = ref.watch(settingsProvider).value!;
        final theme = prefs.getString('theme') ?? 'system';
        final usingSystemTheme = theme == 'system';
        final initialSelection = usingSystemTheme ? (isDarkMode(context) ? 'dark' : 'light') : theme;
        final customColor = Color(prefs.getInt('custom.color.scheme.seed') ?? uniScheduleThemes[theme]!().colorSchemeSeed.value);

        return Scaffold(
            appBar: AppBar(
                title: const Text('Настройки'),
                shadowColor: Theme.of(context).shadowColor,
            ),

            body: ListView(
                children: <Widget>[
                    SwitchListTile(
                        title: const Text('Использовать системную тему'),
                        value: usingSystemTheme,
                        onChanged: (bool value) async {
                            await prefs.setString('theme', value ? 'system' : initialSelection);
                            ref.invalidate(settingsProvider);
                        },
                    ),

                    ListTile(
                        title: Text(
                            'Тема приложения:',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: usingSystemTheme ? Theme.of(context).disabledColor : null
                            )
                        ),

                        trailing: UniScheduleDropDownButton(
                            hint: 'Выберите тему',
                            initialSelection: initialSelection,
                            items: uniScheduleThemes.toList(
                                (e) => DropdownMenuItem<String>(
                                    value: e.key,
                                    child: Container(
                                        alignment: Alignment.center,
                                        child: Text(e.value().label, maxLines: 1),
                                    ),
                                )
                            )
                            .where((e) => e.value != 'system')
                            .toList(),
                            onSelected: !usingSystemTheme
                            ? (String? value) async {
                                await prefs.setString('theme', value!);
                                ref.invalidate(settingsProvider);
                            }
                            : null,
                        )
                    ),

                    if (theme == 'custom')
                    const Divider(),

                    if (theme == 'custom')
                    Text(
                        'Настройки персональной темы приложения',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                    ),

                    if (theme == 'custom')
                    SwitchListTile(
                        title: const Text('Тёмная тема'),
                        value: (prefs.getString('custom.theme.mode') ?? (isDarkMode(context) ? 'dark' : 'light')) == 'dark',
                        onChanged: (bool value) async {
                            await prefs.setString('custom.theme.mode', value ? 'dark' : 'light');
                            uniScheduleThemeCustom.themeMode = value ? ThemeMode.dark : ThemeMode.light;
                            ref.invalidate(settingsProvider);
                        },
                    ),

                    if (theme == 'custom')
                    ListTile(
                        title: const Text('Выбор цвета'),
                        //subtitle: const Text('Устанавливает цвет, от которого будет строиться тема приложения.'),
                        trailing: ElevatedButton(
                            child: Text(
                                customColor.toPrettyString(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: uniScheduleThemeCustom.colorSchemeSeed,
                                ),
                            ),
                            onPressed: () {
                                showDialog<void>(
                                    context: context,
                                    builder: (context) {
                                        return AlertDialog(
                                            content: SingleChildScrollView(
                                                child: ColorPicker(
                                                    pickerColor: uniScheduleThemeCustom.colorSchemeSeed,
                                                    onColorChanged: (Color color) async {
                                                        uniScheduleThemeCustom.colorSchemeSeed = color;
                                                        await prefs.setInt('custom.color.scheme.seed', color.value);
                                                        ref.invalidate(settingsProvider);
                                                    },
                                                    hexInputBar: true,
                                                    enableAlpha: false,
                                                    labelTypes: const [
                                                        ColorLabelType.rgb,
                                                        ColorLabelType.hsv,
                                                        ColorLabelType.hsl,
                                                    ],
                                                ),
                                            ),
                                        );
                                    },
                                );
                            },
                        ),
                    ),

                    // if (theme == 'custom')
                    // ListTile(
                    //     title: const Text('Скопировать настройки темы'),
                    //     trailing: const Icon(Icons.copy),
                    //     onTap: () async {
                    //         final brightness = uniScheduleThemeCustom.themeMode == ThemeMode.dark ? 'dark' : 'light';
                    //         final color = uniScheduleThemeCustom.colorSchemeSeed;

                    //         await Clipboard.setData(
                    //             ClipboardData(
                    //                 text: '${brightness} ${color.value}'
                    //             )
                    //         );

                    //         final snackBar = SnackBar(
                    //             content: const Text('Настройки темы скопированы в буфер обмена')
                    //         );

                    //         ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    //     },
                    // ),

                    // if (theme == 'custom')
                    // ListTile(
                    //     title: const Text('Импортировать настройки темы'),
                    //     trailing: const Icon(Icons.paste),
                    //     onTap: () async {
                    //         final data = await Clipboard.getData('text/plain');
                    //         String message = '';
                    //         final t = data?.text?.split(' ');

                    //         if (data?.text == null || t == null || t.length != 2 || t[0] != 'light' || t[0] != 'dark' || int.tryParse(t[1]) == null) {
                    //             message = 'Не удалось импортировать тему';
                    //         } else {
                    //             message = 'Настройки темы импортированы';
                    //             final (brightness, color) = (t[0], t[1]);
                    //             await prefs.setString('custom.theme.mode', brightness);
                    //             await prefs.setInt('custom.color.scheme.seed', int.parse(color));
                    //             ref.invalidate(settingsProvider);
                    //         }

                    //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                    //     },
                    // ),
                ]
            )
        );
    }
}
