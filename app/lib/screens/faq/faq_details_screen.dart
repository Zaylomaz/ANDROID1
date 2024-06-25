import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:uikit/uikit.dart';

/*
* Экран "Часто задаваемый вопрос"
* По сути просто веб страница
*/

class FAQDetailsScreen extends StatefulWidget {
  const FAQDetailsScreen(this.data, {super.key});

  final FAQDetails data;

  static const String routeName = '/faq_details_screen';

  @override
  State<FAQDetailsScreen> createState() => _FAQDetailsScreenState();
}

class _FAQDetailsScreenState extends State<FAQDetailsScreen> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppToolbar(
        title: Text(widget.data.title),
      ),
      body: InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(),
        ),
        initialData: InAppWebViewInitialData(data: widget.data.text),
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
