import 'package:get/get.dart';
import 'package:aub_connect_app/core/localization/translations/en_us.dart';
import 'package:aub_connect_app/core/localization/translations/km_kh.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'km_KH': kmKH,
      };
}
