
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

Future<void> openLinkInWebView(final BuildContext context, final String url) async {
    if (!await launchLink(context, url)) {
        debugPrint('failed to launch link $url');
    }
}
