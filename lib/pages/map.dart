import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MapSvgViewer extends StatelessWidget {
    MapSvgViewer(this.svg, {super.key});

    AssetBytesLoader svg;

    @override
    Widget build(BuildContext context) {
        return Container(
            color: Colors.white,
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

class MapPage extends StatelessWidget {
    const MapPage({super.key});

    @override
    Widget build(BuildContext context) {
        final floorNumbers = [1, 2];
        final floors = floorNumbers.map(
            (i) => AssetBytesLoader('assets/cmc-floor-plan-$i.svg.vec')
        ).toList();

        return DefaultTabController(
            length: floors.length,
            child: Scaffold(
                appBar: AppBar(
                    toolbarHeight: 0,
                    bottom: TabBar(
                        tabs: floorNumbers.map(
                            (number) => Tab(
                                child: Text(
                                    '$number этаж',
                                    style: Theme.of(context).textTheme.titleMedium
                                )
                            )
                        )
                        .toList()
                    )
                ),

                body: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: floors.map(
                        (svg) => MapSvgViewer(svg)
                    )
                    .toList()
                )
            ),
        );

        // return SvgPicture(
        //     const AssetBytesLoader('assets/cmc-floor-plan-1.svg.vec')
        // );
    }
}
