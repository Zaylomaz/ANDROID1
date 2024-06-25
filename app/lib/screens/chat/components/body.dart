import 'dart:io';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:rempc/model/chat_model.dart';
import 'package:rempc/screens/channels/channels_screen.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';
import 'package:uuid/uuid.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<Body> {
  List<types.Message> _messages = [];
  var _user = const types.User(id: '');
  AppChatChannel? channel;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _resetCurrentChatId();
    super.dispose();
  }

  Future<void> _setCurrentChatId() async {
    const platform = MethodChannel('helperService');
    await platform
        .invokeMethod('setCurrentChannelId', {'channelId': channel?.id});
  }

  Future<void> _resetCurrentChatId() async {
    const platform = MethodChannel('helperService');
    await platform.invokeMethod('setCurrentChannelId', {'channelId': 0});
  }

  Future<void> _addMessage(BuildContext context, types.Message message) async {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed(BuildContext ctx) {
    showModalBottomSheet<void>(
      context: ctx,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection(context);
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Photo'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _handleFileSelection(context);
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('File'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleFileSelection(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowCompression: false,
        allowedExtensions: 'jpg,bmp,png,txt,mp3,xls,csv,apk,pdf'.split(','),
      );

      if (result != null) {
        final message = types.FileMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          mimeType: lookupMimeType(result.files.single.path!),
          name: result.files.single.name,
          size: result.files.single.size,
          uri: result.files.single.path!,
        );

        await _addMessage(context, message);

        await _uploadFile(context, message);
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
    Navigator.of(context).pop();
  }

  Future<void> _uploadFile(
      BuildContext context, types.FileMessage message) async {
    final index = _messages.indexWhere((element) => element.id == message.id);
    setState(() {
      _messages[index] = (_messages[index] as types.FileMessage).copyWith(
        status: types.Status.sending,
      );
    });

    try {
      await ChatRepository()
          .uploadChatFile(context.read<ChatModel>().channelId, message.uri);

      setState(() {
        _messages[index] = (_messages[index] as types.FileMessage).copyWith(
          status: types.Status.sent,
        );
      });
    } catch (e) {
      if (e is DioException) {
        await _showError(e.response?.data?['file']?[0] ??
            e.response?.data.toString() ??
            'Неизвестная ошибка');
      }
      setState(() {
        _messages[index] = (_messages[index] as types.FileMessage).copyWith(
          status: types.Status.error,
        );
      });
    }
  }

  Future<void> _handleImageSelection(
    BuildContext context,
  ) async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      await _addMessage(context, message);
      await _uploadImage(context, message);
    }
  }

  Future<void> _uploadImage(
      BuildContext context, types.ImageMessage message) async {
    final index = _messages.indexWhere((element) => element.id == message.id);
    setState(() {
      _messages[index] = (_messages[index] as types.ImageMessage).copyWith(
        status: types.Status.sending,
      );
    });

    try {
      await ChatRepository()
          .uploadChatImage(context.read<ChatModel>().channelId, message.uri);

      setState(() {
        _messages[index] = (_messages[index] as types.ImageMessage).copyWith(
          status: types.Status.sent,
        );
      });
    } catch (e) {
      if (e is DioException) {
        await _showError(e.response?.data['image'][0] ??
            e.response?.data.toString() ??
            'Неизвестная ошибка');
      }
      setState(() {
        _messages[index] = (_messages[index] as types.ImageMessage).copyWith(
          status: types.Status.error,
        );
      });
    }
  }

  Future<void> _handleMessageTap(
    BuildContext context,
    types.Message message,
  ) async {
    if (message is types.ImageMessage && message.status == types.Status.error) {
      await _uploadImage(context, message);
      return;
    }
    if (message is types.FileMessage && message.status == types.Status.error) {
      await _uploadFile(context, message);
      return;
    }
    if (message is types.FileMessage) {
      var localPath = message.uri;
      if (message.isLoading == true) {
        return;
      }

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            uri: localPath,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      // await OpenFile.open(localPath);
      return;
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.FileMessage).copyWith(
      isLoading: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
      status: types.Status.sending,
    );
    await _addMessage(context, textMessage);

    final id = ModalRoute.of(context)?.settings.arguments as int?;

    final index =
        _messages.indexWhere((element) => element.id == textMessage.id);

    try {
      await ChatRepository().sendMessages(id!, message.text);
      setState(() {
        _messages[index] = (_messages[index] as types.TextMessage).copyWith(
          status: types.Status.sent,
        );
      });
    } catch (e) {
      setState(() {
        _messages[index] = (_messages[index] as types.TextMessage).copyWith(
          status: types.Status.error,
        );
      });
    }
  }

  Future<void> _showError(String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: const Text('Ошибка'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ок'),
              onPressed: () async {
                Navigator.pop(context, 'Canceled');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadMessages() async {
    const platform = MethodChannel('helperService');
    await platform.invokeMethod('resetChannelId');

    final token = ApiStorage().accessToken;
    _user = types.User(id: token, firstName: 'test', lastName: 'last name');
    channel = ModalRoute.of(context)?.settings.arguments as AppChatChannel?;

    final response = await ChatRepository().getMessages(channel!.id);

    if (!mounted) {
      return;
    }
    await _setCurrentChatId();

    setState(() {
      _messages = response.map((e) => e.chatMessage).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatModel = Provider.of<ChatModel>(context);
    if (chatModel.channelId != 0) {
      if (chatModel.channelId ==
          (ModalRoute.of(context)?.settings.arguments as AppChatChannel?)?.id) {
        _loadMessages();
      }
      chatModel.channelId = 0;
    }
    final channel =
        ModalRoute.of(context)?.settings.arguments as AppChatChannel?;
    if (channel?.id == null) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushNamed(ChannelsScreen.routeName);
      });
    }

    return Scaffold(
      appBar: AppToolbar(
        title: Text(channel?.name ?? channel?.id.toString() ?? 'Чат'),
      ),
      body: SafeArea(
        bottom: false,
        child: Chat(
          theme: const DefaultChatTheme(
            inputTextDecoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
              isCollapsed: true,
            ),
            inputBackgroundColor: AppColors.black,
            backgroundColor: AppColors.blackContainer,
            userNameTextStyle: TextStyle(color: AppColors.violetLight),
          ),
          showUserNames: true, // show user name
          messages: _messages,
          dateFormat: DateFormat('dd MMMM yyyy', 'ru'),
          onAttachmentPressed: () => _handleAttachmentPressed(context),
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          user: _user,
        ),
      ),
    );
  }
}
