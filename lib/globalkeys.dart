
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

    //TODO make a method of GlobalKeys
    static void showWarningBanner(String text) {
        // See reason of Future(() async { ... }) at <https://stackoverflow.com/a/63607696>.
        Future(
            () async {
                final globalScaffoldMessanger = GlobalKeys.globalScaffold;

                if (!haveWarningBanner) {
                    haveWarningBanner = true;

                    globalScaffoldMessanger.showMaterialBanner(
                        MaterialBanner(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            content: Text(text),
                            leading: Icon(Icons.warning_amber, color: Colors.black),
                            backgroundColor: Colors.yellow,
                            contentTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),
                            actions: <Widget>[
                                TextButton(
                                    onPressed: () {
                                        Future(
                                            () async {
                                                hideWarningBanner();
                                            }
                                        );
                                    },
                                    child: Text('Понятно'),
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
