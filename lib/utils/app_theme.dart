// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

const kThemeModeKey = '__theme_mode__';

SharedPreferences? _prefs;

abstract class AppTheme {
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.system
        : darkMode
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static AppTheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkModeTheme()
        : LightModeTheme();
  }

  /// Creates a ThemeData object for light mode that can be used in GetMaterialApp
  static ThemeData get lightTheme {
    final theme = LightModeTheme();
    final typography = ThemeTypography(theme);

    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      scaffoldBackgroundColor: theme.primaryBackground,
      colorScheme: ColorScheme.light(
        primary: theme.accent1, // Use accent1 for buttons (including Stripe)
        secondary: theme.secondary,
        tertiary: theme.tertiary,
        error: theme.error,
        surface: theme.secondaryBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: theme.primaryText,
        onBackground: theme.primaryText,
      ),
      textTheme: TextTheme(
        displayLarge: typography.displayLarge,
        displayMedium: typography.displayMedium,
        displaySmall: typography.displaySmall,
        headlineLarge: typography.headlineLarge,
        headlineMedium: typography.headlineMedium,
        headlineSmall: typography.headlineSmall,
        titleLarge: typography.titleLarge,
        titleMedium: typography.titleMedium,
        titleSmall: typography.titleSmall,
        labelLarge: typography.labelLarge,
        labelMedium: typography.labelMedium,
        labelSmall: typography.labelSmall,
        bodyLarge: typography.bodyLarge,
        bodyMedium: typography.bodyMedium,
        bodySmall: typography.bodySmall,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: theme.primaryBackground,
        foregroundColor: theme.primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: theme.primaryText),
        titleTextStyle: typography.headlineSmall.copyWith(
          color: theme.primaryText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: theme.textFieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.accent1, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.error),
        ),
        labelStyle: typography.bodyMedium.copyWith(color: theme.secondaryText),
        hintStyle: typography.bodyMedium.copyWith(color: theme.secondaryText),
      ),
      cardTheme: CardThemeData(
        color: theme.secondaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.borderColor.withOpacity(0.3)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: theme.dialogBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: typography.headlineSmall.copyWith(
          color: theme.primaryText,
        ),
        contentTextStyle: typography.bodyMedium.copyWith(
          color: theme.primaryText,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: theme.bottomsheatBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: DividerThemeData(color: theme.dividerColor, thickness: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.accent1,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: typography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.accent1,
          side: BorderSide(color: theme.borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: typography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: theme.accent1,
          textStyle: typography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return theme.accent1;
          }
          return theme.borderColor;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return theme.accent1.withOpacity(0.5);
          }
          return theme.borderColor.withOpacity(0.3);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return theme.accent1;
          }
          return null;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return theme.accent1;
          }
          return theme.borderColor;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: theme.textFieldColor,
        selectedColor: theme.accent1,
        labelStyle: typography.bodySmall,
        secondaryLabelStyle: typography.bodySmall.copyWith(color: Colors.white),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  /// Creates a ThemeData object for dark mode that can be used in GetMaterialApp
  static ThemeData get darkTheme {
    final theme = DarkModeTheme();
    final typography = ThemeTypography(theme);

    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: theme.primaryBackground,
      colorScheme: ColorScheme.dark(
        primary: theme.accent1,
        secondary: theme.secondary,
        tertiary: theme.tertiary,
        error: theme.error,
        surface: theme.secondaryBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: theme.primaryText,
        onBackground: theme.primaryText,
      ),
      textTheme: TextTheme(
        displayLarge: typography.displayLarge,
        displayMedium: typography.displayMedium,
        displaySmall: typography.displaySmall,
        headlineLarge: typography.headlineLarge,
        headlineMedium: typography.headlineMedium,
        headlineSmall: typography.headlineSmall,
        titleLarge: typography.titleLarge,
        titleMedium: typography.titleMedium,
        titleSmall: typography.titleSmall,
        labelLarge: typography.labelLarge,
        labelMedium: typography.labelMedium,
        labelSmall: typography.labelSmall,
        bodyLarge: typography.bodyLarge,
        bodyMedium: typography.bodyMedium,
        bodySmall: typography.bodySmall,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: theme.primaryBackground,
        foregroundColor: theme.primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: theme.primaryText),
        titleTextStyle: typography.headlineSmall.copyWith(
          color: theme.primaryText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: theme.textFieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.accent1, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.error),
        ),
        labelStyle: typography.bodyMedium.copyWith(color: theme.secondaryText),
        hintStyle: typography.bodyMedium.copyWith(color: theme.secondaryText),
      ),
      cardTheme: CardThemeData(
        color: theme.secondaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.borderColor.withOpacity(0.3)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: theme.dialogBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: typography.headlineSmall.copyWith(
          color: theme.primaryText,
        ),
        contentTextStyle: typography.bodyMedium.copyWith(
          color: theme.primaryText,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: theme.bottomsheatBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: DividerThemeData(color: theme.dividerColor, thickness: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.accent1,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: typography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.accent1,
          side: BorderSide(color: theme.borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: typography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: theme.accent1,
          textStyle: typography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return theme.accent1;
          }
          return theme.borderColor;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return theme.accent1.withOpacity(0.5);
          }
          return theme.borderColor.withOpacity(0.3);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return theme.accent1;
          }
          return null;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return theme.accent1;
          }
          return theme.borderColor;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: theme.textFieldColor,
        selectedColor: theme.accent1,
        labelStyle: typography.bodySmall,
        secondaryLabelStyle: typography.bodySmall.copyWith(color: Colors.white),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  late Color darkGray;
  late Color textGreyColor;
  late Color borderColor;
  late Color textFieldColor;
  late Color dividerColor;
  late Color whiteAndGray;
  late Color homeOrderPlacedBackground;
  late Color homePointsBackground;
  late Color darkAndLightGray;
  late Color peach;
  late Color attributeCardBg;
  late Color pinCodeLightGreyAndGrey;
  late Color variantCardBg;
  late Color secondaryForground;
  late Color addToCartCardShadowColor;
  late Color attributeCardShadowColor;
  late Color minusBtnBgColor;
  late Color minusBtnIconColor;
  late Color cartDividerColor;
  late Color pickupLocationAndTimeTile;
  late Color bottomsheatBackground;
  late Color shadowLightTheme;
  late Color coffeeAndDarkGrey;
  late Color coffeeAndWhite;
  late Color darkGrayAndWhite;
  late Color whiteAndDarkGrey;
  late Color goldTier;
  late Color silverTier;
  late Color dialogBackground;
  late Color shadow;
  late Color deleteRed;
  late Color greyShades;
  late Color accentBlack;
  late Color peachGrey;
  late Color lightGreyDarkGrey;

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

  String get displayLargeFamily => typography.displayLargeFamily;
  bool get displayLargeIsCustom => typography.displayLargeIsCustom;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  bool get displayMediumIsCustom => typography.displayMediumIsCustom;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  bool get displaySmallIsCustom => typography.displaySmallIsCustom;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  bool get headlineLargeIsCustom => typography.headlineLargeIsCustom;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  bool get headlineMediumIsCustom => typography.headlineMediumIsCustom;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  bool get headlineSmallIsCustom => typography.headlineSmallIsCustom;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  bool get titleLargeIsCustom => typography.titleLargeIsCustom;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  bool get titleMediumIsCustom => typography.titleMediumIsCustom;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  bool get titleSmallIsCustom => typography.titleSmallIsCustom;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  bool get labelLargeIsCustom => typography.labelLargeIsCustom;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  bool get labelMediumIsCustom => typography.labelMediumIsCustom;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  bool get labelSmallIsCustom => typography.labelSmallIsCustom;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  bool get bodyLargeIsCustom => typography.bodyLargeIsCustom;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  bool get bodyMediumIsCustom => typography.bodyMediumIsCustom;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  bool get bodySmallIsCustom => typography.bodySmallIsCustom;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends AppTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF636AE8);
  late Color secondary = const Color(0xFF222628);
  late Color tertiary = const Color(0xFFB6B6B6);
  late Color alternate = const Color(0xFF1C1C1C);
  late Color primaryText = const Color(0xFF14181B);
  late Color secondaryText = const Color(0xFF57636C);
  late Color primaryBackground = const Color(0xFFFEFEFE);
  late Color secondaryBackground = const Color(0xFFFFFFFF);
  late Color accent1 = const Color(0xFF636AE8);
  late Color accent2 = const Color(0xFFFFEEDF);
  late Color accent3 = const Color(0xFF42973E);
  late Color accent4 = const Color(0xFF6C6E73);
  late Color success = const Color(0xFF249689);
  late Color warning = const Color(0xFFF9CF58);
  late Color error = const Color(0xFFFF5963);
  late Color info = const Color(0xFFFFFFFF);

  late Color darkGray = const Color(0xFF303436);
  late Color textGreyColor = const Color(0xFF6C6E73);
  late Color borderColor = const Color(0xFF6C6E73);
  late Color textFieldColor = const Color(0xFFEFEFEF);
  late Color dividerColor = const Color(0x21373535);

  late Color whiteAndGray = const Color(0xFFFFFFFF);
  late Color homeOrderPlacedBackground = const Color(0xFFFBF6F2);
  late Color homePointsBackground = const Color(0xFFFEFEFE);
  late Color darkAndLightGray = const Color(0xFFEFEFEF);
  late Color peach = const Color(0xFFFFEEDF);
  late Color attributeCardBg = const Color(0xFFFFFFFF);
  late Color pinCodeLightGreyAndGrey = const Color(0xFFEFEFEF);
  late Color variantCardBg = const Color(0xFFEFEFEF);
  late Color secondaryForground = const Color(0xFF222628);
  late Color addToCartCardShadowColor = const Color(0x256F6F6F);
  late Color attributeCardShadowColor = const Color(0x1F6F6F6F);
  late Color minusBtnBgColor = const Color(0xFF636AE8);
  late Color minusBtnIconColor = const Color(0xFFFFFFFF);
  late Color cartDividerColor = const Color(0x16292626);
  late Color pickupLocationAndTimeTile = const Color(0xFFFEFEFE);
  late Color bottomsheatBackground = const Color(0xFFEFEFEF);
  late Color shadowLightTheme = const Color(0x1E6F6F6F);
  late Color coffeeAndDarkGrey = const Color(0xFF636AE8);
  late Color coffeeAndWhite = const Color(0xFF636AE8);
  late Color darkGrayAndWhite = const Color(0xFF303436);
  late Color whiteAndDarkGrey = const Color(0xFFFFFFFF);
  late Color goldTier = const Color(0xFFD4AF34);
  late Color silverTier = const Color(0xFFB0B0B0);
  late Color dialogBackground = const Color(0xFFFEFEFE);
  late Color shadow = const Color(0x276C6C6C);
  late Color deleteRed = const Color(0xFFE40000);
  late Color greyShades = const Color(0xFF6C6E73);
  late Color accentBlack = const Color(0xFF636AE8);
  late Color peachGrey = const Color(0xFF725333);
  late Color lightGreyDarkGrey = const Color(0xFFB3B3B8);
}

abstract class Typography {
  String get displayLargeFamily;
  bool get displayLargeIsCustom;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  bool get displayMediumIsCustom;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  bool get displaySmallIsCustom;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  bool get headlineLargeIsCustom;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  bool get headlineMediumIsCustom;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  bool get headlineSmallIsCustom;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  bool get titleLargeIsCustom;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  bool get titleMediumIsCustom;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  bool get titleSmallIsCustom;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  bool get labelLargeIsCustom;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  bool get labelMediumIsCustom;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  bool get labelSmallIsCustom;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  bool get bodyLargeIsCustom;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  bool get bodyMediumIsCustom;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  bool get bodySmallIsCustom;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final AppTheme theme;

  String get displayLargeFamily => 'Bebas Neue';
  bool get displayLargeIsCustom => false;
  TextStyle get displayLarge => GoogleFonts.bebasNeue(
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 30.0,
  );
  String get displayMediumFamily => 'Bebas Neue';
  bool get displayMediumIsCustom => false;
  TextStyle get displayMedium => GoogleFonts.bebasNeue(
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 26.0,
  );
  String get displaySmallFamily => 'Bebas Neue';
  bool get displaySmallIsCustom => false;
  TextStyle get displaySmall => GoogleFonts.bebasNeue(
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 24.0,
  );
  String get headlineLargeFamily => 'Bebas Neue';
  bool get headlineLargeIsCustom => false;
  TextStyle get headlineLarge => GoogleFonts.bebasNeue(
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 24.0,
  );
  String get headlineMediumFamily => 'Bebas Neue';
  bool get headlineMediumIsCustom => false;
  TextStyle get headlineMedium => GoogleFonts.bebasNeue(
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 22.0,
  );
  String get headlineSmallFamily => 'Bebas Neue';
  bool get headlineSmallIsCustom => false;
  TextStyle get headlineSmall => GoogleFonts.bebasNeue(
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 18.0,
  );
  String get titleLargeFamily => 'Bebas Neue';
  bool get titleLargeIsCustom => false;
  TextStyle get titleLarge => GoogleFonts.bebasNeue(
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 16.0,
  );
  String get titleMediumFamily => 'Bebas Neue';
  bool get titleMediumIsCustom => false;
  TextStyle get titleMedium => GoogleFonts.bebasNeue(
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 14.0,
  );
  String get titleSmallFamily => 'Bebas Neue';
  bool get titleSmallIsCustom => false;
  TextStyle get titleSmall => GoogleFonts.bebasNeue(
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 12.0,
  );
  String get labelLargeFamily => 'Poppins';
  bool get labelLargeIsCustom => false;
  TextStyle get labelLarge => GoogleFonts.poppins(
    color: theme.secondaryText,
    fontWeight: FontWeight.normal,
    fontSize: 16.0,
  );
  String get labelMediumFamily => 'Poppins';
  bool get labelMediumIsCustom => false;
  TextStyle get labelMedium => GoogleFonts.poppins(
    color: theme.secondaryText,
    fontWeight: FontWeight.normal,
    fontSize: 14.0,
  );
  String get labelSmallFamily => 'Poppins';
  bool get labelSmallIsCustom => false;
  TextStyle get labelSmall => GoogleFonts.poppins(
    color: theme.secondaryText,
    fontWeight: FontWeight.normal,
    fontSize: 12.0,
  );
  String get bodyLargeFamily => 'Poppins';
  bool get bodyLargeIsCustom => false;
  TextStyle get bodyLarge => GoogleFonts.poppins(
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 16.0,
  );
  String get bodyMediumFamily => 'Poppins';
  bool get bodyMediumIsCustom => false;
  TextStyle get bodyMedium => GoogleFonts.poppins(
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 15.0,
  );
  String get bodySmallFamily => 'Poppins';
  bool get bodySmallIsCustom => false;
  TextStyle get bodySmall => GoogleFonts.poppins(
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 14.0,
  );
}

class DarkModeTheme extends AppTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF636AE8);
  late Color secondary = const Color(0xFF222628);
  late Color tertiary = const Color(0xFF6C6E73);
  late Color alternate = const Color(0xFFFEFEFE);
  late Color primaryText = const Color(0xFFFFFFFF);
  late Color secondaryText = const Color(0xFF95A1AC);
  late Color primaryBackground = const Color(0xFF0F0F0F);
  late Color secondaryBackground = const Color(0xFF222628);
  late Color accent1 = const Color(0xFF636AE8);
  late Color accent2 = const Color(0xFFFFEEDF);
  late Color accent3 = const Color(0xFF42973E);
  late Color accent4 = const Color(0xFFD5D6D7);
  late Color success = const Color(0xFF249689);
  late Color warning = const Color(0xFFF9CF58);
  late Color error = const Color(0xFFFF5963);
  late Color info = const Color(0xFFFFFFFF);

  late Color darkGray = const Color(0xFF303436);
  late Color textGreyColor = const Color(0xFF6C6E73);
  late Color borderColor = const Color(0xFFEFEFEF);
  late Color textFieldColor = const Color(0xFF303436);
  late Color dividerColor = const Color(0x21FAF2F2);
  late Color whiteAndGray = const Color(0xFF6C6E73);
  late Color homeOrderPlacedBackground = const Color(0xFF303436);
  late Color homePointsBackground = const Color(0xFF222628);
  late Color darkAndLightGray = const Color(0xFF222628);
  late Color peach = const Color(0xFFFFEEDF);
  late Color attributeCardBg = const Color(0xFF222628);
  late Color pinCodeLightGreyAndGrey = const Color(0xFF6C6E73);
  late Color variantCardBg = const Color(0xFF303436);
  late Color secondaryForground = const Color(0xFFFEFEFE);
  late Color addToCartCardShadowColor = const Color(0x00000000);
  late Color attributeCardShadowColor = const Color(0x5A000000);
  late Color minusBtnBgColor = const Color(0xFF303436);
  late Color minusBtnIconColor = const Color(0xFF6C6E73);
  late Color cartDividerColor = const Color(0x15E8E8E8);
  late Color pickupLocationAndTimeTile = const Color(0x3F6C6E73);
  late Color bottomsheatBackground = const Color(0xFF222628);
  late Color shadowLightTheme = const Color(0x00000000);
  late Color coffeeAndDarkGrey = const Color(0xFF222628);
  late Color coffeeAndWhite = const Color(0xFFFEFEFE);
  late Color darkGrayAndWhite = const Color(0xFFFEFEFE);
  late Color whiteAndDarkGrey = const Color(0xFF222628);
  late Color goldTier = const Color(0xFFD4AF34);
  late Color silverTier = const Color(0xFFB0B0B0);
  late Color dialogBackground = const Color(0xFF303436);
  late Color shadow = const Color(0x006C6C6C);
  late Color deleteRed = const Color(0xFFE40000);
  late Color greyShades = const Color(0xFFB6B6B6);
  late Color accentBlack = const Color(0xFF000000);
  late Color peachGrey = const Color(0xFF444444);
  late Color lightGreyDarkGrey = const Color(0xFF4C4E4E);
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
    String? package,
  }) {
    if (useGoogleFonts && fontFamily != null) {
      font = GoogleFonts.getFont(
        fontFamily,
        fontWeight: fontWeight ?? this.fontWeight,
        fontStyle: fontStyle ?? this.fontStyle,
      );
    }

    return font != null
        ? font.copyWith(
            color: color ?? this.color,
            fontSize: fontSize ?? this.fontSize,
            letterSpacing: letterSpacing ?? this.letterSpacing,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          )
        : copyWith(
            fontFamily: fontFamily,
            package: package,
            color: color,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          );
  }
}
