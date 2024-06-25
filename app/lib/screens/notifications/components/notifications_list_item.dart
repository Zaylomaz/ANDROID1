import 'package:core/core.dart';
import 'package:sip/sip.dart';
import 'package:uikit/uikit.dart';

abstract class NotificationListItemBody extends StatelessWidget {
  const NotificationListItemBody(this.notification, {super.key});
  final NotificationBase notification;
}

class NotificationsListItem extends StatelessWidget {
  const NotificationsListItem(
    this.notification, {
    super.key,
  });

  final NotificationBase notification;

  NotificationListItemBody get body {
    switch (notification.type) {
      case NotificationType.managerLostCall:
        return _NotificationManagerLostCall(notification);
      case NotificationType.lostCall:
        return _NotificationLostCall(notification);
      case NotificationType.newChatMessage:
      case NotificationType.newOrderMakeOut:
        return _NotificationNewOrderMakeOut(notification);
      case NotificationType.newOrder:
        return _NotificationNewOrder(notification);
      case NotificationType.finishedOrder:
        return _NotificationFinishedOrder(notification);
      case NotificationType.orderChange:
        return _NotificationAboutOrder(notification);
      case NotificationType.penalty:
        return _NotificationDanger(notification);
      case NotificationType.undefined:
        return _NotificationUndefined(notification);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: AppMaterialBox(
        borderSide: BorderSide(width: 2, color: notification.decorationColor),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: body,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: BadgeDrop(
                color: notification.decorationColor,
                icon: AppIcons.bell,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _NotificationNewOrder extends NotificationListItemBody {
  const _NotificationNewOrder(super.notification);

  NotificationNewOrder get body =>
      NotificationNewOrder.fromJson(notification.data);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DateFormat('yyyy-MM-dd HH:mm:ss', 'ru')
              .format(notification.createAt.toLocal()),
          style: AppTextStyle.regularCaption.style(
            context,
            AppColors.violetLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body.title,
          style: AppTextStyle.regularSubHeadline.style(
            context,
            AppColors.violet,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          body.message,
          style: AppTextStyle.regularCaption.style(context),
        ),
      ],
    );
  }
}

class _NotificationAboutOrder extends NotificationListItemBody {
  const _NotificationAboutOrder(super.notification);

  NotificationAboutOrder get body =>
      NotificationAboutOrder.fromJson(notification.data);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DateFormat('yyyy-MM-dd HH:mm:ss', 'ru')
              .format(notification.createAt.toLocal()),
          style: AppTextStyle.regularCaption.style(
            context,
            AppColors.violetLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body.title,
          style: AppTextStyle.regularSubHeadline.style(
            context,
            AppColors.violet,
          ),
        ),
        const SizedBox(height: 12),
        DefaultTextStyle.merge(
          style: AppTextStyle.regularSubHeadline.style(context),
          child: Row(
            children: [
              Text('# ${body.orderNumber}'),
              const SizedBox(width: 16),
              Text(body.orderDate),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: IconWithTextRow(
                text: body.clientName,
                leading: AppIcons.user.iconColored(
                  color: AppSplitColor.cyan(),
                  iconSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ListenableBuilder(
                listenable: context.read<SipModel>(),
                builder: (context, _) {
                  return CallButton(
                    isSipActive: context.read<SipModel>().isActive,
                    phone: body.contacts.primary,
                    additionalPhones: body.contacts.additional,
                    onMakeCall: context.read<SipModel>().makeCall,
                    onTryCall: () {
                      showMessage(
                        context,
                        message: 'SIP клиент не активен',
                        type: AppMessageType.error,
                      );
                    },
                  );
                }),
          ],
        ),
        const SizedBox(height: 8),
        IconWithTextRow(
          text: body.status,
          textColor: AppColors.green,
          leading: AppIcons.status.iconColored(
            color: AppSplitColor.green(),
            iconSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          body.message,
          style: AppTextStyle.regularCaption.style(context),
        ),
      ],
    );
  }
}

class _NotificationFinishedOrder extends NotificationListItemBody {
  const _NotificationFinishedOrder(super.notification);

  NotificationFinishedOrder get body =>
      NotificationFinishedOrder.fromJson(notification.data);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              DateFormat('yyyy-MM-dd HH:mm:ss', 'ru')
                  .format(notification.createAt.toLocal()),
              style: AppTextStyle.regularCaption.style(
                context,
                AppColors.violetLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body.title,
              style: AppTextStyle.regularSubHeadline.style(
                context,
                AppColors.violet,
              ),
            ),
            const SizedBox(height: 12),
            IconWithTextRow(
              text: body.user,
              leading: AppIcons.users.iconColored(
                color: AppSplitColor.cyan(),
                iconSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            IconWithTextRow(
              text: body.orderSum,
              leading: AppIcons.wallet.iconColored(
                color: AppSplitColor.violetLight(),
                iconSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            IconWithTextRow(
              text: body.status,
              textColor: AppColors.green,
              leading: AppIcons.status.iconColored(
                color: AppSplitColor.green(),
                iconSize: 16,
              ),
            ),
          ],
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: CallButton(
            isSipActive: context.read<SipModel>().isActive,
            phone: body.userContacts.primary,
            additionalPhones: body.userContacts.additional,
            binotel: body.userContacts.binotel,
            asterisk: body.userContacts.asterisk,
            ringostat: body.userContacts.ringostat,
            onMakeCall: (phone) async {
              await context.read<SipModel>().makeCall(phone);
            },
            onTryCall: () {},
          ),
        ),
      ],
    );
  }
}

class _NotificationNewOrderMakeOut extends NotificationListItemBody {
  const _NotificationNewOrderMakeOut(super.notification);

  NotificationNewOrderMakeOut get body =>
      NotificationNewOrderMakeOut.fromJson(notification.data);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DateFormat('yyyy-MM-dd HH:mm:ss', 'ru')
              .format(notification.createAt.toLocal()),
          style: AppTextStyle.regularCaption.style(
            context,
            AppColors.violetLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body.title,
          style: AppTextStyle.regularSubHeadline.style(
            context,
            AppColors.violet,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${body.date} ${body.time}',
          style: AppTextStyle.regularSubHeadline.style(context),
        ),
        if (body.isUrgently) ...[
          const SizedBox(height: 8),
          IconWithTextRow(
            text: 'Срочный заказ',
            textColor: AppColors.red,
            leading: AppIcons.alert.iconColored(
              color: AppSplitColor.red(),
              iconSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 8),
        IconWithTextRow(
          text: body.clientName,
          leading: AppIcons.user.iconColored(
            color: AppSplitColor.violet(),
            iconSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        IconWithTextRow(
          text: body.city,
          leading: AppIcons.city.iconColored(
            color: AppSplitColor.violet(),
            iconSize: 16,
          ),
        ),
        if (body.defect.isNotEmpty) ...[
          const SizedBox(height: 8),
          IconWithTextRow(
            text: body.defect,
            textColor: AppColors.red,
            leading: AppIcons.repair.iconColored(
              color: AppSplitColor.red(),
              iconSize: 16,
            ),
          ),
        ],
        const SizedBox(height: 8),
        IconWithTextRow(
          text: body.technique,
          leading: AppIcons.chip.iconColored(
            color: AppSplitColor.violetLight(),
            iconSize: 16,
          ),
        ),
      ],
    );
  }
}

class _NotificationDanger extends NotificationListItemBody {
  const _NotificationDanger(super.notification);

  NotificationDanger get body => NotificationDanger.fromJson(notification.data);

  RichText richMessage(BuildContext context) {
    final input = body.message;
    // Regular expression to match the pattern including the delimiters
    final pattern = RegExp(r'(\*\*.*?\*\*)');

    // Splitting the string using the pattern
    final parts = <String>[];
    var lastEnd = 0;

    // Find matches and split the string accordingly
    pattern.allMatches(input).forEach((match) {
      final group = match.group(0);
      // Add the text before the match
      parts
        ..add(input.substring(lastEnd, match.start))
        // Add the text within the delimiters
        ..add('accent_${group!.replaceAll('**', '')}');
      lastEnd = match.end;
    });

    // Add the remaining part of the string after the last match
    if (lastEnd < input.length) {
      parts.add(input.substring(lastEnd));
    }
    return RichText(
      text: TextSpan(
        style: AppTextStyle.regularCaption.style(context),
        children: parts.map(
          (e) {
            if (!e.contains('accent_')) {
              return TextSpan(text: e);
            }
            return TextSpan(
              text: e.replaceAll('accent_', ''),
              style: const TextStyle(
                color: AppColors.violetLight,
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DateFormat('yyyy-MM-dd  HH:mm:ss', 'ru')
              .format(notification.createAt.toLocal()),
          style: AppTextStyle.regularCaption.style(
            context,
            AppColors.violetLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body.title,
          style: AppTextStyle.regularSubHeadline.style(
            context,
            AppColors.red,
          ),
        ),
        const SizedBox(height: 12),
        richMessage(context),
      ],
    );
  }
}

class _NotificationLostCall extends NotificationListItemBody {
  const _NotificationLostCall(super.notification);

  NotificationLostCall get body =>
      NotificationLostCall.fromJson(notification.data);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DateFormat('yyyy-MM-dd  HH:mm:ss', 'ru')
              .format(notification.createAt.toLocal()),
          style: AppTextStyle.regularCaption.style(
            context,
            AppColors.violetLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body.title,
          style: AppTextStyle.regularSubHeadline.style(
            context,
            AppColors.red,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          body.message,
          style: AppTextStyle.regularCaption.style(context),
        ),
      ],
    );
  }
}

class _NotificationManagerLostCall extends NotificationListItemBody {
  const _NotificationManagerLostCall(super.notification);

  NotificationManagerLostCall get body =>
      NotificationManagerLostCall.fromJson(notification.data);

  RichText richMessage(BuildContext context) {
    final input = body.message;
    // Regular expression to match the pattern including the delimiters
    final pattern = RegExp(r'(\*\*.*?\*\*)');

    // Splitting the string using the pattern
    final parts = <String>[];
    var lastEnd = 0;

    // Find matches and split the string accordingly
    pattern.allMatches(input).forEach((match) {
      final group = match.group(0);
      // Add the text before the match
      parts
        ..add(input.substring(lastEnd, match.start))
        // Add the text within the delimiters
        ..add('accent_${group!.replaceAll('**', '')}');
      lastEnd = match.end;
    });

    // Add the remaining part of the string after the last match
    if (lastEnd < input.length) {
      parts.add(input.substring(lastEnd));
    }
    return RichText(
      text: TextSpan(
        style: AppTextStyle.regularCaption.style(context),
        children: parts.map(
          (e) {
            if (!e.contains('accent_')) {
              return TextSpan(text: e);
            }
            return TextSpan(
              text: e.replaceAll('accent_', ''),
              style: const TextStyle(
                color: AppColors.violetLight,
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DateFormat('yyyy-MM-dd  HH:mm:ss', 'ru')
              .format(notification.createAt.toLocal()),
          style: AppTextStyle.regularCaption.style(
            context,
            AppColors.violetLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body.title,
          style: AppTextStyle.regularSubHeadline.style(
            context,
            AppColors.red,
          ),
        ),
        const SizedBox(height: 12),
        richMessage(context),
      ],
    );
  }
}

class _NotificationUndefined extends NotificationListItemBody {
  const _NotificationUndefined(super.notification);

  @override
  Widget build(BuildContext context) {
    return Text(
      'UNDEFINED',
      style: AppTextStyle.regularSubHeadline.style(context),
    );
  }
}
