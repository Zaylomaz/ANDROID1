import 'package:core/core.dart';
import 'package:rempc/screens/chat/chat_screen.dart';
import 'package:uikit/uikit.dart';

class ChannelsListItem extends StatelessWidget {
  const ChannelsListItem({
    required this.chat,
    super.key,
  });

  final AppChatChannel chat;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(
          ChatScreen.routeName,
          arguments: chat,
        );
      },
      leading: AppListTileLeading(
        child: Image.network(
          chat.image.toString(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.white,
              ),
            );
          },
          errorBuilder: (context, error, trace) => AppIcons.chat.widget(
            color: AppColors.violet,
          ),
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        chat.name.isNotEmpty == true ? chat.name : chat.id.toString(),
        style: AppTextStyle.boldHeadLine.style(context),
      ),
      subtitle: Text(
        chat.lastMessage?.text.isNotEmpty == true
            ? '${chat.lastMessage?.authorName}: ${chat.lastMessage?.text}'
            : 'Нет сообщений. Будь первым!',
        style: AppTextStyle.regularCaption.style(
          context,
          AppColors.violetLight,
        ),
      ),
      trailing: chat.lastMessage?.date.isNotEmpty == true
          ? Text(
              chat.lastMessage!.date,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            )
          : null,
    );
  }
}
