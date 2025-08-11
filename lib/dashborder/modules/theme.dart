import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ثيم فاتح متقدم
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.indigo,
  colorScheme: ColorScheme.light(
    primary: Colors.indigo,
    secondary: Colors.tealAccent[400]!,
    surface: Colors.white,
    background: Colors.grey[50]!,
    error: Colors.red[700]!,
  ),
  scaffoldBackgroundColor: Colors.grey[50],
  cardColor: Colors.white,
  appBarTheme: AppBarTheme(
    elevation: 1,
    centerTitle: true,
    backgroundColor: Colors.white,
    foregroundColor: Colors.indigo,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.indigo[800],
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.indigo,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  textTheme: TextTheme(

    headline4: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
    headline5: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.indigo[800]),
    headline6: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.indigo[800]),
    subtitle1: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
    bodyText1: TextStyle(fontSize: 16, color: Colors.grey[800]),
    bodyText2: TextStyle(fontSize: 14, color: Colors.grey[700]),
    caption: TextStyle(fontSize: 12, color: Colors.grey[600]),
    button: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey[400]!),
    ),
    filled: true,
    fillColor: Colors.grey[100],
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.all(8),
  ),
);

// ثيم غامق متقدم
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.teal,
  colorScheme: ColorScheme.dark(
    primary: Colors.teal[300]!,
    secondary: Colors.tealAccent[200]!,
    surface: Colors.grey[850]!,
    background: Colors.grey[900]!,
    error: Colors.red[400]!,
  ),
  scaffoldBackgroundColor: Colors.grey[900],
  cardColor: Colors.grey[800],
  appBarTheme: AppBarTheme(
    elevation: 1,
    centerTitle: true,
    backgroundColor: Colors.grey[900],
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.teal[400],
    elevation: 4,
  ),
  textTheme: TextTheme(
    headline4: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
    headline5: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
    headline6: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
    subtitle1: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[300]),
    bodyText1: TextStyle(fontSize: 16, color: Colors.grey[300]),
    bodyText2: TextStyle(fontSize: 14, color: Colors.grey[400]),
    caption: TextStyle(fontSize: 12, color: Colors.grey[500]),
    button: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey[600]!),
    ),
    filled: true,
    fillColor: Colors.grey[800],
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.all(8),
  ),
);

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isSystemTheme = false;
  bool _isHighContrast = false;
  Color _primaryColor = Colors.indigo;
  String _selectedFont = 'Roboto';

  // قائمة الألوان المتاحة
  final List<Color> availableColors = [
    Colors.indigo,
    Colors.white,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.pink,
  ];

  // قائمة الخطوط المتاحة
  final List<String> availableFonts = ['Roboto', 'Cairo', 'Tajawal', 'Arial'];

  bool get isDarkMode => _isDarkMode;
  bool get isSystemTheme => _isSystemTheme;
  bool get isHighContrast => _isHighContrast;
  Color get primaryColor => _primaryColor;
  String get selectedFont => _selectedFont;
  List<Color> get colorOptions => availableColors;
  List<String> get fontOptions => availableFonts;

  ThemeData get currentTheme {
    var baseTheme = _isDarkMode ? darkTheme : lightTheme;

    return baseTheme.copyWith(
      primaryColor: _primaryColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: _primaryColor,
      ),
      textTheme: baseTheme.textTheme.apply(
        fontFamily: _selectedFont,
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: _isDarkMode ? Colors.white : _primaryColor,
      ),
    );
  }

  ThemeProvider() {
    _loadThemePreferences();
  }

  Future<void> _loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isSystemTheme = prefs.getBool('isSystemTheme') ?? false;
    _isHighContrast = prefs.getBool('isHighContrast') ?? false;

    final colorValue = prefs.getInt('primaryColor');
    _primaryColor = colorValue != null ? Color(colorValue) : Colors.indigo;

    _selectedFont = prefs.getString('selectedFont') ?? 'Roboto';

    if (_isSystemTheme) {
      _isDarkMode = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    }

    notifyListeners();
  }

  Future<void> _saveThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('isSystemTheme', _isSystemTheme);
    await prefs.setBool('isHighContrast', _isHighContrast);
    await prefs.setInt('primaryColor', _primaryColor.value);
    await prefs.setString('selectedFont', _selectedFont);
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveThemePreferences();
    notifyListeners();
  }

  Future<void> setSystemTheme(bool useSystemTheme) async {
    _isSystemTheme = useSystemTheme;
    if (useSystemTheme) {
      _isDarkMode = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    }
    await _saveThemePreferences();
    notifyListeners();
  }

  Future<void> toggleHighContrast() async {
    _isHighContrast = !_isHighContrast;
    await _saveThemePreferences();
    notifyListeners();
  }

  Future<void> changePrimaryColor(Color newColor) async {
    _primaryColor = newColor;
    await _saveThemePreferences();
    notifyListeners();
  }

  Future<void> changeFont(String newFont) async {
    _selectedFont = newFont;
    await _saveThemePreferences();
    notifyListeners();
  }

  void updateThemeBasedOnSystem() {
    if (_isSystemTheme) {
      _isDarkMode = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
      notifyListeners();
    }
  }
  void setInitialTheme(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    notifyListeners();
  }
}