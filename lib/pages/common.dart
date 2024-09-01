
import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:vector_graphics/vector_graphics.dart';

// import './services/about.dart';
// import './services/map.dart';
// import './services/settings.dart';

// import '../configuration.dart';
// import '../provider.dart';
import '../utils.dart';

import './webview/webview.dart';

Future<void> openLinkInWebView(final BuildContext context, final String url) async {
    return AnimatedNavigator.push<void>(
        context,
        (context) => WebView(url: url)
    );
}

// class GamesPage extends StatelessWidget {
//     const GamesPage({super.key});

//     @override
//     Widget build(BuildContext context) {
//         final children = <Widget>[
//             ServiceButton(
//                 assetPath: 'assets/images/services/trex.svg.vec',
//                 subtitle: 'Динозаврик',
//                 onPressed: () async => AnimatedNavigator.push<void>(
//                     context,
//                     (context) => const WebViewDino()
//                 ),
//             ),
//         ];

//         return Scaffold(
//             appBar: AppBar(title: const Text('Игры')),
//             body: ServiceGrid(children: children)
//         );
//     }
// }
