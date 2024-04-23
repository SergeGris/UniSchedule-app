
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
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../configuration.dart';
import '../../widgets/overflowed_text.dart';
import '../../utils.dart';

class CopyingPage extends StatelessWidget {
    const CopyingPage({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: OverflowedText(text: 'GNU General Public License 3', shortText: 'GNU GPLv3', style: Theme.of(context).textTheme.headlineSmall),
            ),
            body: FutureBuilder(
                future: rootBundle.loadString("assets/copying.md"),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasError) {
                        return Center(
                            child: Text(
                                'Не удалось загрузить текст лицензии',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium
                            )
                        );
                    }

                    if (snapshot.hasData) {
                        // Workaround a bug. When using just Markdown(...), then scrolling works bad.
                        // Maybe soon it will be fixed in flutter_markdown.
                        return SingleChildScrollView(
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: MarkdownBody(
                                    data: snapshot.data!,
                                    onTapLink: (text, href, title) {
                                        if (href != null) {
                                            launchLink(context, href);
                                        }
                                    },
                                    shrinkWrap: true,
                                )
                            )
                        );
                    }

                    return Center(
                        child: const CircularProgressIndicator(),
                    );
                }
            ),
        );
    }
}

class AboutPage extends StatelessWidget {
    const AboutPage({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('О UniSchedule'),
                shadowColor: Theme.of(context).shadowColor,
            ),
            body: ListView(
                children: <Widget>[
                    Center(
                        child: SizedBox(
                            height: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.5,
                            width: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.5 ,
                            child: Image.asset('assets/images/icon.png'),
                        )
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

                    Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                            'UniSchedule — это бесплатное приложение для студентов, в котором можно найти множество полезных сервисов. Здесь уже доступен просмотр расписания, схемы этажей факультета, а также полезные ссылки. В скором времени планируется добавить много нового функционала!'
                        ),
                    ),

                    const Divider(),

                    FutureBuilder(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data == null) {
                                return const SizedBox.shrink();
                            }

                            final packageInfo = snapshot.data!;

                            //TODO Copy on long press?
                            return ListTile(
                                title: const Text(textAlign: TextAlign.center, 'Версия приложения'),
                                subtitle: Text(textAlign: TextAlign.center, 'Версия: ${packageInfo.version} (${packageInfo.buildNumber})'),
                            );
                        },
                    ),

                    ListTile(
                        title: const Text(textAlign: TextAlign.center, 'Автор: Сергей Сушилин, ВМК МГУ'),
                        subtitle: UniScheduleConfiguration.authorEmailAddress != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                const Text('По всем вопросам писать на почту:'),
                                Linkify(
                                    onOpen: (link) => launchLink(context, link.url),
                                    text: UniScheduleConfiguration.authorEmailAddress!,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                ),
                            ],
                        )
                        : null,
                    ),

                    if (UniScheduleConfiguration.supportedBy.isNotEmpty)
                    ListTile(
                        title: const Text(textAlign: TextAlign.center, 'Проект поддержали:'),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: UniScheduleConfiguration.supportedBy.map(
                                (e) => Text('${e.name}' + (e.amount != 0 ? ' — ${e.amount} ₽' : ''))
                            )
                            .toList()
                        ),
                    ),

                    if (UniScheduleConfiguration.channelLink != null)
                    ListTile(
                        title: Wrap(
                            alignment: WrapAlignment.center,
                            direction: Axis.horizontal,
                            children: <Widget>[
                                Text(
                                    'Канал в Telegram: ',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Linkify(
                                    onOpen: (link) async => launchLink(context, link.url),
                                    text: UniScheduleConfiguration.channelLink!,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                ),
                            ],
                        ),
                    ),

                    ListTile(
                        title: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: SizedBox(
                                height: 60,
                                width: 60,
                                child: SvgPicture(AssetBytesLoader('assets/images/services/GPLv3Logo.svg.vec')),
                            )
                        ),
                        subtitle: const Text(textAlign: TextAlign.center, 'Лицензия'),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CopyingPage())),
                    ),
                ],
            ),
        );
    }
}
