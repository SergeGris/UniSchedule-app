
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

import '../../floormapselector.dart';
import '../../provider.dart';

class MapSvgViewer extends StatelessWidget {
    const MapSvgViewer(this.svg, {super.key});

    final AssetBytesLoader svg;

    @override
    Widget build(BuildContext context) => ColoredBox(
        color: Colors.white, // For white background for all image
        child: Center(
            child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 10.0,
                child: SvgPicture(svg),
            ),
        ),
    );
}

class MapRoute extends StatelessWidget {
    const MapRoute({super.key});

    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('План этажей')),
        body: const Column(
            children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: FloorMapSelectorButton(),
                ),
                Expanded(child: MapPage()),
            ],
        ),
    );
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

        if (buildingsData[buildingId] == null
            || universityId == null
            || buildingId == null) {
            return Center(
                child: Text(
                    'Выберите корпус',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                    ),
                ),
            );
        }

        final floorNumbers = buildingsData[buildingId]!.floors;

        final floors = floorNumbers.map(
            (i) => AssetBytesLoader('assets/plans/$universityId/$buildingId/floor-plan$i.svg.vec'),
        )
        .toList();

        if (floors.length == 1) {
            return MapSvgViewer(floors[0]);
        }

        _tabController = TabController(
            length: floors.length,
            vsync: this,
            initialIndex: buildingsData[buildingId]?.floors.indexOf(1) ?? 0,
        );

        return Scaffold(
            appBar: AppBar(
                toolbarHeight: 0,
                bottom: TabBar(
                    controller: _tabController,
                    tabs: floorNumbers.map(
                        (number) => Tab(child: Text('$number')),
                    )
                    .toList(),
                )
            ),

            body: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: floors.map((svg) => MapSvgViewer(svg)).toList(),
            )
        );
    }
}
