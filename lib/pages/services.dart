
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
import './services/install.dart';

import '../configuration.dart';
import '../provider.dart';
import '../utils.dart';

// Conditional imports based on the platform
import 'common.dart' if (dart.library.html) 'web.dart';

class ServiceButton extends StatelessWidget {
    const ServiceButton({super.key,
                         required this.assetPath,
                         required this.name,
                         required this.onPressed});

    final String assetPath;
    final String name;
    final VoidCallback onPressed;

    @override
    Widget build(BuildContext context) {
        final tooltipkey = GlobalKey<TooltipState>();

        return Tooltip(
            // Provide a global key with the "TooltipState" type to show
            // the tooltip manually when trigger mode is set to manual.
            key: tooltipkey,
            triggerMode: TooltipTriggerMode.manual,
            message: name,

            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MediaQuery.textScalerOf(context).scale(8.0)),
                color: Theme.of(context).colorScheme.secondaryContainer,
            ),

            textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),

            padding: const EdgeInsets.all(8.0),
            preferBelow: true,
            verticalOffset: MediaQuery.of(context).size.width * 0.17, // TODO: IDK why 0.17

            child: ElevatedButton(
                onPressed: onPressed,
                // Show Tooltip programmatically on button tap.
                onLongPress: () => tooltipkey.currentState?.ensureTooltipVisible(),
                style: ButtonStyle(
                    shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.textScalerOf(context).scale(8.0)
                            ),
                        )
                    ),

                    padding: const MaterialStatePropertyAll(
                        EdgeInsets.zero,
                    ),

                    backgroundColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.primaryContainer,
                    ),
                ),
                child: Padding(
                    padding: EdgeInsets.all(MediaQuery.textScalerOf(context).scale(8.0)),
                    child: SizedBox.square(
                        dimension: MediaQuery.of(context).size.width / 3,
                        child: SvgPicture(AssetBytesLoader(assetPath))
                    ),
                ),

                // child: Center(
                //     child: SizedBox(
                //     height: MediaQuery.of(context).size.width * 0.25,
                //     width: MediaQuery.of(context).size.width * 0.25,
                //     child: SvgPicture(AssetBytesLoader(assetPath))
                //     )
                // ),
                // footer: GridTileBar(
                //     subtitle: Text(
                //         subtitle,
                //         textAlign: TextAlign.center,
                //         overflow: TextOverflow.ellipsis,
                //         maxLines: 1,
                //         softWrap: true,
                //         style: Theme.of(context).textTheme.subtitleMedium?.copyWith(
                //             color: Theme.of(context).colorScheme.primary
                //         ),
                //     ),
                // ),
            ),

            // TextButton(
            //     style: TextButton.styleFrom(
            //         shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(
            //                 MediaQuery.textScalerOf(context).scale(8.0)
            //             )
            //         ),
            //         padding: const EdgeInsets.all(8.0),
            //         backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            //     ),
            //     onPressed: onPressed,
            //     // Show Tooltip programmatically on button tap.
            //     onLongPress: () => tooltipkey.currentState?.ensureTooltipVisible(),
            //     child: Column(
            //         mainAxisSize: MainAxisSize.min,
            //         children: <Widget>[
            //             SizedBox(
            //                 height: MediaQuery.of(context).size.width * 0.25,
            //                 width: MediaQuery.of(context).size.width * 0.25,
            //                 child: SvgPicture(AssetBytesLoader(assetPath))
            //             ),

            //             Flexible(
            //                 child: Text(
            //                     subtitle,
            //                     textAlign: TextAlign.center,
            //                     overflow: TextOverflow.ellipsis,
            //                     maxLines: 2,
            //                     softWrap: true,
            //                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
            //                         color: Theme.of(context).colorScheme.primary
            //                     ),
            //                 ),
            //             ),
            //         ],
            //     ),
            // ),
        );
    }
}

class ServiceGrid extends StatelessWidget {
    const ServiceGrid({super.key, required this.children});
    final List<Widget> children;

    @override
    Widget build(BuildContext context) => GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: MediaQuery.textScalerOf(context).scale(8.0),
            crossAxisSpacing: MediaQuery.textScalerOf(context).scale(8.0),
            // width / height: fixed for *all* items
            //childAspectRatio: 3 / 4,
        ),
        itemBuilder: (context, i) => children[i],
        itemCount: children.length,
        shrinkWrap: true,
        primary: true,
        padding: EdgeInsets.all(MediaQuery.textScalerOf(context).scale(8.0)),
    );
}

class ServiceTitle extends StatelessWidget {
    const ServiceTitle(this.text, {super.key});
    final String text;

    @override
    Widget build(BuildContext context) => Center(
        child: Text(
            text,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
            )
        )
    );
}

class ServiceSubtitle extends StatelessWidget {
    const ServiceSubtitle(this.text, {super.key});
    final String text;

    @override
    Widget build(BuildContext context) => Center(
        child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium,
        )
    );
}

class ServiceTile extends StatelessWidget {
    const ServiceTile({super.key, required this.iconData, required this.text, required this.onTap});

    final IconData iconData;
    final String text;
    final VoidCallback onTap;

    @override
    Widget build(BuildContext context) => ListTile(
        leading: Icon(
            iconData,
            size: MediaQuery.textScalerOf(context).scale(
                Theme.of(context).textTheme.titleLarge?.fontSize ?? 16.0,
            ),
            color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
            text,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
            )
        ),
        onTap: onTap,
    );
}

class ServicesPage extends ConsumerWidget {
    const ServicesPage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final useful = <Widget>[
            ServiceButton(
                assetPath: 'assets/images/services/courses.svg.vec',
                name: 'Межфакультетские курсы',
                onPressed: () async => openLinkInWebView(context, 'https://lk.msu.ru/course'),
            ),

            ServiceButton(
                assetPath: 'assets/images/services/light-cmc-logo.svg.vec',
                name: 'Официальный сайт факультета ВМК МГУ',
                onPressed: () async => openLinkInWebView(context, 'https://cs.msu.ru/'),
            ),

            ServiceButton(
                assetPath: 'assets/images/services/join.svg.vec',
                name: 'Сайт профсоюза МГУ',
                onPressed: () async => openLinkInWebView(context, 'https://lk.msuprof.com'),
            ),

            ServiceButton(
                assetPath: 'assets/images/services/map.svg.vec',
                name: 'Планы этажей',
                onPressed: () async => AnimatedNavigator.push<void>(
                    context,
                    (context) => const MapRoute()
                ),
            ),

            // ServiceButton(
            //     assetPath: 'assets/images/services/trex.svg.vec',
            //     subtitle: 'Игры!',
            //     onPressed: () async => AnimatedNavigator.push<void>(
            //         context,
            //         (context) => const GamesPage()
            //     ),
            // ),

            if (UniScheduleConfiguration.studentDiskLink != null)
            ServiceButton(
                assetPath: 'assets/images/services/yandex_disk.svg.vec',
                name: 'Студенческий диск',
                onPressed: () async => openLinkInWebView(context, UniScheduleConfiguration.studentDiskLink!),
            ),
        ];

        final application = <Widget>[
            if (UniScheduleConfiguration.supportVariants.isNotEmpty)
            ServiceButton(
                assetPath: 'assets/images/services/money.svg.vec',
                name: 'Поддержать проект',
                onPressed: () async => showDialog<void>(
                    context: context,
                    builder: (final context) => AlertDialog(
                        title: const Text('Поддержать проект'),
                        content: Text(UniScheduleConfiguration.supportGoals),
                        actions: UniScheduleConfiguration.supportVariants.map(
                            (e) => TextButton(
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
                name: 'Форма обратной связи',
                onPressed: () async => openLinkInWebView(context, UniScheduleConfiguration.feedbackLink!),
            ),

            ServiceButton(
                assetPath: 'assets/images/services/info.svg.vec',
                name: 'О UniSchedule',
                onPressed: () async => AnimatedNavigator.push<void>(
                    context, (context) => const AboutPage()
                ),
            ),
        ];

        return RefreshIndicator(
            onRefresh: () async => refreshConfiguration(ref),
            child: ref.watch(uniScheduleConfigurationProvider).unwrapPrevious().when(
                loading: ()           => getLoadingIndicator(() async => refreshSchedule(ref)),
                error: (error, stack) => getErrorContainer('Не удалось отобразить расписание'),
                data: (_)             => ListView(
                    primary: true,
                    children: <Widget>[
                        const ServiceTitle('Полезное'),
                        ServiceGrid(children: useful),

                        const ServiceTitle('Приложение'),
                        ServiceGrid(children: application),

                        const Divider(),

                        ServiceTile(
                            iconData: Icons.settings,
                            text: 'Настройки',
                            onTap: () async => AnimatedNavigator.push<void>(
                                context,
                                (context) => const SettingsPage(),
                            ),
                        ),

                        if (OS.isWeb)
                        ServiceTile(
                            iconData: Icons.system_update,
                            text: 'Установить приложение',
                            onTap: () async => AnimatedNavigator.push<void>(
                                context,
                                (context) => const InstallPage(),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}
