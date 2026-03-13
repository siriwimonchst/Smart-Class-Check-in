// =============================================================================
// screens/home_screen.dart — หน้าจอหลักของแอป Smart Class Check-in
// แสดง 3 ปุ่มนำทาง (ลักษณะเหมือนรูปภาพอ้างอิง): Check-in/Finish/History
// มีปุ่มภาษา (globe) และปุ่ม Profile (person) ใน AppBar
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../i18n/app_strings.dart';
import '../widgets/shared_widgets.dart';
import 'checkin_screen.dart';
import 'finish_class_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppStrings strings;
  final String fullName;
  final String studentId;
  final VoidCallback onToggleLang;
  final Future<void> Function(String name, String id) onSaveProfile;

  const HomeScreen({
    super.key,
    required this.strings,
    required this.fullName,
    required this.studentId,
    required this.onToggleLang,
    required this.onSaveProfile,
  });

  // เปิด Dialog แก้ไข Profile (ชื่อ + รหัส)
  void _showProfileDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: fullName);
    final idCtrl = TextEditingController(text: studentId);
    final s = strings;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(s.profileTitle,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: s.fullName,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: idCtrl,
              decoration: InputDecoration(
                labelText: s.studentId,
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel, style: GoogleFonts.nunito(color: kPrimary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onSaveProfile(nameCtrl.text.trim(), idCtrl.text.trim());
            },
            child: Text(s.save,
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.appTitle),
        actions: [
          // ปุ่มสลับภาษา
          TextButton.icon(
            icon: const Icon(Icons.language_rounded,
                color: Colors.white, size: 18),
            label: Text(
              s.switchLang,
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
            ),
            onPressed: onToggleLang,
          ),
          // ปุ่ม Profile (มุมบนขวา)
          IconButton(
            icon: const Icon(Icons.account_circle_rounded, color: Colors.white),
            tooltip: s.editProfile,
            onPressed: () => _showProfileDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- ชื่อแอปยิ่งใหญ่ ----
              Text(
                s.appTitle,
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: kPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.bannerSub,
                style: GoogleFonts.nunito(
                    fontSize: 13, color: const Color(0xFF7A6EA0)),
              ),

              // ---- แสดงชื่อ+รหัสนักศึกษา (ถ้าตั้งค่าแล้ว) ----
              if (fullName.isNotEmpty || studentId.isNotEmpty) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _showProfileDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: kPurpleSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_circle_rounded,
                            color: kPrimary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fullName.isNotEmpty
                                ? '$fullName  |  $studentId'
                                : studentId,
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w700,
                                color: kPrimary,
                                fontSize: 13),
                          ),
                        ),
                        const Icon(Icons.edit_outlined,
                            color: kPrimary, size: 16),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ---- 3 ปุ่มนำทาง (สไตล์รูปภาพ) ----
              _NavCard(
                icon: Icons.login_rounded,
                title: s.checkIn,
                subtitle: s.checkInSub,
                colors: const [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckinScreen(
                          strings: s,
                          initialName: fullName,
                          initialStudentId: studentId),
                    )),
              ),
              const SizedBox(height: 14),
              _NavCard(
                icon: Icons.logout_rounded,
                title: s.finishClass,
                subtitle: s.finishSub,
                colors: const [Color(0xFF1D4ED8), Color(0xFF60A5FA)],
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FinishClassScreen(
                          strings: s,
                          initialName: fullName,
                          initialStudentId: studentId),
                    )),
              ),
              const SizedBox(height: 14),
              _NavCard(
                icon: Icons.history_rounded,
                title: s.history,
                subtitle: s.historySub,
                colors: const [Color(0xFF059669), Color(0xFF34D399)],
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryScreen(strings: s),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// _NavCard — ปุ่มนำทางแบบ Full-Width พร้อม Gradient
// ลักษณะ: [Icon in square | Title + Subtitle | Chevron >]
// =============================================================================
class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              // ---- ไอคอนในกล่องสี่เหลี่ยมกลม (lighter) ----
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              // ---- ชื่อ + คำบรรยาย ----
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // ---- ลูกศร > ----
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
