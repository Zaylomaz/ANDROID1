import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:uikit/uikit.dart';

/// типы контента для браузера
enum WebViewScreenArgsType { data, url }

/// Аргументы экрана
class WebViewScreenArgs {
  const WebViewScreenArgs._({
    this.title,
    this.initialUri,
    this.initialData,
  });

  factory WebViewScreenArgs.fromUri({
    required Uri initialUri,
    String? title,
  }) =>
      WebViewScreenArgs._(
        title: title,
        initialUri: initialUri,
      );
  factory WebViewScreenArgs.fromData({
    required String initialData,
    String? title,
  }) =>
      WebViewScreenArgs._(
        title: title,
        initialData: initialData,
      );

  WebViewScreenArgsType get type => initialUri is Uri
      ? WebViewScreenArgsType.url
      : WebViewScreenArgsType.data;

  /// Название экрана с браузером
  final String? title;

  /// Веб адрес
  final Uri? initialUri;

  /// HTML код к отображению
  final String? initialData;
}

/// Экран с браузером
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({required this.args, super.key});

  final WebViewScreenArgs args;

  static const String routeName = '/web_view';

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? webViewController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppToolbar(
        title: widget.args.title?.isNotEmpty == true
            ? Text(
                widget.args.title!,
              )
            : null,
      ),
      body: InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(),
        ),
        initialUrlRequest: widget.args.type == WebViewScreenArgsType.url
            ? URLRequest(url: widget.args.initialUri!)
            : null,
        initialData: widget.args.type == WebViewScreenArgsType.data
            ? InAppWebViewInitialData(data: widget.args.initialData!)
            : null,
        gestureRecognizers: const {
          Factory<VerticalDragGestureRecognizer>(
              VerticalDragGestureRecognizer.new)
        },
        onWebViewCreated: (c) {
          setState(() {
            webViewController = c;
          });
        },
      ),
    );
  }
}
