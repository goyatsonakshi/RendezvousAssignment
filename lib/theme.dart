import 'package:flutter/material.dart';

// Defines the application's theme based on branding guidelines.
class AppTheme {
  // Primary Colors
  static const Color tanMain = Color(0xFFD5C1A6);
  static const Color tanLight = Color(0xFFFFF3E7);
  static const Color tanGradientStart = Color(0xFFDECDBD);
  static const Color whiteGradientEnd = Color(0xFFFFFFFF);
  static const Color fontBlue = Color(0xFF0A1A4B);
  static const Color strokeBlue = Color(0xFF202939); // Used for borders/strokes

  // Text Styles
  static const TextStyle headlineStyle = TextStyle(
    fontFamily: 'Inter', // Ensure Inter font is included in pubspec.yaml
    color: fontBlue,
    fontWeight: FontWeight.bold,
    fontSize: 24,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'Inter',
    color: fontBlue,
    fontSize: 16,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: 'Inter',
    color: Colors.white, // White text on buttons
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static const TextStyle errorStyle = TextStyle(
    fontFamily: 'Inter',
    color: Colors.redAccent,
    fontSize: 14,
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: tanMain,
      scaffoldBackgroundColor: tanLight, // Light tan background
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: tanMain,
        elevation: 1,
        titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            color: fontBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: fontBlue),
      ),
      textTheme: const TextTheme(
        displayLarge: headlineStyle, // Example usage
        bodyLarge: bodyStyle,
        labelLarge: buttonTextStyle, // For ElevatedButton text
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: whiteGradientEnd, // White input fields
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: strokeBlue, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: strokeBlue, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: tanMain, width: 2.0),
        ),
        labelStyle: bodyStyle.copyWith(color: fontBlue.withOpacity(0.7)),
        hintStyle: bodyStyle.copyWith(color: fontBlue.withOpacity(0.5)),
        errorStyle: errorStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: fontBlue, // Blue buttons
          foregroundColor: Colors.white, // White text
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          textStyle: buttonTextStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: fontBlue, // Blue text for text buttons
          textStyle: bodyStyle.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme( // Apply similar styling
          filled: true,
          fillColor: whiteGradientEnd,
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: strokeBlue, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: strokeBlue, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: tanMain, width: 2.0),
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: tanLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        titleTextStyle: headlineStyle.copyWith(fontSize: 20),
        contentTextStyle: bodyStyle,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: fontBlue, // Blue progress indicators
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  // Define gradients if needed, e.g., for backgrounds
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [tanGradientStart, whiteGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradientAlt = LinearGradient(
    colors: [tanLight, tanGradientStart], // Lighter version
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
