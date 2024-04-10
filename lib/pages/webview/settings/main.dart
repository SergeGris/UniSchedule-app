import 'package:flutter/material.dart';
import '../webview_model.dart';
import './android_settings.dart';
import './cross_platform_settings.dart';
// import './ios_settings.dart';
//import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../custom_popup_menu_item.dart';

class PopupSettingsMenuActions {
  // ignore: constant_identifier_names
  static const String RESET_BROWSER_SETTINGS = "Reset Browser Settings";
  // ignore: constant_identifier_names
  static const String RESET_WEBVIEW_SETTINGS = "Reset WebView Settings";

  static const List<String> choices = <String>[
    RESET_BROWSER_SETTINGS,
    RESET_WEBVIEW_SETTINGS,
  ];
}

class SettingsPage extends StatefulWidget {
    const SettingsPage(this.webViewModel, {super.key});

    final webViewModel;

    @override
    State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
    @override
    Widget build(BuildContext context) {
        return DefaultTabController(
            length: 3,
            child: Scaffold(
                appBar: AppBar(
                    bottom: TabBar(
                        onTap: (value) {
                            FocusScope.of(context).unfocus();
                        },
                        tabs: const [
                            Tab(
                                text: "Cross-Platform",
                                icon: SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: CircleAvatar(
                                        backgroundImage: AssetImage("assets/icon/icon.png"),
                                    ),
                                ),
                            ),
                            Tab(
                                text: "Android",
                                icon: Icon(
                                    Icons.android,
                                    color: Colors.green,
                                ),
                            ),
                            Tab(
                                text: "iOS",
                                icon: Icon(Icons.phone) //TODO TODO TODOIcon(AntDesign.apple1),
                            ),
                    ]),
                    title: const Text(
                        "Settings",
                    ),
                    actions: <Widget>[
                        PopupMenuButton<String>(
                            onSelected: _popupMenuChoiceAction,
                            itemBuilder: (context) {
                                var items = [
                                    CustomPopupMenuItem<String>(
                                        enabled: true,
                                        value: PopupSettingsMenuActions.RESET_BROWSER_SETTINGS,
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: const [
                                                Text(PopupSettingsMenuActions.RESET_BROWSER_SETTINGS),
                                                Icon(
                                                    Icons.phone, //TODO TODOFoundation.web,
                                                    color: Colors.black,
                                                )
                                        ]),
                                    ),
                                    CustomPopupMenuItem<String>(
                                        enabled: true,
                                        value: PopupSettingsMenuActions.RESET_WEBVIEW_SETTINGS,
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: const [
                                                Text(PopupSettingsMenuActions.RESET_WEBVIEW_SETTINGS),
                                                Icon(
                                                    Icons.phone, //TODO TODO TODO MaterialIcons.web,
                                                    color: Colors.black,
                                                )
                                        ]),
                                    )
                                ];

                                return items;
                            },
                        )
                    ],
                ),
                body: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                        CrossPlatformSettings(widget.webViewModel),
                        AndroidSettings(widget.webViewModel),
                        // IOSSettings(),
                    ],
                ),
        ));
    }

  void _popupMenuChoiceAction(String choice) async {
    switch (choice) {
      case PopupSettingsMenuActions.RESET_WEBVIEW_SETTINGS:
        var currentWebViewModel = widget.webViewModel;
        var webViewController = currentWebViewModel.webViewController;
        await webViewController?.setSettings(
            settings: InAppWebViewSettings(
                //incognito: currentWebViewModel.isIncognitoMode,
                useOnDownloadStart: true,
                useOnLoadResource: true,
                safeBrowsingEnabled: true,
                allowsLinkPreview: false,
                isFraudulentWebsiteWarningEnabled: true)
        );
        currentWebViewModel.settings = await webViewController?.getSettings();
        setState(() {});
        break;
    }
  }
}
