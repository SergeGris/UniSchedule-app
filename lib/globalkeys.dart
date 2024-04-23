
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

import './widgets/filledbutton.dart';

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
                                FilledButton(
                                    onPressed: () async {
                                        hideWarningBanner();
                                    },
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                                            (Set<MaterialState> states) => bannerColor.withOpacity(
                                                states.contains(MaterialState.pressed) ? 0.4 : 0.8
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
