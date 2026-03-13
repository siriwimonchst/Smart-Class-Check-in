// =============================================================================
// screens/finish_class_screen.dart — บันทึกหลังเรียน
// - แสดงข้อมูลนักศึกษา (ชื่อ+รหัส) มุมบนขวา (editable)
// - ขั้นตอน 1: GPS | ขั้นตอน 2: QR + ถ่ายรูป | ขั้นตอน 3: สะท้อนหลังเรียน
// - Bilingual (AppStrings) | ไม่มี emoji | ธีมน้ำเงิน
// =============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../i18n/app_strings.dart';
import '../models/checkin_model.dart';
import '../services/storage_service.dart';
import '../widgets/shared_widgets.dart';

class FinishClassScreen extends StatefulWidget {
  final AppStrings strings;
  final String initialName;
  final String initialStudentId;

  const FinishClassScreen({
    super.key,
    required this.strings,
    required this.initialName,
    required this.initialStudentId,
  });

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  // ---- ข้อมูลนักศึกษา ----
  late final TextEditingController _nameCtrl;
  late final TextEditingController _studentIdCtrl;

  // ---- ขั้นตอน 1: GPS ----
  bool _isLoadingLoc = false;
  double? _lat;
  double? _lng;
  String? _locError;

  // ---- ขั้นตอน 2: QR + รูปถ่าย ----
  bool _qrScanned = false;
  String _qrResult = '';
  String? _photoPath;

  // ---- ขั้นตอน 3: ฟอร์ม ----
  final _formKey = GlobalKey<FormState>();
  final _learnedCtrl = TextEditingController();
  final _feedbackCtrl = TextEditingController();

  bool _isSubmitting = false;
  final _picker = ImagePicker();

  static const Color _blue = Color(0xFF1D4ED8);
  static const Color _blueLight = Color(0xFF60A5FA);

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _studentIdCtrl = TextEditingController(text: widget.initialStudentId);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _studentIdCtrl.dispose();
    _learnedCtrl.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  // ---- ดึงพิกัด GPS ----
  Future<void> _getLocation() async {
    setState(() {
      _isLoadingLoc = true;
      _locError = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() {
          _locError = widget.strings.gpsDisabled;
          _isLoadingLoc = false;
        });
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          setState(() {
            _locError = widget.strings.locDenied;
            _isLoadingLoc = false;
          });
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() {
          _locError = widget.strings.locDeniedForever;
          _isLoadingLoc = false;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _isLoadingLoc = false;
      });
    } catch (e) {
      setState(() {
        _locError = '${widget.strings.locError}$e';
        _isLoadingLoc = false;
      });
    }
  }

  // ---- สแกน QR Code ----
  Future<void> _openQr() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
          builder: (_) => QrScannerScreen(strings: widget.strings)),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _qrScanned = true;
        _qrResult = result;
      });
    }
  }

  // ---- ถ่ายรูปด้วยกล้อง ----
  Future<void> _takePhoto() async {
    final XFile? img =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (img != null) setState(() => _photoPath = img.path);
  }

  // ---- Submit ----
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final s = widget.strings;
    if (_lat == null) {
      _showSnack(s.locationRequired, Colors.orange);
      return;
    }
    if (!_qrScanned) {
      _showSnack(s.qrRequired, Colors.orange);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final record = FinishClassRecord(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        latitude: _lat!,
        longitude: _lng!,
        qrScanned: _qrScanned,
        learnedToday: _learnedCtrl.text.trim(),
        feedback: _feedbackCtrl.text.trim(),
        fullName: _nameCtrl.text.trim(),
        studentId: _studentIdCtrl.text.trim(),
        photoPath: _photoPath ?? '',
      );
      await StorageService.saveFinishClassRecord(record);
      if (!mounted) return;
      _showSnack(s.finishSuccess, const Color(0xFF059669));
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnack('Error: $e', Colors.red);
    }
  }

  void _showSnack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.nunito()),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.finishClass),
        backgroundColor: _blue,
        leading: const BackButton(color: Colors.white),
        // ---- ชื่อ + รหัสนักศึกษา มุมบนขวา ----
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _showProfileDialog,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _nameCtrl.text.isNotEmpty ? _nameCtrl.text : s.fullName,
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800),
                  ),
                  Text(
                    _studentIdCtrl.text.isNotEmpty
                        ? _studentIdCtrl.text
                        : s.studentId,
                    style:
                        GoogleFonts.nunito(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ================================ ขั้นตอน 1: GPS ================================
                StepCard(
                  stepNumber: 1,
                  title: s.locationStep,
                  accentColor: _blue,
                  child: Column(
                    children: [
                      FormalButton(
                        label:
                            _isLoadingLoc ? s.gettingLocation : s.getLocation,
                        icon: Icons.my_location_rounded,
                        colors: const [_blue, _blueLight],
                        isLoading: _isLoadingLoc,
                        onPressed: _isLoadingLoc ? null : _getLocation,
                      ),
                      if (_lat != null) ...[
                        const SizedBox(height: 10),
                        InfoTile(
                            icon: Icons.location_on_rounded,
                            iconColor: _blue,
                            text:
                                'Lat: ${_lat!.toStringAsFixed(6)}\nLng: ${_lng!.toStringAsFixed(6)}'),
                      ],
                      if (_locError != null) ...[
                        const SizedBox(height: 8),
                        InfoTile(
                            icon: Icons.error_outline_rounded,
                            iconColor: Colors.red,
                            text: _locError!),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ================================ ขั้นตอน 2: QR + รูปถ่าย ================================
                StepCard(
                  stepNumber: 2,
                  title: s.qrPhotoStep,
                  accentColor: _blue,
                  child: Column(
                    children: [
                      FormalButton(
                        label: _qrScanned ? s.qrScannedBtn : s.scanQr,
                        icon: Icons.qr_code_scanner_rounded,
                        colors: _qrScanned
                            ? const [Color(0xFF059669), Color(0xFF34D399)]
                            : const [_blue, _blueLight],
                        onPressed: _openQr,
                      ),
                      if (_qrScanned) ...[
                        const SizedBox(height: 8),
                        InfoTile(
                            icon: Icons.check_circle_rounded,
                            iconColor: const Color(0xFF059669),
                            text: _qrResult),
                      ],
                      const SizedBox(height: 12),
                      FormalButton(
                        label: _photoPath != null ? s.retakePhoto : s.takePhoto,
                        icon: Icons.camera_alt_rounded,
                        colors: _photoPath != null
                            ? const [Color(0xFFF59E0B), Color(0xFFFBBF24)]
                            : const [Color(0xFF374151), Color(0xFF6B7280)],
                        onPressed: _takePhoto,
                      ),
                      if (_photoPath != null &&
                          File(_photoPath!).existsSync()) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_photoPath!),
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InfoTile(
                            icon: Icons.photo_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            text: s.photoAttached),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ================================ ขั้นตอน 3: Post-Class Reflection ================================
                StepCard(
                  stepNumber: 3,
                  title: s.postStep,
                  accentColor: _blue,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _learnedCtrl,
                        maxLines: 3,
                        style: GoogleFonts.nunito(fontSize: 14),
                        decoration: InputDecoration(labelText: s.whatLearned),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? s.learnedRequired
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _feedbackCtrl,
                        maxLines: 3,
                        style: GoogleFonts.nunito(fontSize: 14),
                        decoration: InputDecoration(labelText: s.feedback),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? s.feedbackRequired
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ================================ ปุ่ม Submit ================================
                FormalButton(
                  label: _isSubmitting ? s.submitting : s.submitFinish,
                  icon: Icons.send_rounded,
                  isLoading: _isSubmitting,
                  colors: const [_blue, _blueLight],
                  onPressed: _isSubmitting ? null : _submit,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dialog แก้ไขชื่อ + รหัส
  void _showProfileDialog() {
    final s = widget.strings;
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
              controller: _nameCtrl,
              decoration: InputDecoration(
                  labelText: s.fullName,
                  prefixIcon: const Icon(Icons.person_outline_rounded)),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _studentIdCtrl,
              decoration: InputDecoration(
                  labelText: s.studentId,
                  prefixIcon: const Icon(Icons.badge_outlined)),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel, style: GoogleFonts.nunito(color: _blue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _blue),
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: Text(s.save,
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
