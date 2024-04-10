import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../webview_model.dart';
import '../util.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../project_info_popup.dart';

class CrossPlatformSettings extends StatefulWidget {
    const CrossPlatformSettings(this.webViewModel, {super.key});

    final webViewModel;

    @override
    State<CrossPlatformSettings> createState() => _CrossPlatformSettingsState();
}

class _CrossPlatformSettingsState extends State<CrossPlatformSettings> {
    final TextEditingController _customHomePageController = TextEditingController();
    final TextEditingController _customUserAgentController = TextEditingController();

    @override
    void dispose() {
        _customHomePageController.dispose();
        _customUserAgentController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return ListView(
            children: _buildBaseSettings(),
        );
    }

    List<Widget> _buildBaseSettings() {
        var widgets = <Widget>[
            const ListTile(
                title: Text("Настройки браузера"),
                enabled: false,
            ),

            FutureBuilder(
                future: InAppWebViewController.getDefaultUserAgent(),
                builder: (context, snapshot) {
                    var deafultUserAgent = snapshot.hasData ? snapshot.data as String : '';

                    return ListTile(
                        title: const Text("Default User Agent"),
                        subtitle: Text(deafultUserAgent),
                        onLongPress: () {
                            Clipboard.setData(ClipboardData(text: deafultUserAgent));
                        },
                    );
                },
            ),

            SwitchListTile(
                title: const Text("Debugging Enabled"),
                subtitle: const Text(
                    "Enables debugging of web contents loaded into any WebViews of this application. On iOS < 16.4, the debugging mode is always enabled."),
                value: widget.webViewModel?.settings?.isInspectable,
                onChanged: (value) {
                    setState(
                        () {
                            if (Util.isAndroid()) {
                                // TODO InAppWebViewController.setWebContentsDebuggingEnabled(settings.debuggingEnabled);
                            }
                            widget.webViewModel?.settings?.isInspectable = value;
                            widget.webViewModel?.webViewController?.setSettings(
                                settings: widget.webViewModel.settings ?? InAppWebViewSettings()
                            );
                        },
                    );
                },
            ),

            FutureBuilder(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                    String packageDescription = '';
                    if (snapshot.hasData) {
                        PackageInfo packageInfo = snapshot.data as PackageInfo;
                        packageDescription =
                        "Package Name: ${packageInfo.packageName}\nVersion: ${packageInfo.version}\nBuild Number: ${packageInfo.buildNumber}";
                    }
                    return ListTile(
                        title: const Text("Flutter Browser Package Info"),
                        subtitle: Text(packageDescription),
                        onLongPress: () {
                            Clipboard.setData(ClipboardData(text: packageDescription));
                        },
                    );
                },
            ),

            ListTile(
                leading: Container(
                    height: 35,
                    width: 35,
                    margin: const EdgeInsets.only(top: 6.0, left: 6.0),
                    child: const CircleAvatar(
                        backgroundImage: AssetImage("assets/icon/icon.png")),
                ),
                title: const Text("Flutter InAppWebView Project"),
                subtitle: const Text("https://github.com/pichillilorenzo/flutter_inappwebview"),
                trailing: const Icon(Icons.arrow_forward),
                onLongPress: () {
                    showGeneralDialog(
                        context: context,
                        barrierDismissible: false,
                        pageBuilder: (context, animation, secondaryAnimation) {
                            return const ProjectInfoPopup();
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                    );
                },
                onTap: () {
                    showGeneralDialog(
                        context: context,
                        barrierDismissible: false,
                        pageBuilder: (context, animation, secondaryAnimation) {
                            return const ProjectInfoPopup();
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                    );
                },
            )
        ];

        if (Util.isAndroid()) {
            widgets.addAll(<Widget>[
                    FutureBuilder(
                        future: InAppWebViewController.getCurrentWebViewPackage(),
                        builder: (context, snapshot) {
                            String packageDescription = "";
                            if (snapshot.hasData) {
                                WebViewPackageInfo packageInfo = snapshot.data as WebViewPackageInfo;
                                packageDescription = "${packageInfo.packageName ?? ""} - ${packageInfo.versionName ?? ""}";
                            }
                            return ListTile(
                                title: const Text("WebView Package Info"),
                                subtitle: Text(packageDescription),
                                onLongPress: () {
                                    Clipboard.setData(ClipboardData(text: packageDescription));
                                },
                            );
                        },
                    )
            ]);
        }

        return widgets;
    }

    List<Widget> _buildWebViewTabSettings() {
        var currentWebViewModel = widget.webViewModel;
        var webViewController = currentWebViewModel.webViewController;

        var widgets = <Widget>[
            const ListTile(
                title: Text("Current WebView Settings"),
                enabled: false,
            ),
            SwitchListTile(
                title: const Text("JavaScript Enabled"),
                subtitle:
                const Text("Sets whether the WebView should enable JavaScript."),
                value: currentWebViewModel.settings?.javaScriptEnabled ?? true,
                onChanged: (value) async {
                    currentWebViewModel.settings?.javaScriptEnabled = value;
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ?? InAppWebViewSettings());
                    currentWebViewModel.settings = await webViewController?.getSettings();
                    setState(() {});
                },
            ),

            SwitchListTile(
                title: const Text("Cache Enabled"),
                subtitle:
                const Text("Sets whether the WebView should use browser caching."),
                value: currentWebViewModel.settings?.cacheEnabled ?? true,
                onChanged: (value) async {
                    currentWebViewModel.settings?.cacheEnabled = value;
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ?? InAppWebViewSettings()
                    );
                    currentWebViewModel.settings = await webViewController?.getSettings();
                    setState(() {});
                },
            ),

            StatefulBuilder(
                builder: (context, setState) {
                    return ListTile(
                        title: const Text("Custom User Agent"),
                        subtitle: Text(
                            currentWebViewModel.settings?.userAgent?.isNotEmpty ?? false
                            ? currentWebViewModel.settings!.userAgent!
                            : 'Set a custom user agent ...'),
                        onTap: () {
                            _customUserAgentController.text = currentWebViewModel.settings?.userAgent ?? '';

                            showDialog(
                                context: context,
                                builder: (context) {
                                    return AlertDialog(
                                        contentPadding: const EdgeInsets.all(0.0),
                                        content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                                ListTile(
                                                    title: Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: <Widget>[
                                                            Expanded(
                                                                child: TextField(
                                                                    onSubmitted: (value) async {
                                                                        currentWebViewModel.settings?.userAgent =
                                                                        value;
                                                                        webViewController?.setSettings(
                                                                            settings:
                                                                            currentWebViewModel.settings ??
                                                                            InAppWebViewSettings());
                                                                        currentWebViewModel.settings =
                                                                        await webViewController?.getSettings();
                                                                        setState(
                                                                            () {
                                                                                Navigator.pop(context);
                                                                            }
                                                                        );
                                                                    },
                                                                    decoration: const InputDecoration(
                                                                        hintText: 'Custom User Agent'
                                                                    ),
                                                                    controller: _customUserAgentController,
                                                                    keyboardType: TextInputType.multiline,
                                                                    textInputAction: TextInputAction.go,
                                                                    maxLines: null,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        ),
                                    );
                                },
                            );
                        },
                    );
                },
            ),

            SwitchListTile(
                title: const Text("Support Zoom"),
                subtitle: const Text(
                    "Sets whether the WebView should not support zooming using its on-screen zoom controls and gestures."),
                value: currentWebViewModel.settings?.supportZoom ?? true,
                onChanged: (value) async {
                    currentWebViewModel.settings?.supportZoom = value;
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ?? InAppWebViewSettings());
                    currentWebViewModel.settings = await webViewController?.getSettings();
                    setState(() {});
                },
            ),
            SwitchListTile(
                title: const Text("Media Playback Requires User Gesture"),
                subtitle: const Text(
                    "Sets whether the WebView should prevent HTML5 audio or video from autoplaying."),
                value: currentWebViewModel.settings?.mediaPlaybackRequiresUserGesture ??
                true,
                onChanged: (value) async {
                    currentWebViewModel.settings?.mediaPlaybackRequiresUserGesture =
                    value;
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ?? InAppWebViewSettings());
                    currentWebViewModel.settings = await webViewController?.getSettings();
                    setState(() {});
                },
            ),
            SwitchListTile(
                title: const Text("Vertical ScrollBar Enabled"),
                subtitle: const Text(
                    "Sets whether the vertical scrollbar should be drawn or not."),
                value: currentWebViewModel.settings?.verticalScrollBarEnabled ?? true,
                onChanged: (value) async {
                    currentWebViewModel.settings?.verticalScrollBarEnabled = value;
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ?? InAppWebViewSettings());
                    currentWebViewModel.settings = await webViewController?.getSettings();
                    setState(() {});
                },
            ),
            SwitchListTile(
                title: const Text("Horizontal ScrollBar Enabled"),
                subtitle: const Text(
                    "Sets whether the horizontal scrollbar should be drawn or not."),
                value: currentWebViewModel.settings?.horizontalScrollBarEnabled ?? true,
                onChanged: (value) async {
                    currentWebViewModel.settings?.horizontalScrollBarEnabled = value;
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ?? InAppWebViewSettings());
                    currentWebViewModel.settings = await webViewController?.getSettings();
                    setState(() {});
                },
            ),
            SwitchListTile(
                title: const Text("Disable Vertical Scroll"),
                subtitle: const Text(
                    "Sets whether vertical scroll should be enabled or not."),
                value: currentWebViewModel.settings?.disableVerticalScroll ?? false,
                onChanged: (value) async {
                    currentWebViewModel.settings?.disableVerticalScroll = value;
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ?? InAppWebViewSettings());
                    currentWebViewModel.settings = await webViewController?.getSettings();
                    setState(() {});
                },
            ),
            SwitchListTile(
                title: const Text("Disable Horizontal Scroll"),
                subtitle: const Text(
                    "Sets whether horizontal scroll should be enabled or not."),
                value: currentWebViewModel.settings?.disableHorizontalScroll ?? false,
                onChanged: (value) async {
                    currentWebViewModel.settings?.disableHorizontalScroll = value;
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ?? InAppWebViewSettings());
                    currentWebViewModel.settings = await webViewController?.getSettings();
                    setState(() {});
                },
            ),
            SwitchListTile(
                title: const Text("Disable Context Menu"),
                subtitle:
                const Text("Sets whether context menu should be enabled or not."),
                value: currentWebViewModel.settings?.disableContextMenu ?? false,
                onChanged: (value) async {
                    currentWebViewModel.settings?.disableContextMenu = value;
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ?? InAppWebViewSettings());
                    currentWebViewModel.settings = await webViewController?.getSettings();
                    setState(() {});
                },
            ),
            ListTile(
                title: const Text("Minimum Font Size"),
                subtitle: const Text("Sets the minimum font size."),
                trailing: SizedBox(
                    width: 50.0,
                    child: TextFormField(
                        initialValue:
                        currentWebViewModel.settings?.minimumFontSize.toString(),
                        keyboardType: const TextInputType.numberWithOptions(),
                        onFieldSubmitted: (value) async {
                            currentWebViewModel.settings?.minimumFontSize = int.parse(value);
                            webViewController?.setSettings(
                                settings:
                                currentWebViewModel.settings ?? InAppWebViewSettings());
                            currentWebViewModel.settings =
                            await webViewController?.getSettings();
                            setState(() {});
                        },
                    ),
                ),
            ),
            SwitchListTile(
                title: const Text("Allow File Access From File URLs"),
                subtitle: const Text(
                    "Sets whether JavaScript running in the context of a file scheme URL should be allowed to access content from other file scheme URLs."),
                value:
                currentWebViewModel.settings?.allowFileAccessFromFileURLs ?? false,
                onChanged: (value) async {
                    currentWebViewModel.settings?.allowFileAccessFromFileURLs = value;
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ?? InAppWebViewSettings());
                    currentWebViewModel.settings = await webViewController?.getSettings();
                    setState(() {});
                },
            ),
            SwitchListTile(
                title: const Text("Allow Universal Access From File URLs"),
                subtitle: const Text(
                    "Sets whether JavaScript running in the context of a file scheme URL should be allowed to access content from any origin."),
                value: currentWebViewModel.settings?.allowUniversalAccessFromFileURLs ??
                false,
                onChanged: (value) async {
                    currentWebViewModel.settings?.allowUniversalAccessFromFileURLs =
                    value;
                    webViewController?.setSettings(
                        settings: currentWebViewModel.settings ?? InAppWebViewSettings());
                    currentWebViewModel.settings = await webViewController?.getSettings();
                    setState(() {});
                },
            ),
        ];

        return widgets;
    }
}
