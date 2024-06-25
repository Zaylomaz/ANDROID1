import 'package:core/core.dart';
import 'package:rempc/provider/view_state.dart';
import 'package:uikit/uikit.dart';

@Deprecated('Перестать использовать и удалить')
class ViewStateBusyWidget extends StatelessWidget {
  const ViewStateBusyWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: AppLoadingIndicator());
  }
}

@Deprecated('Перестать использовать и удалить')
class ViewStateWidget extends StatelessWidget {
  const ViewStateWidget({
    required this.onPressed,
    super.key,
    this.image,
    this.title,
    this.message,
    this.buttonText,
    this.buttonTextData,
  });

  final String? title;
  final String? message;
  final Widget? image;
  final Widget? buttonText;
  final String? buttonTextData;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppTextStyle.regularHeadline.style(context);
    final messageStyle = AppTextStyle.regularSubHeadline.style(
      context,
      AppColors.violetLight,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        image ?? AppIcons.attention.widget(color: AppColors.red),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          child: Column(
            children: <Widget>[
              Text(
                title ?? 'Ошибка',
                style: titleStyle,
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 200,
                  minHeight: 150,
                ),
                child: SingleChildScrollView(
                  child: Text(message ?? '', style: messageStyle),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: ViewStateButton(
            textData: buttonTextData ?? 'Повторить',
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }
}

@Deprecated('Перестать использовать и удалить')
class ViewStateErrorWidget extends StatelessWidget {
  const ViewStateErrorWidget({
    required this.error,
    required this.onPressed,
    super.key,
    this.image,
    this.title,
    this.message,
    this.buttonText,
    this.buttonTextData,
  });

  final ViewStateError error;
  final String? title;
  final String? message;
  final Widget? image;
  final Widget? buttonText;
  final String? buttonTextData;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    Widget? defaultImage;
    String? defaultTitle;
    var errorMessage = error.message;
    const defaultTextData = 'Повторить';
    switch (error.errorType) {
      case ErrorType.networkError:
        defaultImage = AppIcons.attention.widget(color: AppColors.red);
        defaultTitle = 'Ошибка сети';
        errorMessage = '';
        break;
      case ErrorType.defaultError:
        defaultImage = AppIcons.attention.widget(color: AppColors.red);
        defaultTitle = 'Ошибка';
        break;
      case null:
        break;
    }

    return ViewStateWidget(
      onPressed: onPressed,
      image: image ?? defaultImage,
      title: title ?? defaultTitle,
      message: message ?? errorMessage,
      buttonTextData: buttonTextData ?? defaultTextData,
      buttonText: buttonText ?? const Text('Повторить'),
    );
  }
}

@Deprecated('Перестать использовать и удалить')
class ViewStateEmptyWidget extends StatelessWidget {
  const ViewStateEmptyWidget({
    required this.onPressed,
    super.key,
    this.image,
    this.message,
    this.buttonText,
  });

  final String? message;
  final Widget? image;
  final Widget? buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ViewStateWidget(
      onPressed: onPressed ?? () {},
      title: 'Пусто',
      buttonText: buttonText ?? const Text('Обновить'),
      buttonTextData: 'Обновить',
    );
  }
}

@Deprecated('Перестать использовать и удалить')
class ViewStateButton extends StatelessWidget {
  const ViewStateButton({
    required this.onPressed,
    required this.textData,
    super.key,
  });

  final VoidCallback? onPressed;
  final String textData;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton.violet(
      onPressed: onPressed,
      text: textData,
    );
  }
}
