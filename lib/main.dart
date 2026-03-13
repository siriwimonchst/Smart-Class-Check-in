// =============================================================================
// main.dart — จุดเริ่มต้นของแอป Smart Class Check-in
// StatefulWidget จัดการ: ภาษา (EN/TH), ชื่อ+รหัสนักศึกษา (profile)
// ธีม: Nunito font, pearl-white background, formal deep-purple AppBar
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'i18n/app_strings.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SmartCheckinApp());
}

class SmartCheckinApp extends StatefulWidget {
  const SmartCheckinApp({super.key});

  @override
  State<SmartCheckinApp> createState() => _SmartCheckinAppState();
}

class _SmartCheckinAppState extends State<SmartCheckinApp> {
  // ---- สถานะระดับแอป ----
  String _lang = 'en'; // ภาษาปัจจุบัน
  String _fullName = ''; // ชื่อ-นามสกุล นักศึกษา
  String _studentId = ''; // รหัสนักศึกษา

  @override
  void initState() {
    super.initState();
    _loadProfile(); // โหลดข้อมูลจาก SharedPreferences เมื่อเปิดแอป
  }

  // โหลด language + profile จาก SharedPreferences
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lang = prefs.getString('lang') ?? 'en';
      _fullName = prefs.getString('fullName') ?? '';
      _studentId = prefs.getString('studentId') ?? '';
    });
  }

  // สลับภาษา EN ↔ TH และบันทึกการตั้งค่า
  Future<void> _toggleLang() async {
    final newLang = _lang == 'en' ? 'th' : 'en';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', newLang);
    setState(() => _lang = newLang);
  }

  // บันทึกข้อมูล Profile หลังจาก dialog แก้ไข
  Future<void> _saveProfile(String name, String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', name);
    await prefs.setString('studentId', id);
    setState(() {
      _fullName = name;
      _studentId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(_lang); // AppStrings ตามภาษาปัจจุบัน

    // ---- พาเลทสีหลัก ----
    const Color primary = Color(0xFF4A3880); // ม่วงเข้ม (formal)
    const Color bgColor = Color(0xFFF8F8FC); // pearl white
    const Color textDark = Color(0xFF1A1240); // navy-purple สำหรับตัวอักษร

    return MaterialApp(
      title: s.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          surface: bgColor,
          onSurface: textDark,
        ),
        scaffoldBackgroundColor: bgColor,

        // Nunito — ฟอนต์ทางการแต่อ่านง่าย
        textTheme: GoogleFonts.nunitoTextTheme().apply(
          bodyColor: textDark,
          displayColor: textDark,
        ),

        // AppBar — สีเข้มทางการ ไม่มี gradient
        appBarTheme: AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 1,
          titleTextStyle: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        // Input fields — ขอบเบลอ, fill สีม่วงอ่อน
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF0EEFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDDD5F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          labelStyle:
              GoogleFonts.nunito(color: const Color(0xFF7A6EA0), fontSize: 13),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),

        // Card — white, มุมโค้ง 16
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFEAE4F4), width: 1),
          ),
        ),

        // ElevatedButton — pill shape
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: const StadiumBorder(),
            textStyle:
                GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
            elevation: 0,
          ),
        ),
      ),
      home: HomeScreen(
        strings: s,
        fullName: _fullName,
        studentId: _studentId,
        onToggleLang: _toggleLang,
        onSaveProfile: _saveProfile,
      ),
    );
  }
}
