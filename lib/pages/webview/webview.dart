
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

import './webview_model.dart';
import './util.dart';
import '../../utils.dart';

class WebViewDino extends StatelessWidget {
    const WebViewDino({super.key});

    @override
    Widget build(BuildContext context) {
        var initialSettings = InAppWebViewSettings();
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

class WebView extends StatefulWidget {
    WebView({super.key, required this.url, this.windowId})
        : webViewModel = WebViewModel(url: WebUri(url));

    final String url;
    final WebViewModel webViewModel;
    final windowId;

    @override
    State<WebView> createState() => _CustomInAppBrowserState();
}

enum MenuEntry {
    changeTextSize,
    share,
    copyLink,
    openInBrowser,
    desktopMode,
    clearCache,
}

class _CustomInAppBrowserState extends State<WebView> {
    final GlobalKey webViewKey = GlobalKey();

    String url = '';
    String title = '';
    double progress = 0.0;
    bool? isSecure;
    bool isDesktopMode = false;
    InAppWebViewController? webViewController;
    PullToRefreshController? _pullToRefreshController;
    int textSize = kInitialTextSize;
    final FocusNode _buttonFocusNode = FocusNode();

    final ReceivePort _port = ReceivePort();

    void toggleDesktopMode() async {
        if (webViewController != null) {
            setState(() => isDesktopMode = !isDesktopMode);

            var currentSettings = await webViewController?.getSettings();

            if (currentSettings != null) {
                currentSettings.preferredContentMode = isDesktopMode
                  ? UserPreferredContentMode.DESKTOP
                  : UserPreferredContentMode.RECOMMENDED;
                await webViewController?.setSettings(settings: currentSettings);
            }

            await webViewController?.reload();
        }
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
            final taskId = await FlutterDownloader.enqueue(
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
        if (Util.isAndroid()) {
            var currentSettings = await webViewController?.getSettings();

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
        FlutterDownloader.registerCallback(downloadCallback, step: 1);
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
            onRefresh: () async {
                if (Util.isAndroid()) {
                    await webViewController?.reload();
                } else if (Util.isIOS()) {
                    await webViewController?.loadUrl(urlRequest: URLRequest(url: await webViewController?.getUrl()));
                }
            },
        );
    }

    @override
    void dispose() {
        webViewController = null;
        _unbindBackgroundIsolate();
        _buttonFocusNode.dispose();
        super.dispose();
    }

    void _bindBackgroundIsolate() {
        final isSuccess = IsolateNameServer.registerPortWithName(
            _port.sendPort,
            'downloader_send_port',
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
        IsolateNameServer.removePortNameMapping('downloader_send_port');
    }

    @pragma('vm:entry-point')
    static void downloadCallback(String id, int status, int progress) {
        IsolateNameServer.lookupPortByName('downloader_send_port')?.send([id, status, progress]);
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

    void copyLink() {
        if (url != '') {
            Clipboard.setData(ClipboardData(text: url));

            showSnackBar(context, const Text('Ссылка скопирована в буфер обмена'));
        }
    }

    void _activate(MenuEntry selection) async {
        switch (selection) {
        case MenuEntry.changeTextSize:
            break;
        case MenuEntry.share:
            await Share.share(url, subject: title);
            break;
        case MenuEntry.copyLink:
             copyLink();
             break;
        case MenuEntry.openInBrowser:
            await InAppBrowser.openWithSystemBrowser(url: WebUri(url));
            break;
        case MenuEntry.desktopMode:
            toggleDesktopMode();
            break;
        case MenuEntry.clearCache:
            await showDialog(
                context: context,
                builder: (final context) => AlertDialog(
                    title: const Text('Отчистить кэш браузера?'),
                    content: const Text('Обратите внимание: после отчистки кэша нужно будет заново заходить в аккаунты на всех сайтах.'),
                    actions: <Widget>[
                        ElevatedButton(
                            onPressed: () async {
                                await webViewController?.clearCache();
                                if (Util.isAndroid()) {
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
        var initialSettings = widget.webViewModel.settings ?? InAppWebViewSettings();

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

                if (await _goBack(context)) {
                    Navigator.pop(context);
                }
            },
            child: Scaffold(
                backgroundColor: Theme.of(context).colorScheme.background,
                appBar: AppBar(
                    shadowColor: Theme.of(context).shadowColor,
                    leading: widget.windowId != null ? BackButton(onPressed: () => Navigator.pop(context)) : CloseButton(onPressed: () => Navigator.pop(context)),
                    title: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                            FutureBuilder<bool>(
                                future: webViewController?.canGoBack() ?? Future.value(false),
                                builder: (context, snapshot) {
                                    final canGoBack = snapshot.hasData ? snapshot.data! : false;

                                    return IconButton(
                                        icon: const Icon(Icons.arrow_back_ios),
                                        onPressed: canGoBack ? () => webViewController?.goBack() : null,
                                    );
                                },
                            ),

                            Expanded(
                                child: InkWell(
                                    borderRadius: BorderRadius.circular(8.0),
                                    onTap: () => tooltipkey.currentState?.ensureTooltipVisible(),
                                    onLongPress: () => copyLink(),

                                    child: Tooltip(
                                        key: tooltipkey,
                                        triggerMode: TooltipTriggerMode.manual,
                                        message: title,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8.0),
                                            color: Theme.of(context).colorScheme.primary,
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        preferBelow: true,
                                        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onPrimary
                                        ),
                                        textAlign: TextAlign.center,

                                        child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                    if (title != '' && title != url && !title.startsWith('data:'))
                                                    Text(
                                                        title,
                                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            ),

                            FutureBuilder<bool>(
                                future: webViewController?.canGoForward() ?? Future.value(false),
                                builder: (context, snapshot) {
                                    final canGoForward = snapshot.hasData ? snapshot.data! : false;
                                    return IconButton(
                                        icon: const Icon(Icons.arrow_forward_ios),
                                        onPressed: canGoForward
                                        ? () => webViewController?.goForward()
                                        : null,
                                    );
                                },
                            ),
                        ],
                    ),

                    actions: <Widget>[
                        MenuAnchor(
                            consumeOutsideTap: true,

                            builder: (BuildContext context, MenuController controller, Widget? child) {
                                return IconButton(
                                    focusNode: _buttonFocusNode,
                                    onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                                    icon: const Icon(Icons.more_vert),
                                );
                            },

                            menuChildren: <Widget>[
                                Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                        IconButton(
                                            onPressed: textSize < kTextSizeMax
                                            ? () async {
                                                setState(() => textSize += kTextSizeDelta);
                                                await updateTextSize(textSize);
                                            }
                                            : null,
                                            icon: Icon(
                                                Icons.add,
                                                color: textSize < kTextSizeMax ? Theme.of(context).colorScheme.primary : Colors.grey,
                                            ),
                                        ),
                                        IconButton(
                                            onPressed: textSize > kTextSizeMin
                                            ? () async {
                                                setState(() => textSize -= kTextSizeDelta);
                                                await updateTextSize(textSize);
                                            }
                                            : null,
                                            icon: Icon(
                                                Icons.remove,
                                                color: textSize > kTextSizeMin ? Theme.of(context).colorScheme.primary : Colors.grey,
                                            ),
                                        ),
                                        TextButton(
                                            onPressed: textSize != kInitialTextSize
                                            ? () async {
                                                setState(() => textSize = kInitialTextSize);
                                                await updateTextSize(textSize);
                                            }
                                            : null,
                                            child: Text(
                                                '100%',
                                                style: TextStyle(
                                                    color: textSize != kInitialTextSize ? Theme.of(context).colorScheme.primary : Colors.grey,
                                                ),
                                            ),
                                        ),
                                    ]
                                ),

                                const Divider(),

                                MenuItemButton(
                                    child: const Row(
                                        children: <Widget>[
                                            Icon(Icons.share),
                                            SizedBox(width: 8),
                                            Text('Поделиться'),
                                        ]
                                    ),
                                    onPressed: () async => _activate(MenuEntry.share),
                                ),

                                MenuItemButton(
                                    child: const Row(
                                        children: <Widget>[
                                            Icon(Icons.link),
                                            SizedBox(width: 8),
                                            Text('Скопировать ссылку'),
                                        ]
                                    ),
                                    onPressed: () async => _activate(MenuEntry.copyLink),
                                ),

                                MenuItemButton(
                                    child: const Row(
                                        children: <Widget>[
                                            Icon(Icons.open_in_browser),
                                            SizedBox(width: 8),
                                            Text('Открыть в браузере'),
                                        ]
                                    ),
                                    onPressed: () async => _activate(MenuEntry.openInBrowser),
                                ),

                                MenuItemButton(
                                    child: Row(
                                        children: <Widget>[
                                            Icon(
                                                isDesktopMode
                                                ? (Util.isAndroid()
                                                    ? Icons.phone_android
                                                    : Icons.phone_iphone)
                                                : Icons.laptop
                                            ),
                                            const SizedBox(width: 8),
                                            Text(isDesktopMode ? 'Мобильная версия' : 'Версия для ПК'),
                                        ],
                                    ),
                                    onPressed: () async => _activate(MenuEntry.desktopMode),
                                ),

                                MenuItemButton(
                                    child: const Row(
                                        children: <Widget>[
                                            Icon(Icons.clear_all),
                                            SizedBox(width: 8),
                                            Text('Очистить данные браузера')
                                        ],
                                    ),
                                    onPressed: () async => _activate(MenuEntry.clearCache),
                                ),
                            ]
                        )
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
                                        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                                        initialSettings: initialSettings,
                                        initialUserScripts: UnmodifiableListView(
                                            Util.isAndroid() ? [] : [textSizeUserScript]
                                        ),

                                        // TODO
                                        gestureRecognizers: widget.windowId != null ? <Factory<OneSequenceGestureRecognizer>>{Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())} : null,
                                        windowId: widget.windowId,
                                        onCloseWindow: widget.windowId != null ? (controller) => Navigator.pop(context) : null,

                                        onWebViewCreated: (controller) async {
                                            webViewController = controller;

                                            if (Util.isAndroid()) {
                                                await controller.startSafeBrowsing();
                                            }
                                        },

                                        onLoadStart: (controller, url) {
                                            _pullToRefreshController?.endRefreshing();

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
                                            if (url != null) {
                                                setState(() => this.url = url.toString());
                                            }

                                            final sslCertificate = await controller.getCertificate();

                                            setState(() => isSecure = sslCertificate != null || (url != null && Util.urlIsSecure(url)));
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

                                        onProgressChanged: (controller, progress) {
                                            if (progress == 100) {
                                                _pullToRefreshController?.endRefreshing();
                                            }

                                            setState(() => this.progress = progress / 100.0);
                                        },

                                        onLongPressHitTestResult: (controller, hitTestResult) async {
                                            if (LongPressAlertDialog.hitTestResultSupported.contains(hitTestResult.type)) {
                                                var requestFocusNodeHrefResult = await webViewController?.requestFocusNodeHref();

                                                if (requestFocusNodeHrefResult != null) {
                                                    await showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                            return LongPressAlertDialog(
                                                                webViewController: webViewController!,
                                                                hitTestResult: hitTestResult,
                                                                requestFocusNodeHrefResult: requestFocusNodeHrefResult,
                                                            );
                                                        },
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
                                                MaterialPageRoute(
                                                    builder: (context) => WebView(
                                                        url: '', //TODO
                                                        windowId: createWindowRequest.windowId
                                                    )
                                                )
                                            );

                                            return true;
                                        },

                                        shouldOverrideUrlLoading: (controller, navigationAction) async {
                                            if (Util.isIOS()) {
                                                final shouldPerformDownload = navigationAction.shouldPerformDownload ?? false;
                                                final url = navigationAction.request.url;

                                                if (shouldPerformDownload && url != null) {
                                                    await downloadFile(url.toString());
                                                    return NavigationActionPolicy.DOWNLOAD;
                                                }
                                            }

                                            var url = navigationAction.request.url;

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
                                            var sslError = challenge.protectionSpace.sslError;

                                            if (sslError != null && (sslError.code != null)) {
                                                if (Util.isIOS() && sslError.code == SslErrorType.UNSPECIFIED) {
                                                    return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                                                }

                                                widget.webViewModel.isSecure = false;
                                                return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.CANCEL);
                                            }

                                            return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                                        },

                                        onReceivedHttpError: (controller, request, errorResponse) async {
                                            // Handle HTTP errors here
                                            var isForMainFrame = request.isForMainFrame ?? false;

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

                                        onReceivedError: (controller, request, error) async {
                                            await _pullToRefreshController?.endRefreshing();

                                            // Handle web page loading errors here
                                            var isForMainFrame = request.isForMainFrame ?? false;

                                            if (!isForMainFrame || (Util.isIOS() && error.type == WebResourceErrorType.CANCELLED)) {
                                                return;
                                            }

                                            var errorUrl = request.url;
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
                                            color: Theme.of(context).colorScheme.primary
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
