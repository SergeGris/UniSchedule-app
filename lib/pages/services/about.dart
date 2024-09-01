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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../configuration.dart';
import '../../widgets/overflowed_text.dart';
import '../../utils.dart';
import './animated_logo.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());
final copyingProvider = FutureProvider<String>((ref) => rootBundle.loadString('assets/copying.md'));

class VersionTile extends ConsumerWidget {
    const VersionTile({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        return ref.watch(packageInfoProvider).when(
            data: (packageInfo) => ListTile(
                title: const Text(
                    'Версия приложения:',
                    textAlign: TextAlign.center,
                ),
                subtitle: Text(
                    '${packageInfo.version} (${packageInfo.buildNumber})',
                    textAlign: TextAlign.center,
                ),
            ),
            error: (error, stack) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
        );
    }
}

class CopyingPage extends ConsumerWidget {
    const CopyingPage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        return Scaffold(
            appBar: AppBar(
                title: OverflowedText(
                    text: 'GNU General Public License 3',
                    shortText: 'GNU GPLv3',
                    style: Theme.of(context).textTheme.titleLarge ?? const TextStyle()
                ),
            ),

            body: ref.watch(copyingProvider).when(
                data: (content) => SelectionArea(
                    child: Markdown(
                        selectable: false,
                        data: content,
                        onTapLink: (text, href, title) async {
                            if (href != null) {
                                await launchLink(context, href);
                            }
                        },
                        shrinkWrap: true,
                    ),
                ),

                error: (error, stack) => Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Text(
                                'Не удалось загрузить текст лицензии',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium
                            ),

                            Text(
                                'Вы можете ознакомиться с текстом лицензии по ссылке:',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                            ),

                            Link(
                                text: 'https://www.gnu.org/licenses/gpl-3.0-standalone.html',
                            ),
                        ]
                    )
                ),

                loading: () => const Center(child: CircularProgressIndicator()),
            ),
        );
    }
}

class AboutPage extends ConsumerWidget {
    const AboutPage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        return Scaffold(
            appBar: AppBar(title: const Text('О UniSchedule')),
            body: ListView(
                children: <Widget>[
                    AnimatedLogo(
                        'assets/images/icon.png',
                        size: MediaQuery.of(context).size.shortestSide * 0.5
                    ),

                    Text(
                        'UniSchedule',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                    ),

                    Text(
                        '© 2024 Сергей Сушилин',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                    ),

                    ListTile(
                        title: Text(
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                            'UniSchedule — это бесплатное приложение для студентов, в котором можно найти множество полезных сервисов. Здесь уже доступен просмотр расписания, схемы этажей факультета, а также полезные ссылки!'
                        ),
                    ),

                    ListTile(
                        title: Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                                children: <InlineSpan>[
                                    const TextSpan(
                                        text: 'Нравится приложение? Поставьте '
                                    ),

                                    WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(
                                            Icons.star,
                                            color: Color(0xFFFFCC00),
                                        ),
                                    ),

                                    const TextSpan(
                                        text: ' на ',
                                    ),

                                    LinkSpan(
                                        text: 'GitHub',
                                        link: 'https://github.com/SergeGris/UniSchedule-app',
                                        onTap: (link) async => launchLink(context, link),
                                    ),

                                    const TextSpan(
                                        text: '!',
                                    ),
                                ],
                            ),
                        ),

                        subtitle: Text(
                            textAlign: TextAlign.center,
                            'Приложение распростроняется со свободным и открытым исходным кодом, вы всегда можете внести свой вклад в его развитие.'
                        ),
                    ),

                    const Divider(),

                    const VersionTile(),

                    const ListTile(
                        title: Text(textAlign: TextAlign.center, 'Автор: Сергей Сушилин, ВМК МГУ'),
                        // subtitle: UniScheduleConfiguration.authorEmailAddress == null
                        // ? null
                        // : Column(
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     children: <Widget>[
                        //         const Text(
                        //             'По всем вопросам писать на почту:',
                        //             textAlign: TextAlign.center
                        //         ),

                        //         Link(
                        //             text: UniScheduleConfiguration.authorEmailAddress!,
                        //         ),
                        //     ],
                        // ),
                    ),

                    // if (UniScheduleConfiguration.supportedBy.isNotEmpty)
                    // ListTile(
                    //     title: const Text(textAlign: TextAlign.center, 'Проект поддержали:'),
                    //     subtitle: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.center,
                    //         children: UniScheduleConfiguration.supportedBy.map(
                    //             (e) => Text(
                    //                 e.name + (e.amount != 0 ? ' — ${e.amount} ₽' : ''),
                    //                 textAlign: TextAlign.center,
                    //             )
                    //         )
                    //         .toList()
                    //     ),
                    // ),

                    // if (UniScheduleConfiguration.channelLink != null)
                    // Column(
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: <Widget>[
                    //         Text(
                    //             'Канал в Telegram:',
                    //             textAlign: TextAlign.center,
                    //             style: Theme.of(context).textTheme.bodyLarge,
                    //         ),

                    //         Link(text: UniScheduleConfiguration.channelLink!),
                    //     ],
                    // ),

                    ListTile(
                        title: SizedBox.square(
                            dimension: min(80, MediaQuery.of(context).size.shortestSide),
                            child: const SvgPicture(
                                AssetBytesLoader('assets/images/services/GPLv3Logo.svg.vec'),
                            ),
                        ),
                        subtitle: const Text(textAlign: TextAlign.center, 'Лицензия приложения'),
                        onTap: () async => AnimatedNavigator.push(
                            context,
                            (context) => const CopyingPage(),
                        ),
                    ),
                ],
            ),
        );
    }
}
