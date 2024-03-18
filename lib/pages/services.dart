import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../provider.dart';
import '../configuration.dart';
import '../utils.dart';

class ServiceButton extends StatelessWidget {
    const ServiceButton({
            required this.image,
            required this.subtitle,
            required this.onPressed,
            this.tooltip,
            super.key});

    final image;
    final subtitle;
    final onPressed;
    final tooltip;

    @override
    Widget build(BuildContext context) {
        return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                IconButton(
                    // TODO make it shrinkable for availability on small screens
                    icon: SizedBox(height: 80, width: 80, child: image),
                    tooltip: tooltip,
                    onPressed: onPressed,
                ),
                Text(subtitle, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,),
            ],
        );
    }
}

class ServicesPage extends ConsumerWidget {
    const ServicesPage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final services = [
            ServiceButton(
                image: SvgPicture(AssetBytesLoader('assets/images/services/write_us.svg.vec')),
                subtitle: 'Паблик профкома',
                onPressed: () => launchLink(context, 'https://vk.com/profkomvmk'),
            ),
            ServiceButton(
                image: SvgPicture(AssetBytesLoader('assets/images/services/study_office.svg.vec')),
                subtitle: 'Учебная часть',
                onPressed: () => launchLink(context, 'https://vk.com/profkomvmk'),
            ),
            ServiceButton(
                image: SvgPicture(AssetBytesLoader('assets/images/services/courses.svg.vec')),
                subtitle: 'МФК',
                onPressed: () {
                    print('hi');
                },
            ),
        ];

        return GridView.count(
            // Create a grid with 3 columns. If you change the scrollDirection to
            // horizontal, this produces 3 rows.
            crossAxisCount: 3,
            // Generate 100 widgets that display their index in the List.
            children: services.map(
                (s) => s,
                // (s) => Row(
                //     children: <Widget>[
                //         Spacer(),
                //         s,
                //         Spacer(),
                //     ],
                // )
            )
            .toList(),
        );
    }
}
