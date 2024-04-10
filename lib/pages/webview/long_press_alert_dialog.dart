// import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_browser/custom_image.dart';
// import 'package:flutter_browser/webview_tab.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';

import 'custom_image.dart';

// import 'models/browser_model.dart';
// import 'models/webview_model.dart';

class LongPressAlertDialog extends StatefulWidget {
    static const List<InAppWebViewHitTestResultType> hitTestResultSupported = [
        InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE,
        InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE,
        InAppWebViewHitTestResultType.IMAGE_TYPE
    ];

    const LongPressAlertDialog({
            super.key,
            required this.webViewController,
            required this.hitTestResult,
            this.requestFocusNodeHrefResult
    });

    final InAppWebViewController webViewController;
    final InAppWebViewHitTestResult hitTestResult;
    final RequestFocusNodeHrefResult? requestFocusNodeHrefResult;

    @override
    State<LongPressAlertDialog> createState() => _LongPressAlertDialogState();
}

class _LongPressAlertDialogState extends State<LongPressAlertDialog> {
    var _isLinkPreviewReady = false;
    static const _borderRadius = 8.0;

    @override
    Widget build(BuildContext context) {
        // return Dialog(
        //     child: SingleChildScrollView(
        //         child: SizedBox(
        //             width: double.maxFinite,
        //             //height: MediaQuery.of(context).size.height * 0.8,
        //             //width: MediaQuery.of(context).size.width * 0.8,
        //             child: Column(
        //                 mainAxisSize: MainAxisSize.min,
        //                 children: _buildDialogLongPressHitTestResult(),
        //             ),
        //         ),
        //     ),
        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
        // );
        // return SimpleDialog(
        //     contentPadding: const EdgeInsets.all(0.0),
        //     children: _buildDialogLongPressHitTestResult(),
        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
        //         // SingleChildScrollView(
        //         //     child: SizedBox(
        //         //         width: double.maxFinite,
        //         //         child: Column(
        //         //             mainAxisSize: MainAxisSize.min,
        //         //             children: _buildDialogLongPressHitTestResult(),
        //         //         ),
        //         //     ),
        //         // ),
        // );

        return SimpleDialog(
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
            children: [
                SingleChildScrollView(
                    child: SizedBox(
                        width: double.maxFinite,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _buildDialogLongPressHitTestResult(),
                        ),
                    ),
                ),
            ],
        );
    }

    List<Widget> _buildDialogLongPressHitTestResult() {
        if (widget.hitTestResult.type == InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE
        ||  widget.hitTestResult.type == InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE
        || (widget.hitTestResult.type == InAppWebViewHitTestResultType.IMAGE_TYPE
         && widget.requestFocusNodeHrefResult != null
         && widget.requestFocusNodeHrefResult!.url != null
         && widget.requestFocusNodeHrefResult!.url.toString().isNotEmpty)) {
            return <Widget>[
                _buildLinkTile(),
                // const Divider(),
                // _buildLinkPreview(),
                const Divider(),
                _buildOpenLink(),
                _buildCopyAddressLink(),
                _buildShareLink(),
            ];
        } else if (widget.hitTestResult.type == InAppWebViewHitTestResultType.IMAGE_TYPE) {
            return <Widget>[
                _buildImageTile(),
                const Divider(),
                //_buildDownloadImage(),
                //_buildSearchImageOnGoogle(),
                _buildShareImage(),
            ];
        }

        return [];
    }

    Widget _buildLinkTile() {
        var url = widget.requestFocusNodeHrefResult?.url ?? Uri.parse("about:blank");
        var faviconUrl = Uri.parse("${url.origin}/favicon.ico");
        var title = widget.requestFocusNodeHrefResult?.title;
        var link = widget.requestFocusNodeHrefResult?.url?.toString();

        if (title != null && title.isEmpty) {
            title = null;
        }

        return ListTile(
            leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    // TODO
                    // CachedNetworkImage(
                    //   placeholder: (context, url) => CircularProgressIndicator(),
                    //   imageUrl: widget.requestFocusNodeHrefResult?.src != null ? widget.requestFocusNodeHrefResult!.src : faviconUrl,
                    //   height: 30,
                    // )
                    CustomImage(
                        url: widget.requestFocusNodeHrefResult?.src != null
                            ? Uri.parse(widget.requestFocusNodeHrefResult!.src!)
                            : faviconUrl,
                        maxWidth: 24.0,
                        height: 24.0,
                    )
                ],
            ),
            title: Text(
                title ?? link ?? 'Предпросмотр',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            subtitle: title != null && link != null
            ? Text(
                link,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
            )
            : null
        );
    }

    // Widget _buildLinkPreview() {
    //     // var browserModel = Provider.of<BrowserModel>(context, listen: true);
    //     // browserModel.getSettings();

    //     return SizedBox.shrink();//TODO
    //     return Container(
    //         padding: const EdgeInsets.all(8.0),
    //         height: MediaQuery.of(context).size.height * 0.5,
    //         child: IndexedStack(
    //             index: _isLinkPreviewReady ? 1 : 0,
    //             children: <Widget>[
    //                 const Center(
    //                     child: CircularProgressIndicator(),
    //                 ),
    //                 InAppWebView(
    //                     gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
    //                         Factory<OneSequenceGestureRecognizer>(
    //                             () => EagerGestureRecognizer(),
    //                         ),
    //                     },
    //                     initialUrlRequest: URLRequest(url: widget.requestFocusNodeHrefResult?.url),
    //                     initialSettings: InAppWebViewSettings(
    //                         verticalScrollbarThumbColor: const Color.fromRGBO(0, 0, 0, 0.5),
    //                         horizontalScrollbarThumbColor: const Color.fromRGBO(0, 0, 0, 0.5)
    //                     ),
    //                     onProgressChanged: (controller, progress) {
    //                         if (progress > 50) {
    //                             setState(() => _isLinkPreviewReady = true);
    //                         }
    //                     },
    //                 )
    //             ],
    //         ),
    //     );
    // }

    // Widget _buildOpenNewTab() {
    //   var browserModel = Provider.of<BrowserModel>(context, listen: false);

    //   return ListTile(
    //     title: const Text("Open in a new tab"),
    //     onTap: () {
    //       browserModel.addTab(WebViewTab(
    //         key: GlobalKey(),
    //         webViewModel:
    //             WebViewModel(url: widget.requestFocusNodeHrefResult?.url),
    //       ));
    //       Navigator.pop(context);
    //     },
    //   );
    // }

    Widget _buildOpenLink() {
        return ListTile(
            title: const Text("Открыть страницу"),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
            onTap: () {
                if (widget.requestFocusNodeHrefResult?.url != null) {
                    widget.webViewController.loadUrl(
                        urlRequest: URLRequest(url: widget.requestFocusNodeHrefResult?.url!)
                    );
                } else {
                    // TODO
                }

                Navigator.pop(context);
            },
        );
    }

    Widget _buildCopyAddressLink() {
        return ListTile(
            title: const Text("Скопировать ссылку"),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
            onTap: () {
                Clipboard.setData(
                    ClipboardData(
                        text: widget.requestFocusNodeHrefResult?.url.toString() ?? widget.hitTestResult.extra ?? ''
                    )
                );
                Navigator.pop(context);
            },
        );
    }

    Widget _buildShareLink() {
        return ListTile(
            title: const Text("Поделиться ссылкой"),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
            onTap: () {
                if (widget.hitTestResult.extra != null) {
                    Share.share(widget.requestFocusNodeHrefResult?.url.toString() ?? widget.hitTestResult.extra!);
                }

                Navigator.pop(context);
            },
        );
    }

    // Widget _buildCopyAddressLink() {
    //     return TextButton(
    //         child: const Text('Скопировать ссылку'),
    //         style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    //         onPressed: () {
    //             Clipboard.setData(
    //                 ClipboardData(
    //                     text: widget.requestFocusNodeHrefResult?.url.toString() ?? widget.hitTestResult.extra ?? ''
    //                 )
    //             );
    //             Navigator.pop(context);
    //         },
    //     );
    // }

    // Widget _buildShareLink() {
    //     return TextButton(
    //         style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    //         child: const Text('Поделиться ссылкой'),
    //         onPressed: () {
    //             if (widget.hitTestResult.extra != null) {
    //                 Share.share(widget.requestFocusNodeHrefResult?.url.toString() ?? widget.hitTestResult.extra!);
    //             }
    //             Navigator.pop(context);
    //         },
    //     );
    // }

    Widget _buildImageTile() {
        return ListTile(
            leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    // CachedNetworkImage(
                    //   placeholder: (context, url) => CircularProgressIndicator(),
                    //   imageUrl: widget.hitTestResult.extra,
                    //   height: 50,
                    // ),
                    CustomImage(
                        url: Uri.parse(widget.hitTestResult.extra!),
                        maxWidth: 60.0,
                        height: 60.0
                    )
                ],
            ),

            title: FutureBuilder<String?>(
                future: widget.webViewController.getTitle() ?? Future.value(''),
                builder: (context, snapshot) {
                    final title = snapshot.hasData ? snapshot.data! : '';
                    return title != ''
                    ? Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                    )
                    : const SizedBox.shrink();
                },
            ),
        );
    }

    // Widget _buildDownloadImage() {
    //   return ListTile(
    //     title: const Text("Download image"),
    //     onTap: () async {
    //       String? url = widget.hitTestResult.extra;
    //       if (url != null) {
    //         var uri = Uri.parse(widget.hitTestResult.extra!);
    //         String path = uri.path;
    //         String fileName = path.substring(path.lastIndexOf('/') + 1);
    //         Directory? directory = await getExternalStorageDirectory();
    //         await FlutterDownloader.enqueue(
    //           url: url,
    //           fileName: fileName,
    //           savedDir: directory!.path,
    //           showNotification: true,
    //           openFileFromNotification: true,
    //         );
    //       }
    //       if (mounted) {
    //         Navigator.pop(context);
    //       }
    //     },
    //   );
    // }

    Widget _buildShareImage() {
        return ListTile(
            title: const Text('Поделиться изображением'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
            onTap: () {
                if (widget.hitTestResult.extra != null) {
                    Share.share(widget.hitTestResult.extra!);
                }

                Navigator.pop(context);
            },
        );
    }

    // Widget _buildSearchImageOnGoogle() {
    //   var browserModel = Provider.of<BrowserModel>(context, listen: false);

    //   return ListTile(
    //     title: const Text("Search this image on Google"),
    //     onTap: () {
    //       if (widget.hitTestResult.extra != null) {
    //         var url =
    //             "http://images.google.com/searchbyimage?image_url=${widget.hitTestResult.extra!}";
    //         browserModel.addTab(WebViewTab(
    //           key: GlobalKey(),
    //           webViewModel: WebViewModel(url: WebUri(url)),
    //         ));
    //       }
    //       Navigator.pop(context);
    //     },
    //   );
    // }
}
