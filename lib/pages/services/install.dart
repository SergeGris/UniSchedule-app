
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';

import '../../utils.dart';
import '../../configuration.dart';

class InstallPage extends StatelessWidget {
    const InstallPage({super.key});

    List<Widget> _getNumberedSteps(List<Widget> steps) {
        return steps.mapIndexed(
            (s, i) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Text('${i+1}.'),
                    const SizedBox(width: 4),
                    Flexible(child: s),
                ],
            ),
        ).toList();
    }

    @override
    Widget build(BuildContext context) {
        Widget iconify(IconData icon, Color color) => Icon(
            icon,
            color: color,
            size: Theme.of(context).textTheme.titleLarge?.fontSize ?? 32
        );

        final List<InlineSpan> updateVariants = [];

        for (int i = 0; i < UniScheduleConfiguration.updateVariants.length; i++) {
            final e = UniScheduleConfiguration.updateVariants[i];

            updateVariants.add(
                LinkSpan(
                    text: e.label,
                    link: e.link,
                    onTap: (link) async => launchLink(context, link),
                ),
            );

            if (i < UniScheduleConfiguration.updateVariants.length - 1) {
                updateVariants.add(
                    i == UniScheduleConfiguration.updateVariants.length - 2
                    ? const TextSpan(text: ' и ')
                    : const TextSpan(text: ', ')
                );
            }
        }

        final showBoth = !(OS.isWebAndroid || OS.isWebIOS);

        return Scaffold(
            appBar: AppBar(title: const Text('Установить приложение')),
            body: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                    Row(
                        children: <Widget>[
                            Text(
                                'Установка на смартфон',
                                style: Theme.of(context).textTheme.titleLarge,
                            ),
                        ],
                    ),

                    const Divider(),

                    const Text(
                        'UniSchedule может работать не только в браузере, но и устанавливаться на устройства как приложение. Рекомендуется это сделать, чтобы получить полноценную функциональность приложения и максимально приятные впечатления.',
                    ),

                    if (showBoth || OS.isWebAndroid) ...[
                        const SizedBox(height: 8),

                        Row(
                            children: <Widget>[
                                iconify(Icons.android, Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                    'Установка на Android',
                                    style: Theme.of(context).textTheme.titleLarge,
                                ),
                            ]
                        ),

                        const Divider(),

                        Text.rich(
                            TextSpan(
                                children: <InlineSpan>[
                                    const TextSpan(text: 'Приложение можно скачать в '),
                                    ...updateVariants,
                                    const TextSpan(text: '.'),
                                ],
                            ),
                        ),

                        const SizedBox(height: 4),

                        const Text('Также можно установить приложение как PWA:'),

                        ..._getNumberedSteps(
                            [
                                const Text.rich(
                                    TextSpan(
                                        children: <TextSpan>[
                                            TextSpan(
                                                text: 'Откройте браузер ',
                                            ),

                                            TextSpan(
                                                text: 'Google Chrome',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                            ),

                                            TextSpan(
                                                text: ' на Android-устройстве.',
                                            ),
                                        ],
                                    ),
                                ),

                                Text.rich(
                                    TextSpan(
                                        children: <InlineSpan>[
                                            const TextSpan(
                                                text: 'Перейдите на ',
                                            ),

                                            LinkSpan(
                                                text: 'страницу приложения',
                                                link: 'https://sergegris.github.io/UniSchedule-app',
                                                onTap: (link) async => launchLink(context, link),
                                            ),

                                            const TextSpan(
                                                text: '.',
                                            ),
                                        ],
                                    ),
                                ),

                                const Text.rich(
                                    TextSpan(
                                        children: <TextSpan>[
                                            TextSpan(
                                                text: 'Перейдите в меню',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                            ),

                                            TextSpan(
                                                text: ' (центральная кнопка на нижней панели) и нажмите кнопку ',
                                            ),

                                            TextSpan(
                                                text: 'Установить',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                            ),

                                            TextSpan(
                                                text: '.',
                                            ),
                                        ],
                                    ),
                                ),

                                const Text('Следуйте инструкциям на экране.'),
                            ],
                        ),
                    ],

                    if (showBoth || OS.isWebIOS) ...[
                        const SizedBox(height: 8),

                        Row(
                            children: <Widget>[
                                iconify(MaterialCommunityIcons.apple, Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                    'Установка на iPhone',
                                    style: Theme.of(context).textTheme.titleLarge,
                                ),
                            ]
                        ),

                        const Divider(),

                        ..._getNumberedSteps(
                            [
                                const Text.rich(
                                    TextSpan(
                                        children: <TextSpan>[
                                            TextSpan(
                                                text: 'Откройте браузер ',
                                            ),

                                            TextSpan(
                                                text: 'Safari',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                            ),

                                            TextSpan(
                                                text: ' на iPhone.',
                                            ),
                                        ],
                                    ),
                                ),

                                Text.rich(
                                    TextSpan(
                                        children: <InlineSpan>[
                                            const TextSpan(
                                                text: 'Перейдите на ',
                                            ),

                                            LinkSpan(
                                                text: 'страницу приложения',
                                                link: 'https://sergegris.github.io/UniSchedule-app',
                                                onTap: (link) async => launchLink(context, link),
                                            ),

                                            const TextSpan(
                                                text: '.',
                                            ),
                                        ],
                                    ),
                                ),

                                const Text.rich(
                                    TextSpan(
                                        children: <TextSpan>[
                                            TextSpan(
                                                text: 'Перейдите в меню ',
                                            ),

                                            TextSpan(
                                                text: 'Поделиться',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                            ),

                                            TextSpan(
                                                text: ' (центральная кнопка на нижней панели) и нажмите кнопку ',
                                            ),

                                            TextSpan(
                                                text: 'На экран “Домой”',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                            ),

                                            TextSpan(
                                                text: '.',
                                            ),
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    ],
                ],
            ),
        );
    }
}
