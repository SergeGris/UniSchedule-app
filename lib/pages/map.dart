
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../provider.dart';
import '../floormapselector.dart';
import '../globalkeys.dart';

class MapSvgViewer extends StatelessWidget {
    MapSvgViewer(this.svg, {super.key});

    AssetBytesLoader svg;

    @override
    Widget build(BuildContext context) {
        return Container(
            color: Colors.white, // For white background for all image
            child: Center(
                child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 10.0,
                    child: SvgPicture(svg),
                ),
            ),
        );
    }
}

class MapPage extends ConsumerWidget {
    const MapPage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final prefs = ref.watch(settingsProvider).value!;
        final universityId = prefs.getString('universityId');
        final buildingId = prefs.getString('buildingId');

        if (buildingsFloors[buildingId] == null
         || universityId == null /* TODO */
         || buildingId == null   /* TODO */) {
            return const SizedBox(); // TODO
        }

        final floorNumbers = buildingsFloors[buildingId]!;

        final floors = floorNumbers.map(
            (i) => AssetBytesLoader('assets/$universityId/$buildingId/floor-plan$i.svg.vec')
        )
        .toList();

        if (floors.length == 1) {
            return MapSvgViewer(floors[0]);
        }

        final initialFloor = buildingsFloors[buildingId]!.indexOf(1);
        print('$initialFloor $buildingId');

        return DefaultTabController(
            length: floors.length,
            initialIndex: initialFloor!,
            child: Scaffold(
                appBar: AppBar(
                    toolbarHeight: 0,
                    bottom: TabBar(
                        tabs: floorNumbers.map(
                            (number) => Tab(
                                child: Text(
                                    '$number',
                                    style: Theme.of(context).textTheme.titleMedium
                                )
                            )
                        )
                        .toList()
                    )
                ),

                body: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: floors.map((svg) => MapSvgViewer(svg)).toList()
                )
            ),
        );
    }
}
