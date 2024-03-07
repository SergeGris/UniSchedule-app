
import 'package:flutter/material.dart';

// Because of the opened issue <https://github.com/flutter/flutter/issues/89705>.
// We do as said here <https://github.com/flutter/flutter/issues/89705#issuecomment-1872540014>.
class GlobalKeys {
    static final globalScaffoldKey = GlobalKey<ScaffoldMessengerState>();

    static ScaffoldMessengerState get globalScaffold {
        final context = globalScaffoldKey.currentState;

        if (context == null) {
            throw Exception('ScaffoldMessengerContext not found. You must initialize it in the MaterialApp widget before using it');
        }

        return context;
    }

    static void showWarningBanner(String text) {
        // See reason of Future(() async { ... }) at <https://stackoverflow.com/a/63607696>.
        Future(
            () async {
                final globalScaffoldMessanger = GlobalKeys.globalScaffold;
                const textColor = Colors.black;
                const bannerColor = Colors.yellow;

                if (!haveWarningBanner) {
                    haveWarningBanner = true;

                    globalScaffoldMessanger.showMaterialBanner(
                        MaterialBanner(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            content: Text(text),
                            leading: const Icon(Icons.warning_amber, color: textColor),
                            backgroundColor: bannerColor,
                            contentTextStyle: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
                            actions: <Widget>[
                                ElevatedButton(
                                    onPressed: () async {
                                        hideWarningBanner();
                                    },
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                                            (Set<MaterialState> states) => bannerColor.withOpacity(
                                                states.contains(MaterialState.pressed) ? 1.0 : 0.8
                                            ),
                                        ),
                                    ),
                                    child: const Text(
                                        'Понятно',
                                        style: TextStyle(color: textColor)
                                    ),
                                ),
                            ],
                        )
                    );
                }
            }
        );
    }

    static void hideWarningBanner() {
        if (haveWarningBanner) {
            haveWarningBanner = false;
            final globalScaffoldMessanger = GlobalKeys.globalScaffold;
            globalScaffoldMessanger.hideCurrentMaterialBanner();
        }
    }

    static bool haveWarningBanner = false;
}
