// =============================================================================
// i18n/app_strings.dart
// ระบบ Bilingual สนับสนุน English (UK) และ ภาษาไทย
// ใช้งาน: final s = AppStrings('en'); หรือ AppStrings('th');
// =============================================================================

class AppStrings {
  final String lang;
  const AppStrings(this.lang);

  bool get isThai => lang == 'th';

  // ---- ชื่อแอปและการนำทาง ----
  String get appTitle => 'Smart Class Check-in';
  String get checkIn => isThai ? 'เช็คชื่อก่อนเรียน' : 'Check-In to Class';
  String get checkInSub =>
      isThai ? 'เริ่มต้นคาบเรียน' : 'Start your class session';
  String get finishClass => isThai ? 'ออกจากชั้นเรียน' : 'Finish Class';
  String get finishSub => isThai ? 'สิ้นสุดคาบเรียน' : 'Complete your session';
  String get history => isThai ? 'ประวัติ' : 'History';
  String get historySub => isThai ? 'ดูประวัติที่ผ่านมา' : 'View past records';

  // ---- โปรไฟล์นักศึกษา ----
  String get profileTitle => isThai ? 'ข้อมูลนักศึกษา' : 'Student Profile';
  String get fullName => isThai ? 'ชื่อ-นามสกุล' : 'Full Name';
  String get studentId => isThai ? 'รหัสนักศึกษา' : 'Student ID';
  String get editProfile => isThai ? 'แก้ไขโปรไฟล์' : 'Edit Profile';
  String get save => isThai ? 'บันทึก' : 'Save';
  String get cancel => isThai ? 'ยกเลิก' : 'Cancel';

  // ---- ขั้นตอน ----
  String get locationStep => isThai ? 'รับพิกัดตำแหน่ง' : 'Get Location';
  String get qrPhotoStep => isThai ? 'สแกน QR และถ่ายรูป' : 'Scan QR & Photo';
  String get reflectionStep =>
      isThai ? 'สะท้อนการเรียนรู้' : 'Learning Reflection';
  String get postStep => isThai ? 'สะท้อนหลังเรียน' : 'Post-Class Reflection';

  // ---- ปุ่มและ Action ----
  String get getLocation =>
      isThai ? 'รับพิกัดปัจจุบัน' : 'Get Current Location';
  String get gettingLocation =>
      isThai ? 'กำลังดึงพิกัด...' : 'Getting Location...';
  String get scanQr => isThai ? 'สแกน QR Code' : 'Scan QR Code';
  String get qrScannedBtn =>
      isThai ? 'สแกนแล้ว (กดสแกนใหม่)' : 'Scanned (Tap to rescan)';
  String get takePhoto => isThai ? 'ถ่ายรูปแนบ' : 'Attach Photo';
  String get retakePhoto => isThai ? 'ถ่ายรูปใหม่' : 'Retake Photo';
  String get submitCheckin => isThai ? 'ยืนยันเช็คชื่อ' : 'Submit Check-in';
  String get submitFinish =>
      isThai ? 'ยืนยันบันทึกหลังเรียน' : 'Submit Finish Class';
  String get submitting => isThai ? 'กำลังบันทึก...' : 'Submitting...';

  // ---- ฟิลด์ฟอร์ม ----
  String get previousTopic =>
      isThai ? 'หัวข้อที่เรียนคาบที่แล้ว' : 'Previous Class Topic';
  String get expectedTopic =>
      isThai ? 'หัวข้อที่คาดหวังวันนี้' : 'Expected Topic Today';
  String get moodQuestion =>
      isThai ? 'อารมณ์ก่อนเรียนวันนี้' : 'Mood Before Class';
  String get whatLearned =>
      isThai ? 'สิ่งที่เรียนรู้วันนี้' : 'What Did You Learn Today';
  String get feedback => isThai ? 'ความคิดเห็นเกี่ยวกับคาบ' : 'Class Feedback';

  // ---- Mood Labels (1-5 ไม่มี emoji) ----
  String get moodVeryNeg => isThai ? 'แย่มาก' : 'Very Bad';
  String get moodNeg => isThai ? 'แย่' : 'Bad';
  String get moodNeutral => isThai ? 'กลาง' : 'Neutral';
  String get moodPos => isThai ? 'ดี' : 'Good';
  String get moodVeryPos => isThai ? 'ดีมาก' : 'Very Good';
  String get selectedMood => isThai ? 'อารมณ์ที่เลือก' : 'Selected Mood';

  List<String> get moodLabels =>
      [moodVeryNeg, moodNeg, moodNeutral, moodPos, moodVeryPos];

  // ---- Validation Messages ----
  String get nameRequired =>
      isThai ? 'กรุณาระบุชื่อ-นามสกุล' : 'Please enter your full name';
  String get idRequired =>
      isThai ? 'กรุณาระบุรหัสนักศึกษา' : 'Please enter student ID';
  String get topicRequired =>
      isThai ? 'กรุณาระบุหัวข้อ' : 'Please enter the topic';
  String get learnedRequired =>
      isThai ? 'กรุณาระบุสิ่งที่เรียนรู้' : 'Please describe what you learned';
  String get feedbackRequired =>
      isThai ? 'กรุณาให้ความคิดเห็น' : 'Please provide feedback';
  String get locationRequired => isThai
      ? 'กรุณาดึงพิกัดก่อน (ขั้นตอนที่ 1)'
      : 'Please get your location first (Step 1)';
  String get qrRequired => isThai
      ? 'กรุณาสแกน QR Code ก่อน (ขั้นตอนที่ 2)'
      : 'Please scan QR code first (Step 2)';

  // ---- GPS Error Messages ----
  String get gpsDisabled => isThai
      ? 'GPS ปิดอยู่ กรุณาเปิดในการตั้งค่า'
      : 'GPS disabled. Enable in settings.';
  String get locDenied =>
      isThai ? 'ไม่ได้รับอนุญาตเข้าถึงตำแหน่ง' : 'Location permission denied.';
  String get locDeniedForever => isThai
      ? 'สิทธิ์ถูกปฏิเสธถาวร ไปเปิดใน Settings'
      : 'Permission permanently denied. Change in Settings.';
  String get locError => isThai ? 'เกิดข้อผิดพลาด: ' : 'Error: ';

  // ---- SnackBar / Success ----
  String get checkinSuccess =>
      isThai ? 'เช็คชื่อสำเร็จแล้ว' : 'Check-in submitted successfully';
  String get finishSuccess =>
      isThai ? 'บันทึกหลังเรียนสำเร็จ' : 'Finish class submitted successfully';

  // ---- QR Scanner Screen ----
  String get scannerTitle => isThai ? 'สแกน QR Code' : 'Scan QR Code';
  String get scanFrame =>
      isThai ? 'นำ QR Code เข้ามาในกรอบ' : 'Align QR code within the frame';
  String get toggleFlash => isThai ? 'เปิด/ปิดไฟฉาย' : 'Toggle Flash';
  String get flipCamera => isThai ? 'สลับกล้อง' : 'Flip Camera';

  // ---- Info / Display ----
  String get photoAttached => isThai ? 'แนบรูปแล้ว' : 'Photo attached';
  String get noPhoto => isThai ? 'ยังไม่ได้แนบรูป' : 'No photo attached';
  String get switchLang => isThai ? 'English' : 'ภาษาไทย';
  String get historyEmpty => isThai ? 'ยังไม่มีประวัติ' : 'No records yet';
  String get historyCheckin => isThai ? 'เช็คชื่อเข้าเรียน' : 'Check-in';
  String get historyFinish => isThai ? 'บันทึกหลังเรียน' : 'Finish Class';
  String get mood => isThai ? 'อารมณ์' : 'Mood';
  String get date => isThai ? 'วันที่' : 'Date';
  String get welcomeBanner =>
      isThai ? 'ยินดีต้อนรับ นักศึกษา' : 'Welcome, Student';
  String get bannerSub => isThai
      ? 'บันทึกการเข้าเรียนและสะท้อนการเรียนรู้'
      : 'Track your class attendance and learning';
  String get about => isThai ? 'เกี่ยวกับ' : 'About';
}
