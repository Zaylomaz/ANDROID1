import 'dart:async';

import 'package:api/api.dart';
import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:rempc/config/router_manager.dart';
import 'package:rempc/model/chat_model.dart';
import 'package:rempc/model/user_model.dart';
import 'package:rempc/screens/chat/chat_screen.dart';
import 'package:rempc/screens/sign_in/sign_in_screen.dart';
import 'package:rempc/screens/to_many_request/to_many_request_screen.dart';
import 'package:repository/repository.dart';
import 'package:uikit/uikit.dart';

class ChannelsList extends StatefulWidget {
  const ChannelsList({super.key});

  @override
  State<ChannelsList> createState() => _ChannelsListState();
}

class _ChannelsListState extends State<ChannelsList> {
  List<AppChatChannel> _channels = [];
  bool _isFetch = false;

  Future<void> _fetchData() async {
    try {
      final channels = await ChatRepository().getChannels();
      setState(() {
        _isFetch = true;
        _channels = channels;
      });
      await _resetCurrentChatId();
    } catch (e) {
      if (e is TooManyRequestsException) {
        unawaited(Navigator.of(context)
            .pushReplacementNamed(ToManyRequestScreen.routeName));
      }
      if (e is UnauthorizedException) {
        unawaited(Navigator.of(AppRouter
                .navigatorKeys[AppRouter.mainNavigatorKey]!.currentContext!)
            .pushReplacementNamed(SignInScreen.routeName));
      }
    }
  }

  Future<void> _resetCurrentChatId() async {
    const platform = MethodChannel('helperService');
    await platform.invokeMethod('setCurrentChannelId', {'channelId': 0});
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetch == false) {
      return const Center(child: CircularProgressIndicator());
    }

    final chatModel = context.read<ChatModel>();
    if (chatModel.channelId != 0) {
      _fetchData();
      chatModel.channelId = 0;
    }
    final userModel = context.read<HomeData>();
    if (userModel.userChannelId != '') {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushNamed(
          ChatScreen.routeName,
          arguments: int.parse(
            userModel.userChannelId,
          ),
        );
        userModel.userChannelId = '';
      });
    }

    return _channels.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ваш список чатов пуст',
                  style: AppTextStyle.boldTitle2.style(context),
                ),
                const SizedBox(height: 8),
                Text(
                  '''На данный момент вам не доступен ни один чат. При добавлении нового, вы получите уведомление''',
                  style: AppTextStyle.regularHeadline.style(
                    context,
                    AppColors.violetLight,
                  ),
                ),
              ],
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _channels.length,
            itemBuilder: (ctx, index) {
              final chat = _channels[index];
              return AppMaterialBox(
                key: ValueKey<String>('${chat.id}'),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      ChatScreen.routeName,
                      arguments: chat,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        AppListTileLeading(
                          child: Image.network(
                            chat.image.toString(),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: AppColors.white,
                                ),
                              );
                            },
                            errorBuilder: (context, error, trace) =>
                                AppIcons.chatDef.widget(
                              color: AppColors.violet,
                              width: 48,
                              height: 48,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat.name.isNotEmpty == true
                                    ? chat.name
                                    : chat.id.toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.boldHeadLine.style(context),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                chat.lastMessage?.text.isNotEmpty == true
                                    ? '''${chat.lastMessage?.authorName}: ${chat.lastMessage?.text}'''
                                    : 'Нет сообщений. Будь первым!',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.regularCaption.style(
                                  context,
                                  AppColors.violetLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (chat.lastMessage?.date.isNotEmpty == true)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              chat.lastMessage!.date,
                              style: AppTextStyle.regularCaption.style(context),
                            ),
                          ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
          );
  }
}
