// =============================================================================
// screens/checkin_screen.dart — เช็คชื่อก่อนเรียน
// - แสดงข้อมูลนักศึกษา (ชื่อ+รหัส) มุมบนขวา (editable)
// - ขั้นตอน 1: GPS | ขั้นตอน 2: QR + ถ่ายรูป | ขั้นตอน 3: Reflection
// - Bilingual (AppStrings) | ไม่มี emoji
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

class CheckinScreen extends StatefulWidget {
  final AppStrings strings;
  final String initialName;
  final String initialStudentId;

  const CheckinScreen({
    super.key,
    required this.strings,
    required this.initialName,
    required this.initialStudentId,
  });

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
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
  final _prevTopicCtrl = TextEditingController();
  final _expectedTopicCtrl = TextEditingController();
  int _mood = 3; // 1–5

  bool _isSubmitting = false;
  final _picker = ImagePicker();

  static const Color _purple = Color(0xFF6D28D9);
  static const Color _light = Color(0xFF8B5CF6);

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
    _prevTopicCtrl.dispose();
    _expectedTopicCtrl.dispose();
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
      final record = CheckinRecord(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        latitude: _lat!,
        longitude: _lng!,
        qrScanned: _qrScanned,
        previousTopic: _prevTopicCtrl.text.trim(),
        expectedTopic: _expectedTopicCtrl.text.trim(),
        mood: _mood,
        fullName: _nameCtrl.text.trim(),
        studentId: _studentIdCtrl.text.trim(),
        photoPath: _photoPath ?? '',
      );
      await StorageService.saveCheckinRecord(record);
      if (!mounted) return;
      _showSnack(s.checkinSuccess, const Color(0xFF059669));
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
        title: Text(s.checkIn),
        backgroundColor: _purple,
        leading: const BackButton(color: Colors.white),
        // ---- ชื่อ + รหัสนักศึกษา แสดงมุมบนขวา ----
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
                  accentColor: _purple,
                  child: Column(
                    children: [
                      FormalButton(
                        label:
                            _isLoadingLoc ? s.gettingLocation : s.getLocation,
                        icon: Icons.my_location_rounded,
                        colors: const [_purple, _light],
                        isLoading: _isLoadingLoc,
                        onPressed: _isLoadingLoc ? null : _getLocation,
                      ),
                      if (_lat != null) ...[
                        const SizedBox(height: 10),
                        InfoTile(
                            icon: Icons.location_on_rounded,
                            iconColor: const Color(0xFF059669),
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
                  accentColor: _purple,
                  child: Column(
                    children: [
                      // ปุ่มสแกน QR
                      FormalButton(
                        label: _qrScanned ? s.qrScannedBtn : s.scanQr,
                        icon: Icons.qr_code_scanner_rounded,
                        colors: _qrScanned
                            ? const [Color(0xFF059669), Color(0xFF34D399)]
                            : const [_purple, _light],
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

                      // ปุ่มถ่ายรูป
                      FormalButton(
                        label: _photoPath != null ? s.retakePhoto : s.takePhoto,
                        icon: Icons.camera_alt_rounded,
                        colors: _photoPath != null
                            ? const [Color(0xFFF59E0B), Color(0xFFFBBF24)]
                            : const [Color(0xFF374151), Color(0xFF6B7280)],
                        onPressed: _takePhoto,
                      ),

                      // แสดง thumbnail รูปถ่าย
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

                // ================================ ขั้นตอน 3: Reflection ================================
                StepCard(
                  stepNumber: 3,
                  title: s.reflectionStep,
                  accentColor: _purple,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _prevTopicCtrl,
                        maxLines: 2,
                        style: GoogleFonts.nunito(fontSize: 14),
                        decoration: InputDecoration(labelText: s.previousTopic),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? s.topicRequired
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _expectedTopicCtrl,
                        maxLines: 2,
                        style: GoogleFonts.nunito(fontSize: 14),
                        decoration: InputDecoration(labelText: s.expectedTopic),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? s.topicRequired
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // ---- Mood Selector (ตัวเลข 1-5 ไม่มี emoji) ----
                      Text(s.moodQuestion,
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: const Color(0xFF1A1240))),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (i) {
                          final val = i + 1;
                          final isSelected = _mood == val;
                          return GestureDetector(
                            onTap: () => setState(() => _mood = val),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 56,
                              height: 64,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _purple
                                    : const Color(0xFFF0EEFF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: isSelected
                                        ? _purple
                                        : const Color(0xFFDDD5F0)),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                            color:
                                                _purple.withValues(alpha: 0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3))
                                      ]
                                    : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('$val',
                                      style: GoogleFonts.nunito(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: isSelected
                                              ? Colors.white
                                              : _purple)),
                                  Text(s.moodLabels[i],
                                      style: GoogleFonts.nunito(
                                          fontSize: 9,
                                          color: isSelected
                                              ? Colors.white70
                                              : const Color(0xFF9E97B8)),
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '${s.selectedMood}: ${s.moodLabels[_mood - 1]} ($_mood/5)',
                          style: GoogleFonts.nunito(
                              color: _purple,
                              fontWeight: FontWeight.w700,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ================================ ปุ่ม Submit ================================
                FormalButton(
                  label: _isSubmitting ? s.submitting : s.submitCheckin,
                  icon: Icons.send_rounded,
                  isLoading: _isSubmitting,
                  colors: const [_purple, _light],
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

  // Dialog แก้ไขชื่อ + รหัส (rebuild ใน screen นี้เท่านั้น)
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
            child: Text(s.cancel,
                style: GoogleFonts.nunito(color: const Color(0xFF6D28D9))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D28D9)),
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
