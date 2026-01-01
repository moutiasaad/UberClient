import 'package:tshl_tawsil/localization/ar_sa.dart';
import 'package:tshl_tawsil/localization/de_de.dart';
import 'package:tshl_tawsil/localization/en_us.dart';
import 'package:tshl_tawsil/localization/fr_fr.dart';
import 'package:tshl_tawsil/localization/zn_ch.dart';

import 'hi_in.dart';

abstract class AppTranslation {
  static Map<String, Map<String, String>> translationsKeys = {
    "en": enUS,
    "hi": hiIN,
    "ar": arSA,
    "de": deDE,
    "fr": frFR,
    "zh": zhCN
  };
}
