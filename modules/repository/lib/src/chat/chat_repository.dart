import 'package:api/api.dart';
import 'package:core/core.dart';

class ChatRepository extends AppRepository {
  factory ChatRepository() {
    return _singleton;
  }

  ChatRepository._internal();

  static final ChatRepository _singleton = ChatRepository._internal();

  Future<List<AppChatChannel>> getChannels() async {
    final response = await const GetRequest('/chat/get-channels', secure: true)
        .callRequest(dio);
    return response.asList().map(AppChatChannel.fromJson).toList();
  }

  Future<List<AppChatMessage>> getMessages(int channelId) async {
    final response = await GetRequest(
      '/chat/get-messages',
      query: {
        'channel_id': channelId.toString(),
      },
      secure: true,
    ).callRequest(dio);
    return response.asList().map(AppChatMessage.fromJson).toList();
  }

  Future<Response> sendMessages(int channelId, String message) async {
    final response = await PostRequest(
      '/chat/store-message',
      query: {
        'channel_id': channelId.toString(),
        'message': message,
      },
      secure: true,
    ).getResponse(dio);
    return response;
  }

  Future uploadChatFile(int chatId, String file) async {
    final formData = FormData.fromMap({
      'channel_id': chatId,
      'file': XFile(file, name: file.split('/').last)
    });

    formData.files.add(
      MapEntry(
        'file',
        await MultipartFile.fromFile(
          file,
          filename: file.split('/').last,
        ),
      ),
    );

    final response = await FileUploadRequest(
      '/chat/store-message',
      formData: formData,
      secure: true,
    ).upload(dio);

    return response.data;
  }

  Future uploadChatImage(int chatId, String imagePath) async {
    final formData = FormData.fromMap({
      'channel_id': chatId,
    });

    formData.files.add(
      MapEntry(
        'image',
        await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      ),
    );

    final response = await FileUploadRequest(
      '/chat/store-message',
      formData: formData,
      secure: true,
    ).upload(dio);

    return response.data;
  }
}
