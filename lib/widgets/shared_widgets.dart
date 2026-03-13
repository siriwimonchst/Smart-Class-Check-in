// =============================================================================
// widgets/shared_widgets.dart
// Widget ที่ใช้ร่วมกัน: StepCard, InfoTile, FormalButton, QrScannerScreen
// ไม่มี emoji — ใช้ Nunito font, formal palette
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../i18n/app_strings.dart';

// ---- สีที่ใช้ร่วมกัน ----
const Color kPrimary = Color(0xFF4A3880);
const Color kPurpleSoft = Color(0xFFF0EEFF);
const Color kBorder = Color(0xFFDDD5F0);

// =============================================================================
// QrScannerScreen — สแกน QR Code แบบเต็มหน้าจอ
// Returns: String (ค่า QR) หรือ null ถ้ายกเลิก
// =============================================================================
class QrScannerScreen extends StatefulWidget {
  final AppStrings strings;
  const QrScannerScreen({super.key, required this.strings});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false; // ป้องกัน callback ซ้ำ

  @override
  void dispose() {
    _controller.dispose(); // คืน resource กล้อง
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.scannerTitle),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            tooltip: s.toggleFlash,
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            tooltip: s.flipCamera,
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ---- ภาพจากกล้อง ----
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_scanned) return;
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? rawValue = barcodes.first.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  _scanned = true;
                  Navigator.pop(context, rawValue); // ส่งค่ากลับ
                }
              }
            },
          ),

          // ---- กรอบ Overlay ----
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: kPrimary, width: 2.5),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // ---- คำแนะนำด้านล่าง ----
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  s.scanFrame,
                  style: GoogleFonts.nunito(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// StepCard — Card มีป้ายหมายเลขขั้นตอน
// =============================================================================
class StepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final Widget child;
  final Color accentColor;

  const StepCard({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.child,
    this.accentColor = kPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // ป้ายหมายเลข
              Container(
                width: 32,
                height: 32,
                decoration:
                    BoxDecoration(color: accentColor, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  '$stepNumber',
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1240),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFEAE4F4)),
          child,
        ],
      ),
    );
  }
}

// =============================================================================
// InfoTile — แบนเนอร์แสดงข้อมูล พร้อมไอคอน
// =============================================================================
class InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const InfoTile(
      {super.key,
      required this.icon,
      required this.iconColor,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                  color: iconColor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FormalButton — ปุ่มทางการ รูปแบบ Pill Shape + Gradient ม่วง/น้ำเงิน
// =============================================================================
class FormalButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final List<Color> colors;
  final bool isLoading;

  const FormalButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.colors = const [Color(0xFF5E35B1), Color(0xFF7C4DFF)],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: enabled
            ? LinearGradient(
                colors: colors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight)
            : const LinearGradient(
                colors: [Color(0xFFBDBDBD), Color(0xFFE0E0E0)]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: enabled
            ? [
                BoxShadow(
                    color: colors.first.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: enabled ? onPressed : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
              else if (icon != null)
                Icon(icon, color: Colors.white, size: 18),
              if (!isLoading && icon != null) const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
