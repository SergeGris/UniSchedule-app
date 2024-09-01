import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider.dart';
import '../../utils.dart';

class SettingsPage extends ConsumerWidget {
    const SettingsPage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final prefs = ref.watch(settingsProvider).value!;
        final theme = ColorTheme.fromString(prefs.getString('theme'));
        final usingSystemTheme = theme == ColorTheme.system;
        final initialSelection = usingSystemTheme ? (isDarkMode(context) ? ColorTheme.dark : ColorTheme.light) : theme;
        final customColor = Color(prefs.getInt('custom.color.scheme.seed') ?? theme.colorSchemeSeed.value);

        return Scaffold(
            appBar: AppBar(title: const Text('Настройки')),
            body: ListView(
                children: <Widget>[
                    SwitchListTile(
                        title: const Text('Использовать системную тему'),
                        value: usingSystemTheme,
                        onChanged: (bool value) async {
                            await prefs.setString('theme', value ? ColorTheme.system.name : initialSelection.name);
                            ref.invalidate(settingsProvider);
                        },
                    ),

                    ListTile(
                        enabled: !usingSystemTheme,
                        title: const Text('Тема приложения'),

                        trailing: DropdownMenu<ColorTheme>(
                            enabled: !usingSystemTheme,

                            initialSelection: initialSelection,
                            requestFocusOnTap: false,

                            textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: !usingSystemTheme ? null : Theme.of(context).disabledColor
                            ),

                            onSelected: usingSystemTheme ? null : (ColorTheme? value) async {
                                await prefs.setString('theme', value?.name ?? ColorTheme.system.name);
                                ref.invalidate(settingsProvider);
                            },

                            dropdownMenuEntries: ColorTheme.values.where((e) => e != ColorTheme.system).map<DropdownMenuEntry<ColorTheme>>(
                                (ColorTheme theme) => DropdownMenuEntry<ColorTheme>(
                                    value: theme,
                                    label: theme.label,
                                ),
                            ).toList(),
                        ),
                    ),

                    if (theme == ColorTheme.custom)
                    ...[
                        const Divider(),

                        Text(
                            'Настройки персональной темы приложения',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                        ),

                        SwitchListTile(
                            title: const Text('Тёмная тема'),
                            value: (prefs.getString('custom.theme.mode') ?? (isDarkMode(context) ? 'dark' : 'light')) == 'dark',
                            onChanged: (bool value) async {
                                await prefs.setString('custom.theme.mode', value ? 'dark' : 'light');
                                CustomColorTheme.themeMode = value ? ThemeMode.dark : ThemeMode.light;
                                ref.invalidate(settingsProvider);
                            },
                        ),

                        ListTile(
                            title: const Text('Цвет'),
                            trailing: ElevatedButton(
                                child: Text(
                                    customColor.toPrettyString(),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: CustomColorTheme.colorSchemeSeed,
                                    ),
                                ),
                                onPressed: () async => showDialog<void>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                        content: SingleChildScrollView(
                                            child: ColorPicker(
                                                pickerColor: CustomColorTheme.colorSchemeSeed,
                                                onColorChanged: (Color color) async {
                                                    CustomColorTheme.colorSchemeSeed = color;
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
                                    ),
                                ),
                            ),
                        ),
                    ],

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
