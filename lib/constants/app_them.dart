import 'package:dashboard/constants/parcel.dart';
import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color onPrimar;
  final Color secondary;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
  final Color disabled;

  const AppColors({
    required this.primary,
    required this.onPrimar,
    required this.secondary,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.disabled,
  });

  @override
  ThemeExtension<AppColors> copyWith({
    Color? primary,
    Color? onPrimar,
    Color? secondary,
    Color? error,
    Color? success,
    Color? warning,
    Color? info,
    Color? disabled,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimar: onPrimar ?? this.onPrimar,
      secondary: secondary ?? this.secondary,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
      ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimar: Color.lerp(onPrimar, other.onPrimar, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
    );
  }
  Color get onPrimary => this.onPrimar ?? Colors.black; // قيمة افتراضية
  static const light = AppColors(
    primary: Color(0xFF6200EE),
    onPrimar: Color(0xFFFFFFFF),
    secondary: Color(0xFF03DAC6),
    error: Color(0xFFB00020),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFFC107),
    info: Color(0xFF2196F3),
    disabled: Color(0xFF9E9E9E),
  );

  static const dark = AppColors(
    primary: Color(0xFFBB86FC),
    onPrimar: Color(0xFF000000),
    secondary: Color(0xFF03DAC6),
    error: Color(0xFFCF6679),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFFC107),
    info: Color(0xFF2196F3),
    disabled: Color(0xFF616161),
  );
}

ThemeData appTheme(BuildContext context, bool isDarkMode) {
  final colors = isDarkMode ? AppColors.dark : AppColors.light;

  return ThemeData(
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
    extensions: <ThemeExtension<dynamic>>[colors],
    colorScheme: ColorScheme(
      primary: colors.primary,
      onPrimary: colors.onPrimar,
      secondary: colors.secondary,
      onSecondary: colors.onPrimar,
      error: colors.error,
      onError: colors.onPrimar,
      background: isDarkMode ? Color(0xFF121212) : Color(0xFFF5F5F5),
      onBackground: isDarkMode ? Colors.white : Colors.black,
      surface: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
      onSurface: isDarkMode ? Colors.white : Colors.black,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDarkMode ? Color(0xFF2D2D2D) : Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}