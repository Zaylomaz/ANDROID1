part of 'sign_up_screen.dart';

/// Модель данных регистрации
class SingUpBody {
  const SingUpBody({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.cityId,
    required this.companyId,
    required this.homeAddress,
    required this.onesignalUserid,
    required this.themas,
    this.avatar,
  });

  /// Собирвет объект [FormData] для отправки
  Future<FormData> toFormData() async {
    final data = FormData.fromMap({
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'city_id': cityId,
      'company_id': companyId,
      'home_address': homeAddress,
      'onesignalUserid': onesignalUserid,
      'themas[]': themas,
    });
    if (avatar != null) {
      data.files.add(MapEntry(
          'avatar',
          await MultipartFile.fromFile(avatar!.path,
              filename: avatar!.path.split('/').last)));
    }
    return data;
  }

  final String name;
  final String email;
  final String phone;
  final String password;
  final int cityId;
  final int companyId;
  final String homeAddress;
  final String onesignalUserid;
  final XFile? avatar;
  final List<int> themas;
}
