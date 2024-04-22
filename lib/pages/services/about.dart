import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../configuration.dart';
import '../../utils.dart';

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
                            height: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) / 2,
                            width: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) / 2 ,
                            child: Image.asset('assets/images/icon.png') //getLoadingIndicator(() => Future.value())
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
                                    style: TextStyle(fontSize: MediaQuery.textScalerOf(context).scale(Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14.0)),
                                ),
                            ],
                        )
                        : null,
                    ),

                    if (UniScheduleConfiguration.supportedBy.isNotEmpty)
                    ListTile(
                        title: const Text(textAlign: TextAlign.center, 'Проект поддержали'),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: UniScheduleConfiguration.supportedBy.map(
                                (e) => Text('${e.name}' + (e.amount != 0 ? ' — ${e.amount} ₽' : ''))
                            )
                            .cast<Widget>()
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
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    'Канал в Telegram: '
                                ),
                                Linkify(
                                    onOpen: (link) async => launchLink(context, link.url),
                                    text: UniScheduleConfiguration.channelLink!,
                                    style: TextStyle(fontSize: MediaQuery.textScalerOf(context).scale(Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14.0))
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }
}
