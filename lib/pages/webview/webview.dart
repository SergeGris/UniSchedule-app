
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

import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import 'long_press_alert_dialog.dart';

import './custom_popup_menu_item.dart';
import './webview_model.dart';
import '../../utils.dart';

const defaultDownloaderSendPortName = 'downloader_send_port';

abstract final class Util {
    static bool urlIsSecure(Uri url) => (url.scheme == 'https') || isLocalizedContent(url);

    static bool isLocalizedContent(Uri url) {
        return url.scheme == 'file'
            || url.scheme == 'chrome'
            || url.scheme == 'data'
            || url.scheme == 'javascript'
            || url.scheme == 'about';
    }
}

class WebViewDino extends StatelessWidget {
    const WebViewDino({super.key});

    @override
    Widget build(BuildContext context) {
        final initialSettings = InAppWebViewSettings();
        initialSettings.forceDark = isDarkMode(context) ? ForceDark.ON : ForceDark.OFF;

        return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(title: const Text('Динозаврик!')),
            body: InAppWebView(
                initialSettings: initialSettings,
                initialFile: 'assets/dino-runner/index.html',
            )
        );
    }
}

////////////

const kInitialTextSize = 100;
const kTextSizeMin = 20;
const kTextSizeMax = 200;
const kTextSizeDelta = 20;
const kTextSizePlaceholder = 'TEXT_SIZE_PLACEHOLDER';
const kTextSizeSourceJS = '''
window.addEventListener('DOMContentLoaded', function(event) {
  document.body.style.textSizeAdjust = '$kTextSizePlaceholder%';
  document.body.style.webkitTextSizeAdjust = '$kTextSizePlaceholder%';
});
''';

final textSizeUserScript = UserScript(
    source: kTextSizeSourceJS.replaceAll(kTextSizePlaceholder, '$kInitialTextSize'),
    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START
);

// class TaskInfo {
//   TaskInfo({this.name, this.link});

//   final String? name;
//   final String? link;

//   String? taskId;
//   int? progress = 0;
//   DownloadTaskStatus? status = DownloadTaskStatus.undefined;
// }


// class BrowserAppBar extends StatefulWidget implements PreferredSizeWidget {
//   const BrowserAppBar({super.key})
//       : preferredSize = const Size.fromHeight(kToolbarHeight);

//   @override
//   State<BrowserAppBar> createState() => _BrowserAppBarState();

//   @override
//   final Size preferredSize;
// }

// class _BrowserAppBarState extends State<BrowserAppBar> {
//   bool _isFindingOnPage = false;

//   @override
//   Widget build(BuildContext context) {
//     return _isFindingOnPage
//         ? FindOnPageAppBar(
//             hideFindOnPage: () {
//               setState(() {
//                 _isFindingOnPage = false;
//               });
//             },
//           )
//         : WebViewAppBar(
//           );
//   }
// }

class WebView extends StatefulWidget {
    WebView({super.key, required this.url, this.windowId})
        : webViewModel = WebViewModel(url: WebUri(url));

    final String url;
    final WebViewModel webViewModel;
    final int? windowId;

    @override
    State<WebView> createState() => _CustomInAppBrowserState();
}

enum MenuEntry {
    changeTextSize(null, null),
    copyLink(Icons.link, 'Скопировать ссылку'),
    findOnPage(Icons.search, 'Найти на странице'),
    openInBrowser(Icons.open_in_browser, 'Открыть в браузере'),
    desktopMode(null, null),
    clearCache(Icons.clear_all, 'Очистить кэш');

    const MenuEntry(this.icon, this.text);

    final IconData? icon;
    final String? text;

                                        // MenuItemButton(
                                        //     child: const Row(
                                        //         children: <Widget>[
                                        //             Icon(Icons.share),
                                        //             SizedBox(width: 8),
                                        //             Text('Поделиться'),
                                        //         ]
                                        //     ),
                                        //     onPressed: () async => _activate(MenuEntry.share),
                                        // ),

                                        // MenuItemButton(
                                        //     child: const Row(
                                        //         children: <Widget>[
                                        //             Icon(Icons.link),
                                        //             SizedBox(width: 8),
                                        //             Text('Скопировать ссылку'),
                                        //         ]
                                        //     ),
                                        //     onPressed: () async => _activate(MenuEntry.copyLink),
                                        // ),

                                        // MenuItemButton(
                                        //     child: const Row(
                                        //         children: <Widget>[
                                        //             Icon(Icons.open_in_browser),
                                        //             SizedBox(width: 8),
                                        //             Text('Открыть в браузере'),
                                        //         ]
                                        //     ),
                                        //     onPressed: () async => _activate(MenuEntry.openInBrowser),
                                        // ),

                                        // MenuItemButton(
                                        //     child: Row(
                                        //         children: <Widget>[
                                        //             Icon(
                                        //                 isDesktopMode
                                        //                 ? (OS.isAndroid
                                        //                     ? Icons.phone_android
                                        //                     : Icons.phone_iphone)
                                        //                 : Icons.laptop
                                        //             ),
                                        //             const SizedBox(width: 8),
                                        //             Text(isDesktopMode ? 'Мобильная версия' : 'Версия для ПК'),
                                        //         ],
                                        //     ),
                                        //     onPressed: () async => _activate(MenuEntry.desktopMode),
                                        // ),

                                        // MenuItemButton(
                                        //     child: const Row(
                                        //         children: <Widget>[
                                        //             Icon(Icons.clear_all),
                                        //             SizedBox(width: 8),
                                        //             Text('Очистить данные браузера')
                                        //         ],
                                        //     ),
                                        //     onPressed: () async => _activate(MenuEntry.clearCache),
                                        // ),

}

class _CustomInAppBrowserState extends State<WebView> {
    final GlobalKey webViewKey = GlobalKey();
    final GlobalKey menuKey = GlobalKey();

    String url = '';
    String title = '';
    double progress = 0.0;
    bool _isFindingOnPage = false;
    bool? isSecure;
    bool isDesktopMode = false;
    InAppWebViewController? webViewController;
    PullToRefreshController? _pullToRefreshController;
    FindInteractionController? _findInteractionController;
    int textSize = kInitialTextSize;
    final FocusNode _buttonFocusNode = FocusNode();
    final ReceivePort _port = ReceivePort();

    int? activeMatchOrdinal;
    int? numberOfMatches;
    bool? isDoneCounting;

    final TextEditingController _findOnPageController = TextEditingController();

    OutlineInputBorder outlineBorder = const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent, width: 0.0),
        // borderRadius: BorderRadius.all(
        //     Radius.circular(16.0),
        // ),
    );

    Future<void> toggleDesktopMode() async {
        if (webViewController != null) {
            setState(() => isDesktopMode = !isDesktopMode);

            final currentSettings = await webViewController!.getSettings();

            if (currentSettings != null) {
                currentSettings.preferredContentMode = isDesktopMode
                  ? UserPreferredContentMode.DESKTOP
                  : UserPreferredContentMode.RECOMMENDED;
                await webViewController!.setSettings(settings: currentSettings);
            }

            await webViewController!.reload();
        }

        return Future.value();
    }

    Future<bool> _goBack(BuildContext context) async {
        if (await webViewController?.canGoBack() ?? false) {
            await webViewController?.goBack();
            return Future.value(false);
        } else {
            return Future.value(true);
        }
    }

    Future<void> downloadFile(String url, [String? filename]) async {
        var hasStoragePermission = await Permission.storage.isGranted;

        if (!hasStoragePermission) {
            final status = await Permission.storage.request();
            hasStoragePermission = status.isGranted;
        }

        if (hasStoragePermission) {
            await FlutterDownloader.enqueue(
                url: url,
                headers: {},
                // optional: header send with url (auth token etc)
                savedDir: (await getTemporaryDirectory()).path,
                saveInPublicStorage: true,
                fileName: filename
            );
        }
    }

    Future<void> updateTextSize(int textSize) async {
        if (OS.isAndroid) {
            final currentSettings = await webViewController?.getSettings();

            if (currentSettings != null) {
                currentSettings.textZoom = textSize;
                await webViewController?.setSettings(settings: currentSettings);
            }
        } else {
            // Update current text size
            await webViewController?.evaluateJavascript(source: '''
document.body.style.textSizeAdjust = '$textSize%';
document.body.style.webkitTextSizeAdjust = '$textSize%';
''');

            // Update the User Script for the next page load
            await webViewController?.removeUserScript(userScript: textSizeUserScript);
            textSizeUserScript.source = kTextSizeSourceJS.replaceAll(kTextSizePlaceholder, '$textSize');
            await webViewController?.addUserScript(userScript: textSizeUserScript);
        }
    }

    @override
    void initState() {
        super.initState();
        url = widget.url;

        _bindBackgroundIsolate();
        FlutterDownloader.registerCallback(downloadCallback, step: 1); //TODO: async, but shall work idk
        _findInteractionController = FindInteractionController(
            onFindResultReceived: (PlatformFindInteractionController controller,
                                   int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting) {
                setState(
                    () {
                        this.activeMatchOrdinal = activeMatchOrdinal;
                        this.numberOfMatches = numberOfMatches;
                        this.isDoneCounting = isDoneCounting;
                    }
                );
            },
        );
    }

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        _pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
                backgroundColor: Theme.of(context).colorScheme.background,
                color: Theme.of(context).colorScheme.primary,
            ),
            onRefresh: () async => refresh(),
        );
    }

    @override
    void dispose() {
        _findOnPageController.dispose();
        webViewController = null;
        _findInteractionController = null;
        _unbindBackgroundIsolate();
        _buttonFocusNode.dispose();
        super.dispose();
    }

    void _bindBackgroundIsolate() {
        final isSuccess = IsolateNameServer.registerPortWithName(
            _port.sendPort,
            defaultDownloaderSendPortName,
        );

        if (!isSuccess) {
            _unbindBackgroundIsolate();
            _bindBackgroundIsolate();
            return;
        }

        _port.listen(
            (dynamic data) {
                // final taskId = data[0] as String;
                final status = DownloadTaskStatus.fromInt(data[1] as int);
                // final progress = data[2] as int;

                if (status == DownloadTaskStatus.complete) {
                    showSnackBar(
                        context,
                        const Text('Загрузка завершена')
                    );
                }
            }
        );
    }

    void _unbindBackgroundIsolate() {
        IsolateNameServer.removePortNameMapping(defaultDownloaderSendPortName);
    }

    @pragma('vm:entry-point')
    static void downloadCallback(String id, int status, int progress) {
        IsolateNameServer.lookupPortByName(defaultDownloaderSendPortName)?.send([id, status, progress]);
    }

    // Future<void> _requestDownload(TaskInfo task) async {
    //     task.taskId = await FlutterDownloader.enqueue(
    //         url: task.link!,
    //         headers: {}, // TODO {'auth': 'test_for_sql_encoding'},
    //         savedDir: _localPath,
    //         saveInPublicStorage: _saveInPublicStorage,
    //     );
    // }

    // Future<void> _pauseDownload(TaskInfo task) async {
    //     await FlutterDownloader.pause(taskId: task.taskId!);
    // }

    // Future<void> _resumeDownload(TaskInfo task) async {
    //     final newTaskId = await FlutterDownloader.resume(taskId: task.taskId!);
    //     task.taskId = newTaskId;
    // }

    // Future<void> _retryDownload(TaskInfo task) async {
    //     final newTaskId = await FlutterDownloader.retry(taskId: task.taskId!);
    //     task.taskId = newTaskId;
    // }

    // Future<bool> _openDownloadedFile(TaskInfo? task) async {
    //     final taskId = task?.taskId;

    //     if (taskId == null) {
    //         return false;
    //     }

    //     return FlutterDownloader.open(taskId: taskId);
    // }

    // Future<void> _delete(TaskInfo task) async {
    //     await FlutterDownloader.remove(
    //         taskId: task.taskId!,
    //         shouldDeleteContent: true,
    //     );
    //     setState(() {});
    // }

    // Future<bool> _checkPermission() async {
    //     if (Util.isIOS()) {
    //         return true;
    //     }

    //     if (Util.isAndroid()) {
    //         // TODO
    //         // final info = await DeviceInfoPlugin().androidInfo;
    //         // if (info.version.sdkInt > 28) {
    //         //     return true;
    //         // }

    //         if (await Permission.storage.status == PermissionStatus.granted) {
    //             return true;
    //         }

    //         return await Permission.storage.request() == PermissionStatus.granted;
    //     }

    //     throw StateError('unknown platform');
    // }

    // Future<void> _prepareSaveDir() async {
    //     _localPath = (await _getSavedDir())!;
    //     final savedDir = Directory(_localPath);

    //     if (!savedDir.existsSync()) {
    //         await savedDir.create();
    //     }
    // }

    // Future<String?> _getSavedDir() async {
    //     return (await getApplicationDocumentsDirectory()).absolute.path;
    // }

    Future<void> copyLink() async {
        if (url != '') {
            await Clipboard.setData(ClipboardData(text: url));
            showSnackBar(context, const Text('Ссылка скопирована в буфер обмена'));
        }
    }

    Future<void> refresh() async {
        if (OS.isAndroid) {
            await webViewController?.reload();
        } else if (OS.isIOS) {
            await webViewController?.loadUrl(urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
    }

    Future<void> _activate(MenuEntry selection) async {
        switch (selection) {
        case MenuEntry.findOnPage:
            setState(() => _isFindingOnPage = true);
            break;
        case MenuEntry.changeTextSize:
            break;
        case MenuEntry.copyLink:
             await copyLink();
             break;
        case MenuEntry.openInBrowser:
            await InAppBrowser.openWithSystemBrowser(url: WebUri(url));
            break;
        case MenuEntry.desktopMode:
            await toggleDesktopMode();
            break;
        case MenuEntry.clearCache:
            await showDialog<void>(
                context: context,
                builder: (final context) => AlertDialog(
                    title: const Text('Отчистить кэш браузера?'),
                    content: const Text('Обратите внимание: после отчистки кэша нужно будет заново заходить в аккаунты на всех сайтах.'),
                    actions: <Widget>[
                        ElevatedButton(
                            onPressed: () async {
                                await webViewController?.clearCache();
                                if (OS.isAndroid) {
                                    await webViewController?.clearHistory();
                                }
                                setState(() {});
                                Navigator.pop(context);
                                showSnackBar(context, const Text('Кэш браузера отчищен'));
                            },
                            child: const Text('Да'),
                        ),
                        ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Нет'),
                        )
                    ]
                )
            );
            break;
        }
    }

    @override
    Widget build(BuildContext context) {
        final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();
        final initialSettings = widget.webViewModel.settings ?? InAppWebViewSettings();

        initialSettings.iframeAllow = 'camera; microphone';
        initialSettings.iframeAllowFullscreen = true;
        initialSettings.mediaPlaybackRequiresUserGesture = false;
        initialSettings.allowsInlineMediaPlayback = true;

        initialSettings.useOnDownloadStart = true;
        initialSettings.useOnLoadResource = true;
        initialSettings.useShouldOverrideUrlLoading = true;
        initialSettings.javaScriptCanOpenWindowsAutomatically = true;
        //initialSettings.userAgent = "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36";
        initialSettings.transparentBackground = true;

        initialSettings.safeBrowsingEnabled = true;
        initialSettings.disableDefaultErrorPage = true;
        initialSettings.supportMultipleWindows = true;
        //initialSettings.verticalScrollbarThumbColor = const Color.fromRGBO(0, 0, 0, 0.5);
        //initialSettings.horizontalScrollbarThumbColor = const Color.fromRGBO(0, 0, 0, 0.5);

        initialSettings.allowsLinkPreview = false;
        initialSettings.isFraudulentWebsiteWarningEnabled = true;
        initialSettings.disableLongPressContextMenuOnLinks = true;
        initialSettings.textZoom = textSize;
        initialSettings.forceDark = isDarkMode(context) ? ForceDark.ON : ForceDark.OFF;
        //initialSettings.allowingReadAccessTo = WebUri('file./$WEB_ARCHIVE_DIR/');

        return PopScope(
            canPop: false,
            onPopInvoked: (bool didPop) async {
                if (didPop) {
                    return;
                }

                if (_isFindingOnPage) {
                    setState(() => _isFindingOnPage = false);
                    return;
                }

                if (await _goBack(context)) {
                    Navigator.pop(context);
                }
            },
            child: Scaffold(
                backgroundColor: Theme.of(context).colorScheme.background,
                appBar: _isFindingOnPage
                ? AppBar(
                    titleSpacing: 0.0,
                    leadingWidth: 0.0,
                    leading: const SizedBox.shrink(),
                    title: Row(
                        children: [
                            Expanded(
                                child: TextField(
                                    onChanged: (value) async => _findInteractionController?.findAll(find: value),
                                    autofocus: true,
                                    controller: _findOnPageController,
                                    textInputAction: TextInputAction.go,
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(8.0),
                                        filled: false,
                                        border: outlineBorder,
                                        focusedBorder: outlineBorder,
                                        enabledBorder: outlineBorder,
                                        hintText: 'Найти на странице...',
                                    ),
                                ),
                            ),
                            if (_findOnPageController.value.text.isNotEmpty && (isDoneCounting ?? false) && activeMatchOrdinal != null && numberOfMatches != null)
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    '${numberOfMatches! == 0 ? 0 : activeMatchOrdinal! + 1}/$numberOfMatches',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: numberOfMatches == 0
                                        ? Colors.red
                                        : Theme.of(context).colorScheme.primary,
                                    ),
                                )
                            ),
                        ]
                    ),
                    actions: <Widget>[
                        IconButton(
                            icon: const Icon(Icons.keyboard_arrow_up, size: 32),
                            onPressed: () async => _findInteractionController?.findNext(forward: false),
                        ),
                        IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                            onPressed: () async => _findInteractionController?.findNext(forward: true),
                        ),
                        IconButton(
                            icon: const Icon(Icons.close, size: 32),
                            onPressed: () async {
                                await _findInteractionController?.clearMatches();
                                _findOnPageController.text = '';
                                setState(() => _isFindingOnPage = false);
                            },
                        ),
                    ],
                )
                : AppBar(
                    titleSpacing: 0.0,
                    leading: widget.windowId != null
                    ? BackButton(onPressed: () => Navigator.pop(context))
                    : CloseButton(onPressed: () => Navigator.pop(context)),

                    title: InkWell(
                        onTap: () async => tooltipkey.currentState?.ensureTooltipVisible(),
                        onLongPress: () async => copyLink(),

                        child: Tooltip(
                            key: tooltipkey,
                            triggerMode: TooltipTriggerMode.manual,
                            message: title,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(MediaQuery.textScalerOf(context).scale(8.0)),
                                color: Theme.of(context).colorScheme.primary,
                            ),
                            preferBelow: true,
                            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            textAlign: TextAlign.center,

                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                    children: <Widget>[
                                        if (title != '' && title != url && !title.startsWith('data:'))
                                        Text(
                                            title,
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: Theme.of(context).colorScheme.primary
                                            ),
                                            overflow: TextOverflow.fade,
                                        ),
                                        if (url != '' && !url.startsWith('data:'))
                                        Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                                if (isSecure != null)
                                                (isSecure!
                                                    ? Icon(
                                                        Icons.lock,
                                                        color: Colors.green,
                                                        size: Theme.of(context).textTheme.titleSmall?.fontSize ?? 12
                                                    )
                                                    : Icon(
                                                        Icons.lock_open,
                                                        color: Colors.red,
                                                        size: Theme.of(context).textTheme.titleSmall?.fontSize ?? 12
                                                    )
                                                ),
                                                if (isSecure != null)
                                                const SizedBox(width: 4),
                                                Flexible(
                                                    child: Text(
                                                        url,
                                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                                        overflow: TextOverflow.fade,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    ),

                    actions: <Widget>[
                        IconButton(
                            key: menuKey,
                            icon: const Icon(Icons.more_vert),
                            onPressed: () async {
                                final RenderBox? box = menuKey.currentContext!.findRenderObject() as RenderBox?;

                                if (box == null) {
                                    return;
                                }

                                final position = box.localToGlobal(Offset.zero);

                                await showMenu<MenuEntry>(
                                    popUpAnimationStyle: AnimationStyle(
                                        duration: const Duration(milliseconds: 200)
                                    ),
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                        position.dx,
                                        position.dy + box.size.height,
                                        0,
                                        0
                                    ),
                                    items: [
                                        CustomPopupMenuItem<MenuEntry>(
                                            isIconButtonRow: true,
                                            child: StatefulBuilder(
                                                builder: (context, setState) => Row(
                                                    mainAxisSize: MainAxisSize.max,
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: <Widget>[
                                                        FutureBuilder<bool>(
                                                            future: webViewController?.canGoBack() ?? Future.value(false),
                                                            builder: (context, snapshot) {
                                                                final canGoBack = snapshot.hasData && snapshot.data!;

                                                                return IconButton(
                                                                    icon: const Icon(Icons.arrow_back),
                                                                    onPressed: canGoBack
                                                                    ? () {
                                                                        setState(() => webViewController?.goBack());
                                                                        Navigator.pop(context);
                                                                    }
                                                                    : null,
                                                                );
                                                            },
                                                        ),

                                                        FutureBuilder<bool>(
                                                            future: webViewController?.canGoForward() ?? Future.value(false),
                                                            builder: (context, snapshot) {
                                                                final canGoForward = snapshot.hasData && snapshot.data!;
                                                                return IconButton(
                                                                    icon: const Icon(Icons.arrow_forward),
                                                                    onPressed: canGoForward
                                                                    ? () {
                                                                        setState(() => webViewController?.goForward());
                                                                        Navigator.pop(context);
                                                                    }
                                                                    : null,
                                                                );
                                                            },
                                                        ),

                                                        IconButton(
                                                            icon: const Icon(Icons.share),
                                                            onPressed: () async {
                                                                await Share.share(url, subject: title);
                                                                Navigator.pop(context);
                                                            }
                                                        ),

                                                        IconButton(
                                                            icon: progress < 1.0
                                                            ? const Icon(Icons.close)
                                                            : const Icon(Icons.refresh),
                                                            onPressed: () async {
                                                                if (progress < 1.0) {
                                                                    await webViewController?.stopLoading();
                                                                } else {
                                                                    await refresh();
                                                                }
                                                                Navigator.pop(context);
                                                            }
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ),

                                        // const PopupMenuDivider(),

                                        // CustomPopupMenuItem<MenuEntry>(
                                        //     isIconButtonRow: true,
                                        //     child: StatefulBuilder(
                                        //         builder: (context, setState) => Row(
                                        //             mainAxisSize: MainAxisSize.max,
                                        //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        //             children: <Widget>[
                                        //                 IconButton(
                                        //                     onPressed: textSize < kTextSizeMax
                                        //                     ? () => setState(() async => await updateTextSize(textSize += kTextSizeDelta))
                                        //                     : null,
                                        //                     icon: Icon(
                                        //                         Icons.add,
                                        //                         color: textSize < kTextSizeMax
                                        //                         ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                                        //                     ),
                                        //                 ),

                                        //                 IconButton(
                                        //                     onPressed: textSize > kTextSizeMin
                                        //                     ? () => setState(() async => await updateTextSize(textSize -= kTextSizeDelta))
                                        //                     : null,
                                        //                     icon: Icon(
                                        //                         Icons.remove,
                                        //                         color: textSize > kTextSizeMin
                                        //                         ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                                        //                     ),
                                        //                 ),

                                        //                 TextButton(
                                        //                     onPressed: textSize != kInitialTextSize
                                        //                     ? () => setState(() async => await updateTextSize(textSize = kInitialTextSize))
                                        //                     : null,
                                        //                     child: Text(
                                        //                         '100%',
                                        //                         style: TextStyle(
                                        //                             color: textSize != kInitialTextSize
                                        //                             ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                                        //                         ),
                                        //                     ),
                                        //                 ),
                                        //             ],
                                        //         ),
                                        //     ),
                                        // ),

                                        const PopupMenuDivider(),

                                        PopupMenuItem<MenuEntry>(
                                            child: Row(
                                                children: <Widget>[
                                                    Icon(
                                                        isDesktopMode
                                                        ? (OS.isAndroid
                                                            ? Icons.phone_android
                                                            : Icons.phone_iphone)
                                                        : Icons.laptop
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(isDesktopMode ? 'Мобильная версия' : 'Версия для ПК'),
                                                ]
                                            ),
                                            value: MenuEntry.desktopMode,
                                        ),

                                        ...MenuEntry.values.where((e) => e != MenuEntry.desktopMode).map(
                                            (e) => e.icon == null || e.text == null
                                            ? null
                                            : PopupMenuItem<MenuEntry>(
                                                child: Row(
                                                    children: <Widget>[
                                                        Icon(e.icon!),
                                                        const SizedBox(width: 8),
                                                        Text(e.text!),
                                                    ]
                                                ),
                                                value: e,
                                            ),
                                        ).nonNulls.cast<PopupMenuItem<MenuEntry>>(),
                                    ]
                                ).then(
                                    (MenuEntry? action) async {
                                        if (action != null) {
                                            await _activate(action);
                                        }
                                    },
                                );
                            }
                        ),

                        // MenuAnchor(
                        //     consumeOutsideTap: true,

                        //     builder: (BuildContext context, MenuController controller, Widget? child) {
                        //         return IconButton(
                        //             focusNode: _buttonFocusNode,
                        //             onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                        //             icon: const Icon(Icons.more_vert),
                        //         );
                        //     },

                        //     menuChildren: <Widget>[
                        //         Row(
                        //             mainAxisSize: MainAxisSize.max,
                        //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //             children: <Widget>[
                        //                 IconButton(
                        //                     onPressed: textSize < kTextSizeMax
                        //                     ? () async {
                        //                         setState(() => textSize += kTextSizeDelta);
                        //                         await updateTextSize(textSize);
                        //                     }
                        //                     : null,
                        //                     icon: Icon(
                        //                         Icons.add,
                        //                         color: textSize < kTextSizeMax ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                        //                     ),
                        //                 ),
                        //                 IconButton(
                        //                     onPressed: textSize > kTextSizeMin
                        //                     ? () async {
                        //                         setState(() => textSize -= kTextSizeDelta);
                        //                         await updateTextSize(textSize);
                        //                     }
                        //                     : null,
                        //                     icon: Icon(
                        //                         Icons.remove,
                        //                         color: textSize > kTextSizeMin ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                        //                     ),
                        //                 ),
                        //                 TextButton(
                        //                     onPressed: textSize != kInitialTextSize
                        //                     ? () async {
                        //                         setState(() => textSize = kInitialTextSize);
                        //                         await updateTextSize(textSize);
                        //                     }
                        //                     : null,
                        //                     child: Text(
                        //                         '100%',
                        //                         style: TextStyle(
                        //                             color: textSize != kInitialTextSize ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                        //                         ),
                        //                     ),
                        //                 ),
                        //             ]
                        //         ),

                        //         const Divider(),

                        //         MenuItemButton(
                        //             child: const Row(
                        //                 children: <Widget>[
                        //                     Icon(Icons.share),
                        //                     SizedBox(width: 8),
                        //                     Text('Поделиться'),
                        //                 ]
                        //             ),
                        //             onPressed: () async => _activate(MenuEntry.share),
                        //         ),

                        //         MenuItemButton(
                        //             child: const Row(
                        //                 children: <Widget>[
                        //                     Icon(Icons.link),
                        //                     SizedBox(width: 8),
                        //                     Text('Скопировать ссылку'),
                        //                 ]
                        //             ),
                        //             onPressed: () async => _activate(MenuEntry.copyLink),
                        //         ),

                        //         MenuItemButton(
                        //             child: const Row(
                        //                 children: <Widget>[
                        //                     Icon(Icons.open_in_browser),
                        //                     SizedBox(width: 8),
                        //                     Text('Открыть в браузере'),
                        //                 ]
                        //             ),
                        //             onPressed: () async => _activate(MenuEntry.openInBrowser),
                        //         ),

                        //         MenuItemButton(
                        //             child: Row(
                        //                 children: <Widget>[
                        //                     Icon(
                        //                         isDesktopMode
                        //                         ? (Util.isAndroid()
                        //                             ? Icons.phone_android
                        //                             : Icons.phone_iphone)
                        //                         : Icons.laptop
                        //                     ),
                        //                     const SizedBox(width: 8),
                        //                     Text(isDesktopMode ? 'Мобильная версия' : 'Версия для ПК'),
                        //                 ],
                        //             ),
                        //             onPressed: () async => _activate(MenuEntry.desktopMode),
                        //         ),

                        //         MenuItemButton(
                        //             child: const Row(
                        //                 children: <Widget>[
                        //                     Icon(Icons.clear_all),
                        //                     SizedBox(width: 8),
                        //                     Text('Очистить данные браузера')
                        //                 ],
                        //             ),
                        //             onPressed: () async => _activate(MenuEntry.clearCache),
                        //         ),
                        //     ]
                        // )
                    ],
                ),

                body: Column(
                    children: <Widget>[
                        Expanded(
                            child: Stack(
                                children: <Widget>[
                                    InAppWebView(
                                        key: webViewKey,
                                        pullToRefreshController: _pullToRefreshController,
                                        findInteractionController: _findInteractionController,
                                        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                                        initialSettings: initialSettings,
                                        initialUserScripts: UnmodifiableListView(
                                            OS.isAndroid ? [] : [textSizeUserScript]
                                        ),

                                        // TODO
                                        gestureRecognizers: widget.windowId != null ? <Factory<OneSequenceGestureRecognizer>>{ Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()) } : null,
                                        windowId: widget.windowId,
                                        onCloseWindow: widget.windowId != null ? (controller) => Navigator.pop(context) : null,

                                        onWebViewCreated: (controller) async {
                                            webViewController = controller;

                                            if (OS.isAndroid) {
                                                await controller.startSafeBrowsing();
                                            }
                                        },

                                        onLoadStart: (controller, url) async {
                                            await _pullToRefreshController?.endRefreshing();

                                            if (url != null) {
                                                setState(
                                                    () {
                                                        this.url = url.toString();
                                                        isSecure = Util.urlIsSecure(url);
                                                    }
                                                );
                                            }
                                        },

                                        onLoadStop: (controller, url) async {
                                            final sslCertificate = await controller.getCertificate();

                                            setState(
                                                () {
                                                    if (url != null) {
                                                        this.url = url.toString();
                                                    }

                                                    this.isSecure = sslCertificate != null || (url != null && Util.urlIsSecure(url));
                                                }
                                            );
                                        },

                                        onUpdateVisitedHistory: (controller, url, isReload) {
                                            if (url != null) {
                                                setState(() => this.url = url.toString());
                                            }
                                        },

                                        onTitleChanged: (controller, title) {
                                            if (title != null) {
                                                setState(() => this.title = title);
                                            }
                                        },

                                        onProgressChanged: (controller, progress) async {
                                            if (progress == 100) {
                                                await _pullToRefreshController?.endRefreshing();
                                            }

                                            setState(() => this.progress = progress / 100.0);
                                        },

                                        onLongPressHitTestResult: (controller, hitTestResult) async {
                                            if (LongPressAlertDialog.hitTestResultSupported.contains(hitTestResult.type)) {
                                                final requestFocusNodeHrefResult = await webViewController?.requestFocusNodeHref();

                                                if (requestFocusNodeHrefResult != null) {
                                                    await showDialog<void>(
                                                        context: context,
                                                        builder: (context) => LongPressAlertDialog(
                                                            webViewController: webViewController!,
                                                            hitTestResult: hitTestResult,
                                                            requestFocusNodeHrefResult: requestFocusNodeHrefResult,
                                                        ),
                                                    );
                                                }
                                            }
                                        },

                                        onLoadResource: (controller, resource) {
                                            widget.webViewModel.addLoadedResources(resource);
                                        },

                                        onCreateWindow: (controller, createWindowRequest) async {
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute<void>(
                                                    builder: (context) => WebView(
                                                        url: '', //TODO
                                                        windowId: createWindowRequest.windowId
                                                    )
                                                )
                                            );

                                            return true;
                                        },

                                        shouldOverrideUrlLoading: (controller, navigationAction) async {
                                            if (OS.isIOS) {
                                                final shouldPerformDownload = navigationAction.shouldPerformDownload ?? false;
                                                final url = navigationAction.request.url;

                                                if (shouldPerformDownload && url != null) {
                                                    await downloadFile(url.toString());
                                                    return NavigationActionPolicy.DOWNLOAD;
                                                }
                                            }

                                            final url = navigationAction.request.url;

                                            if (url != null && !['http', 'https', 'file', 'chrome', 'data', 'javascript', 'about'].contains(url.scheme)) {
                                                if (await launchLink(context, url.toString())) {
                                                    return NavigationActionPolicy.CANCEL;
                                                }
                                            }

                                            return NavigationActionPolicy.ALLOW;
                                        },

                                        onDownloadStartRequest: (controller, downloadStartRequest) async {
                                            await downloadFile(downloadStartRequest.url.toString(), downloadStartRequest.suggestedFilename);
                                        },

                                        onReceivedServerTrustAuthRequest: (controller, challenge) async {
                                            final sslError = challenge.protectionSpace.sslError;

                                            if (sslError != null && (sslError.code != null)) {
                                                if (OS.isIOS && sslError.code == SslErrorType.UNSPECIFIED) {
                                                    return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                                                }

                                                widget.webViewModel.isSecure = false;
                                                return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.CANCEL);
                                            }

                                            return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                                        },

                                        onReceivedHttpError: (controller, request, errorResponse) async {
                                            // Handle HTTP errors here
                                            final isForMainFrame = request.isForMainFrame ?? false;

                                            if (!isForMainFrame) {
                                                return;
                                            }

                                            showSnackBar(
                                                context,
                                                Text(
                                                    'HTTP error for URL: ${request.url} with status: ${errorResponse.statusCode} ${errorResponse.reasonPhrase ?? ''}'
                                                )
                                            );
                                        },

                                        //TODO FIXME
                                        onReceivedError: true ? null : (controller, request, error) async {
                                            await _pullToRefreshController?.endRefreshing();

                                            // Handle web page loading errors here
                                            final isForMainFrame = request.isForMainFrame ?? false;

                                            if (!isForMainFrame || (OS.isIOS && error.type == WebResourceErrorType.CANCELLED)) {
                                                return;
                                            }

                                            final errorUrl = request.url;
                                            await controller.loadData(
                                                data: '''
<!DOCTYPE html>
<html lang="ru">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <style>
            ${await InAppWebViewController.tRexRunnerCss}
        </style>
        <style>
            .interstitial-wrapper {
                box-sizing: border-box;
                font-size: 1em;
                line-height: 1.6em;
                margin: 0 auto 0;
                max-width: 600px;
                width: 100%;
            }
        </style>
    </head>
    <body>
        ${await InAppWebViewController.tRexRunnerHtml}
        <div class="interstitial-wrapper">
            <h1>Сайт не доступен</h1>
            <p>Не удалось загрузить страницу по адресу <strong>$errorUrl</strong>:</p> <p>${error.description}</p>
        </div>
    </body>
</html>
''',
                                                baseUrl: errorUrl,
                                                historyUrl: errorUrl
                                            );
                                        },
                                    ),
                                    if (progress < 1.0)
                                    SizedBox(
                                        height: 3,
                                        child: LinearProgressIndicator(
                                            value: progress,
                                            color: Theme.of(context).colorScheme.primary,
                                        )
                                    ),
                                ],
                            )
                        ),
                    ]
                ),
            )
        );
    }
}
