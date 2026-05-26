// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../core/data/remote/services/ai_service.dart' as _i780;
import '../../core/data/remote/services/auth_service.dart' as _i894;
import '../../core/data/remote/services/barcode_service.dart' as _i461;
import '../../core/data/remote/services/gemini_service.dart' as _i238;
import '../../core/data/remote/services/groq_service.dart' as _i975;
import '../../core/data/remote/services/haptic_service.dart' as _i635;
import '../../core/data/remote/services/ocr_service.dart' as _i670;
import '../../core/data/remote/services/onboarding_service.dart' as _i702;
import '../../core/data/remote/services/scan_history_service.dart' as _i78;
import '../../core/data/remote/services/storage_service.dart' as _i1036;
import '../../core/data/remote/services/user_profile_service.dart' as _i806;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i780.AIService>(() => _i780.AIService());
    gh.lazySingleton<_i894.AuthService>(() => _i894.AuthService());
    gh.lazySingleton<_i461.BarcodeService>(() => _i461.BarcodeService());
    gh.lazySingleton<_i238.GeminiService>(() => _i238.GeminiService());
    gh.lazySingleton<_i975.GroqService>(() => _i975.GroqService());
    gh.lazySingleton<_i635.HapticService>(() => _i635.HapticService());
    gh.lazySingleton<_i670.OCRService>(() => _i670.OCRService());
    gh.lazySingleton<_i702.OnboardingService>(() => _i702.OnboardingService());
    gh.lazySingleton<_i78.ScanHistoryService>(() => _i78.ScanHistoryService());
    gh.lazySingleton<_i1036.StorageService>(() => _i1036.StorageService());
    gh.lazySingleton<_i806.UserProfileService>(
      () => _i806.UserProfileService(),
    );
    return this;
  }
}
