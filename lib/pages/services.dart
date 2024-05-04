
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

import './services/about.dart';
import './services/map.dart';
import './services/settings.dart';

import '../configuration.dart';
import '../provider.dart';
import '../utils.dart';
import './webview/webview.dart';

class ServiceButton extends StatelessWidget {
    const ServiceButton({super.key,
                         required this.assetPath,
                         required this.subtitle,
                         this.fullname,
                         required this.onPressed});

    final String assetPath;
    final String subtitle;
    final String? fullname;
    final void Function() onPressed;

    @override
    Widget build(BuildContext context) {
        final tooltipkey = GlobalKey<TooltipState>();

        return Tooltip(
            // Provide a global key with the "TooltipState" type to show
            // the tooltip manually when trigger mode is set to manual.
            key: tooltipkey,
            triggerMode: TooltipTriggerMode.manual,
            message: fullname ?? subtitle,

            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Theme.of(context).colorScheme.primaryContainer,
            ),

            textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),

            padding: const EdgeInsets.all(8.0),
            preferBelow: true,
            verticalOffset: MediaQuery.of(context).size.width * 0.2,

            child: TextButton(
                style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    padding: const EdgeInsets.all(8.0),
                    backgroundColor: primaryContainerColor(context),
                ),
                onPressed: onPressed,
                onLongPress: () {
                    // Show Tooltip programmatically on button tap.
                    tooltipkey.currentState?.ensureTooltipVisible();
                },
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        SizedBox(
                            height: MediaQuery.of(context).size.width * 0.25,
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: SvgPicture(AssetBytesLoader(assetPath))
                        ),

                        Flexible(
                            child: Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.fade,
                                maxLines: 2,
                                softWrap: true,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary
                                ),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}

class ServiceGrid extends StatelessWidget {
    const ServiceGrid({super.key, required this.children});
    final List<Widget> children;

    @override
    Widget build(BuildContext context) {
        return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                // width / height: fixed for *all* items
                childAspectRatio: 3 / 4,
            ),
            itemBuilder: (context, i) => children[i],
            itemCount: children.length,
            shrinkWrap: true,
            primary: true,
            padding: const EdgeInsets.all(8.0),
        );
    }
}

class ServiceTitle extends StatelessWidget {
    const ServiceTitle(this.text, {super.key});
    final String text;

    @override
    Widget build(BuildContext context) {
        return Center(
            child: Text(
                text,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                )
            )
        );
    }
}

class ServiceSubtitle extends StatelessWidget {
    const ServiceSubtitle(this.text, {super.key});
    final String text;

    @override
    Widget build(BuildContext context) {
        return Center(
            child: Text(
                text,
                style: Theme.of(context).textTheme.titleMedium,
            )
        );
    }
}

class GamesPage extends StatelessWidget {
    const GamesPage({super.key});

    @override
    Widget build(BuildContext context) {
        final children = <Widget>[
            ServiceButton(
                assetPath: 'assets/images/services/trex.svg.vec',
                subtitle: 'Динозаврик',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WebViewDino())
                ),
            ),
        ];

        return Scaffold(
            appBar: AppBar(
                title: const Text('Игры')
            ),

            body: ServiceGrid(
                children: children,
            )
        );
    }
}

class ServicesPage extends ConsumerWidget {
    const ServicesPage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        Future openLinkInWebView(final BuildContext context, final url) async {
            await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WebView(url: url))
            );
        }

        final useful = <Widget>[
            ServiceButton(
                assetPath: 'assets/images/services/courses.svg.vec',
                subtitle: 'МФК',
                fullname: 'Межфакультетские курсы',
                onPressed: () async => openLinkInWebView(context, 'https://lk.msu.ru/course'),
            ),

            ServiceButton(
                assetPath: 'assets/images/services/light-cmc-logo.svg.vec',
                subtitle: 'Сайт ВМК',
                fullname: 'Официальный сайт факультета ВМК МГУ',
                onPressed: () async => openLinkInWebView(context, 'https://cs.msu.ru/'),
            ),

            ServiceButton(
                assetPath: 'assets/images/services/join.svg.vec',
                subtitle: 'Профсоюз',
                fullname: 'Сайт профсоюза МГУ',
                onPressed: () async => openLinkInWebView(context, 'https://lk.msuprof.com'),
            ),

            ServiceButton(
                assetPath: 'assets/images/services/map.svg.vec',
                subtitle: 'Планы этажей',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapRoute())
                ),
            ),

            ServiceButton(
                assetPath: 'assets/images/services/trex.svg.vec',
                subtitle: 'Игры!',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GamesPage())
                ),
            ),

            if (UniScheduleConfiguration.studentDiskLink != null)
            ServiceButton(
                assetPath: 'assets/images/services/yandex_disk.svg.vec',
                subtitle: 'Студ. диск',
                fullname: 'Студенческий диск',
                onPressed: () async => openLinkInWebView(context, UniScheduleConfiguration.studentDiskLink),
            ),
        ];

        final application = <Widget>[
            if (UniScheduleConfiguration.supportVariants.isNotEmpty)
            ServiceButton(
                assetPath: 'assets/images/services/money.svg.vec',
                subtitle: 'Поддержать проект',
                onPressed: () => showDialog(
                    context: context,
                    builder: (final context) => AlertDialog(
                        title: const Text('Поддержать проект'),
                        content: Text(UniScheduleConfiguration.supportGoals),
                        actions: UniScheduleConfiguration.supportVariants.map(
                            (e) => ElevatedButton(
                                child: Text(e.label),
                                onPressed: () => launchLink(context, e.link)
                            )
                        )
                        .toList()
                    )
                )
            ),

            if (UniScheduleConfiguration.feedbackLink != null)
            ServiceButton(
                assetPath: 'assets/images/services/feedback.svg.vec',
                subtitle: 'Форма обратной связи',
                onPressed: () => openLinkInWebView(context, UniScheduleConfiguration.feedbackLink),
            ),

            ServiceButton(
                assetPath: 'assets/images/services/info.svg.vec',
                subtitle: 'О UniSchedule',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage())),
            ),
        ];

        return RefreshIndicator(
            onRefresh: () => refreshConfiguration(ref),
            child: ref.watch(uniScheduleConfigurationProvider).unwrapPrevious().when(
                loading: ()           => getLoadingIndicator(() => refreshSchedule(ref)),
                error: (error, stack) => getErrorContainer('Не удалось отобразить расписание'),
                data: (_)             => ListView(
                    primary: true,
                    children: <Widget>[
                        const ServiceTitle('Полезное'),
                        ServiceGrid(children: useful),
                        const ServiceTitle('Приложение'),
                        ServiceGrid(children: application),

                        ListTile(
                            leading: Icon(
                                Icons.settings,
                                size: MediaQuery.textScalerOf(context).scale(Theme.of(context).textTheme.titleLarge?.fontSize ?? 16.0),
                                color: Theme.of(context).colorScheme.primary
                            ),
                            title: Text(
                                'Настройки',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary
                                )
                            ),
                            onTap: () => Navigator.push(
                                context, MaterialPageRoute(builder: (context) => const SettingsPage())
                            ),
                        ),
                    ]
                ),
            )
        );
    }
}
