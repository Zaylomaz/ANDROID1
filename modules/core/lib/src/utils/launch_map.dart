import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

/// TODO редизайн модалки
/// Метод отображения локации в приложении нивигации
///
/// Метод вызывает BottomSheet с списком доступных карт на телефоне если
/// установленных карт более одной

Future<bool> launchMap(
  BuildContext context, {
  required Coords location,
}) async {
  final bannedMaps = [
    MapType.doubleGis,
    MapType.yandexMaps,
    MapType.yandexNavi,
  ];
  final webMap = AvailableMap.fromJson({
    'mapName': 'Web карта',
    'mapType': 'google',
  }) as AvailableMap;
  final maps = await MapLauncher.installedMaps;
  final availableMaps = [
    ...maps.where((e) => !bannedMaps.contains(e.mapType)),
    webMap,
  ];
  if (availableMaps.isNotEmpty) {
    AvailableMap? selectedMap;
    if (availableMaps.length == 1) {
      selectedMap = availableMaps.first;
    } else {
      selectedMap = await showMaterialModalBottomSheet<AvailableMap?>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return MaterialBottomSheetLayout(
            title: 'Выбирите карту',
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 24,
                mainAxisSpacing: 16,
                childAspectRatio: 68 / 78,
              ),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final icon = Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: SvgPicture.asset(availableMaps[index].icon),
                );
                final text = Text(
                  availableMaps[index].mapName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.regularCaption.style(context),
                );
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(availableMaps[index]),
                  child: Column(
                    children: [
                      icon,
                      const SizedBox(height: 8),
                      text,
                    ],
                  ),
                );
              },
              itemCount: availableMaps.length,
            ),
          );
        },
      );
    }
    if (selectedMap is AvailableMap) {
      if (selectedMap.mapName != 'Открыть в браузере') {
        await selectedMap.showMarker(
          coords: location,
          title: 'Заказ',
        );
      } else {
        if (await canLaunchUrl(location.googleMapsUri)) {
          await launchUrl(location.googleMapsUri);
        }
      }
      return true;
    }
    return false;
  }
  return false;
}
