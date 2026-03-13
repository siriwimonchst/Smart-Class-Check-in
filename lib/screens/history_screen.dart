import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../i18n/app_strings.dart';
import '../models/checkin_model.dart';
import '../services/storage_service.dart';

// ---- ไม่ใช้ package intl — format date เองแทน ----

class HistoryScreen extends StatefulWidget {
  final AppStrings strings;
  const HistoryScreen({super.key, required this.strings});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // รายการบันทึกทั้งหมด (รวม CheckinRecord และ FinishClassRecord)
  List<_HistoryEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // โหลดข้อมูลจาก SharedPreferences
  Future<void> _loadHistory() async {
    final checkins = await StorageService.loadCheckinRecords();
    final finishes = await StorageService.loadFinishClassRecords();

    final entries = <_HistoryEntry>[
      ...checkins.map((r) =>
          _HistoryEntry(type: 'checkin', checkin: r, timestamp: r.timestamp)),
      ...finishes.map((r) =>
          _HistoryEntry(type: 'finish', finish: r, timestamp: r.timestamp)),
    ];

    // เรียงจากล่าสุดไปเก่าสุด
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  // format DateTime เป็น string
  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.history),
        leading: const BackButton(color: Colors.white),
        backgroundColor: const Color(0xFF059669),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history_rounded,
                          size: 64, color: Color(0xFFCCC5E0)),
                      const SizedBox(height: 16),
                      Text(
                        s.historyEmpty,
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: const Color(0xFF9E97B8),
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _buildCard(_entries[i], s),
                ),
    );
  }

  Widget _buildCard(_HistoryEntry entry, AppStrings s) {
    final isCheckin = entry.type == 'checkin';
    final color = isCheckin ? const Color(0xFF6D28D9) : const Color(0xFF1D4ED8);
    final bgColor =
        isCheckin ? const Color(0xFFF3EEFF) : const Color(0xFFEEF4FF);

    // ดึงข้อมูลจาก record
    final name = isCheckin ? entry.checkin!.fullName : entry.finish!.fullName;
    final sid = isCheckin ? entry.checkin!.studentId : entry.finish!.studentId;
    final photoPath =
        isCheckin ? entry.checkin!.photoPath : entry.finish!.photoPath;
    final mood = isCheckin ? entry.checkin!.mood : null;
    final mainText =
        isCheckin ? entry.checkin!.expectedTopic : entry.finish!.learnedToday;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Header (type badge + timestamp) ----
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    isCheckin ? s.historyCheckin : s.historyFinish,
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(entry.timestamp),
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: const Color(0xFF9E97B8),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // ---- Body (student info + content) ----
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ชื่อ + รหัส
                Row(
                  children: [
                    Icon(Icons.account_circle_rounded, color: color, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      name.isNotEmpty
                          ? '$name  |  $sid'
                          : (sid.isNotEmpty ? sid : '-'),
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: const Color(0xFF1A1240)),
                    ),
                  ],
                ),

                if (mainText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    mainText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                        fontSize: 12, color: const Color(0xFF6B6B8D)),
                  ),
                ],

                if (mood != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.sentiment_satisfied_rounded,
                          color: color, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${s.mood}: $mood/5',
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],

                // รูปถ่าย thumbnail (ถ้ามี)
                if (photoPath.isNotEmpty && File(photoPath).existsSync()) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(photoPath),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class รวม CheckinRecord และ FinishClassRecord ไว้ด้วยกัน
class _HistoryEntry {
  final String type; // 'checkin' หรือ 'finish'
  final CheckinRecord? checkin;
  final FinishClassRecord? finish;
  final DateTime timestamp;

  _HistoryEntry(
      {required this.type, this.checkin, this.finish, required this.timestamp});
}
