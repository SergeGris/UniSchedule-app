import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

//TODO

//import 'package:webview_flutter/webview_flutter.dart';//TODO

import './services/about.dart';
import './services/map.dart';
import './services/settings.dart';

import '../configuration.dart';
import '../globalkeys.dart';
import '../provider.dart';
import '../utils.dart';
import './webview/webview.dart';

class ServiceButton extends StatelessWidget {
    const ServiceButton({
            super.key,
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
        final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();

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
            padding: const EdgeInsets.all(8.0),
            preferBelow: true,
            textStyle: TextStyle(fontSize: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).colorScheme.onPrimaryContainer),
            verticalOffset: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.2,

            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    padding: const EdgeInsets.all(8.0),
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
                            height: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.25,
                            width: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.25,
                            child: SvgPicture(AssetBytesLoader(assetPath))
                        ),

                        Flexible(
                            child: Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.fade,
                                maxLines: 2,
                                softWrap: true,
                                style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium?.fontSize),
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
                childAspectRatio: 3 / 4 //0.618033988751, //0.75, // TODO
            ),
            itemBuilder: (context, i) => children[i],
            itemCount: children.length,
            shrinkWrap: true,
            primary: true,
            padding: const EdgeInsets.all(8.0),
            //crossAxisSpacing: 8.0,
            //mainAxisSpacing: 8.0,
            //crossAxisCount: 3,
        );
    }

    // @override
    // Widget build(BuildContext context) {
    //     return GridView.count(
    //         physics: NeverScrollableScrollPhysics(),
    //         shrinkWrap: true,
    //         primary: true,
    //         padding: const EdgeInsets.all(8.0),
    //         crossAxisSpacing: 8.0,
    //         mainAxisSpacing: 8.0,
    //         crossAxisCount: 3,
    //         children: children,
    //     );
    // }
}

class ServiceTitle extends StatelessWidget {
    const ServiceTitle(this.text, {super.key});
    final String text;

    @override
    Widget build(BuildContext context) {
        return Center(
            child: Text(
                text,
                style: TextStyle(fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize)
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
                style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium?.fontSize)
            )
        );
    }
}

class ServicesPage extends ConsumerWidget {
    const ServicesPage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        Future openLinkInWebView(final BuildContext context, final url) async {
            // TODO
            // await Permission.camera.request();
            // await Permission.microphone.request();
            // await Permission.storage.request();

            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WebView(url: url)
                )
            );
        }


        GlobalKeys.hideWarningBanner();

        final useful = <Widget>[
            // ServiceButton(
            //     assetPath: 'assets/images/services/write_us.svg.vec',
            //     subtitle: 'Профком в ВК',
            //     fullname: 'Паблик профкома '
            //     onPressed: () => launchLink(context, 'https://vk.com/profkomvmk'),
            // ),

            ServiceButton(
                assetPath: 'assets/images/services/courses.svg.vec',
                subtitle: 'МФК',
                fullname: 'Межфакультетские курсы',
                onPressed: () async => openLinkInWebView(context, 'https://lk.msu.ru/course'),
            ),

            ServiceButton(
                assetPath: 'assets/images/services/cmc-logo.svg.vec',
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
                subtitle: 'Динозаврик!',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WebViewDino())
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
                    builder: (final context) => AlertDialog( // TODO Change to dialog
                        title: const Text('Поддержать проект'),
                        content: Text(UniScheduleConfiguration.supportGoals),
                        actions: UniScheduleConfiguration.supportVariants.map(
                            (e) => ElevatedButton(
                                child: Text(e.label),
                                onPressed: () => launchLink(context, e.link))
                        ).toList()
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
                    //shrinkWrap: true,
                    primary: true,
                    children: <Widget>[
                        const ServiceTitle('Полезное'),
                        ServiceGrid(children: useful),
                        const ServiceTitle('Приложение'),
                        ServiceGrid(children: application),

                        ListTile(
                            leading: const Icon(Icons.settings),
                            title: const Text('Настройки'),
                            onTap: () => Navigator.push(
                                context, MaterialPageRoute(builder: (context) => const SettingsPage())
                            ),
                        ),

                        // ListTile(
                        //     leading: Icon(Icons.calculate),
                        //     title: const Text('Калькулятор твоей нищенской стипы'),
                        //     onTap: () => Navigator.push(
                        //         context, MaterialPageRoute(builder: (context) => const StipuhaPage())
                        //     ),
                        // ),
                    ]
                ),
            )
        );
    }
}
