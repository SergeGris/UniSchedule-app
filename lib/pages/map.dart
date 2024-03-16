
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../floormapselector.dart';
import '../provider.dart';

class MapSvgViewer extends StatelessWidget {
    MapSvgViewer(this.svg, {super.key});

    AssetBytesLoader svg;

    @override
    Widget build(BuildContext context) {
        return ColoredBox(
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

class MapPage extends ConsumerStatefulWidget {
    const MapPage({super.key});

    @override
    ConsumerState<MapPage> createState() => _MapPageState();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _MapPageState extends ConsumerState<MapPage> with TickerProviderStateMixin {
    TabController? _tabController;

    @override
    void dispose() {
        _tabController?.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final prefs = ref.watch(settingsProvider).value!;
        ref.watch(buildingProvider);
        final universityId = prefs.getString('universityId');
        final buildingId = prefs.getString('buildingId');

        if (buildingsFloors[buildingId] == null
         || universityId == null /* TODO */
         || buildingId == null   /* TODO */) {
            return const SizedBox(); // TODO
        }
        final floorNumbers = buildingsFloors[buildingId]!;

        final floors = floorNumbers.map(
            (i) => AssetBytesLoader('assets/plans/$universityId/$buildingId/floor-plan$i.svg.vec')
        )
        .toList();

        if (floors.length == 1) {
            return MapSvgViewer(floors[0]);
        }

        _tabController = TabController(length: floors.length, vsync: this, initialIndex: buildingsFloors[buildingId]!.indexOf(1));

        return Scaffold(
            appBar: AppBar(
                toolbarHeight: 0,
                bottom: TabBar(
                    controller: _tabController,
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
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: floors.map((svg) => MapSvgViewer(svg)).toList()
            )
        );
    }
}
