
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../floormapselector.dart';
import '../../provider.dart';

class MapSvgViewer extends StatelessWidget {
    MapSvgViewer(this.svg, {super.key});

    final AssetBytesLoader svg;

    @override
    Widget build(BuildContext context) {
        return ColoredBox(
            color: Colors.white, // For white background for all image
            child: Center(
                child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 10.0,
                    child: SvgPicture(svg),
                ),
            ),
        );
    }
}

class MapRoute extends StatelessWidget {
    const MapRoute({super.key});

    @override
    Widget build(BuildContext context) {
        return  Scaffold(
            appBar: AppBar(
                title: const Text('План этажей'),
                shadowColor: Theme.of(context).shadowColor,
                bottom: const Tab(
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: FloorMapSelectorButton()
                    ),
                ),
            ),
            body: const MapPage()
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
            || universityId == null
            || buildingId == null) {
            return Center(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                        child: Text(
                            'Выберете корпус',
                            style: TextStyle(
                                fontSize: Theme.of(context).textTheme.displayMedium?.fontSize,
                                color: Theme.of(context).colorScheme.onPrimaryContainer
                            ),
                        ),
                    ),
                ),
            );
        }
        final floorNumbers = buildingsFloors[buildingId]!;

        final floors = floorNumbers.map(
            (i) => AssetBytesLoader('assets/plans/$universityId/$buildingId/floor-plan$i.svg.vec')
        )
        .toList();

        if (floors.length == 1) {
            return MapSvgViewer(floors[0]);
        }

        _tabController = TabController(
            length: floors.length,
            vsync: this,
            initialIndex: buildingsFloors[buildingId]!.indexOf(1)
        );

        return Scaffold(
            appBar: AppBar(
                toolbarHeight: 0,
                bottom: TabBar(
                    controller: _tabController,
                    tabs: floorNumbers.map(
                        (number) => Tab(
                            child: Text(
                                '$number',
                                style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.titleMedium?.fontSize
                                )
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
