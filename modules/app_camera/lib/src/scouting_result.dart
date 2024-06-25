import 'package:app_camera/app_camera.dart';
import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

class ScoutingResultScreenArgs {
  const ScoutingResultScreenArgs(this.file);
  final ScoutingFile file;
}

class ScoutingResultScreen extends StatelessWidget {
  const ScoutingResultScreen({
    required this.args,
    Key? key,
  }) : super(key: key);

  final ScoutingResultScreenArgs args;

  static const String routeName = '/scouting/photo_preview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppToolbar(
        leading: AppIcons.arrowPop.iconButton(
          onPressed: () => Navigator.of(context).maybePop(false),
        ),
        title: Text(
          DateFormat('dd MMM yyyy HH:mm', 'ru').format(args.file.createDate),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Image.file(
                  args.file.asFile,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PrimaryButton.green(
              onPressed: () => Navigator.of(context).pop(true),
              text: 'Загрузить',
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
