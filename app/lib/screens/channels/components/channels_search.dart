import 'package:core/core.dart';
import 'package:uikit/uikit.dart';

class ChannelsSearch extends StatefulWidget {
  const ChannelsSearch({super.key});

  @override
  ChannelsSearchState createState() => ChannelsSearchState();
}

class ChannelsSearchState extends State<ChannelsSearch> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Поиск...',
          hintStyle: const TextStyle(color: Colors.white),
          labelStyle: const TextStyle(color: Colors.white),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.white,
            size: 20,
          ),
          filled: true,
          fillColor: AppColors.violetLightDark,
          contentPadding: const EdgeInsets.all(8),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.grey)),
        ),
      ),
    );
  }
}
