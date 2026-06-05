import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:frontend/features/event_shared/models/event_registration_model.dart';

class AttendeeExportService {
  static const String xlsxMimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  static const MethodChannel _downloadsChannel = MethodChannel(
    'app.uevent/downloads',
  );

  const AttendeeExportService();

  Future<AttendeeExportResult> exportRegistrationsToXlsx({
    required String eventId,
    required List<EventRegistrationModel> registrations,
  }) async {
    final excel = Excel.createExcel();
    const sheetName = 'Nguoi dang ky';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];
    final answerFieldIds = _answerFieldIds(registrations);

    final headers = [
      'STT',
      'Họ tên',
      'Email',
      'Tên đăng nhập',
      'Mã vé',
      'Trạng thái đăng ký',
      'Trạng thái check-in',
      'Thời gian đăng ký',
      'Mã đăng ký',
      ...answerFieldIds.map((fieldId) => 'Câu trả lời: $fieldId'),
    ];

    sheet.appendRow(headers.map(TextCellValue.new).toList());

    for (var index = 0; index < registrations.length; index += 1) {
      final registration = registrations[index];
      final user = registration.user;
      final answersByFieldId = {
        for (final answer in registration.answers) answer.fieldId: answer.value,
      };

      sheet.appendRow([
        IntCellValue(index + 1),
        TextCellValue(user?.displayName ?? 'Người tham gia'),
        TextCellValue(user?.email ?? ''),
        TextCellValue(user?.username ?? ''),
        TextCellValue(registration.ticket?.ticketCode ?? ''),
        TextCellValue(_registrationStatusLabel(registration.status)),
        TextCellValue(_checkInStatusLabel(registration.status)),
        TextCellValue(_formatDateTime(registration.registeredAt)),
        TextCellValue(registration.id),
        ...answerFieldIds.map(
          (fieldId) => TextCellValue(answersByFieldId[fieldId] ?? ''),
        ),
      ]);
    }

    _setColumnWidths(sheet, headers.length);

    final bytes = excel.save();
    if (bytes == null) {
      throw StateError('Không thể tạo file Excel.');
    }

    final fileName =
        'uevent_attendees_${_safeFilePart(eventId)}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final typedBytes = Uint8List.fromList(bytes);
    final savedPath = Platform.isAndroid
        ? await _saveToAndroidDownloads(fileName: fileName, bytes: typedBytes)
        : await _saveWithFileSaver(fileName: fileName, bytes: typedBytes);

    return AttendeeExportResult(fileName: fileName, path: savedPath);
  }

  Future<String> _saveToAndroidDownloads({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final savedPath = await _downloadsChannel.invokeMethod<String>('saveFile', {
      'fileName': fileName,
      'mimeType': xlsxMimeType,
      'bytes': bytes,
    });

    if (savedPath == null || savedPath.isEmpty) {
      throw StateError('Không thể lưu file vào Downloads.');
    }

    return savedPath;
  }

  Future<String> _saveWithFileSaver({
    required String fileName,
    required Uint8List bytes,
  }) {
    final baseName = fileName.replaceFirst(RegExp(r'\.xlsx$'), '');
    return FileSaver.instance.saveFile(
      name: baseName,
      bytes: bytes,
      fileExtension: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );
  }

  List<String> _answerFieldIds(List<EventRegistrationModel> registrations) {
    final seen = <String>{};
    final fieldIds = <String>[];

    for (final registration in registrations) {
      for (final answer in registration.answers) {
        final fieldId = answer.fieldId.trim();
        if (fieldId.isEmpty || seen.contains(fieldId)) continue;
        seen.add(fieldId);
        fieldIds.add(fieldId);
      }
    }

    return fieldIds;
  }

  void _setColumnWidths(Sheet sheet, int columnCount) {
    const widths = <int, double>{
      0: 8,
      1: 28,
      2: 30,
      3: 22,
      4: 18,
      5: 22,
      6: 22,
      7: 22,
      8: 36,
    };

    for (var column = 0; column < columnCount; column += 1) {
      sheet.setColumnWidth(column, widths[column] ?? 24);
    }
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(value.toLocal());
  }

  String _registrationStatusLabel(String status) {
    return switch (status) {
      'checked_in' => 'Đã check-in',
      'registered' => 'Đã đăng ký',
      'waitlisted' => 'Danh sách chờ',
      'cancelled' => 'Đã hủy',
      'rejected' => 'Đã từ chối',
      _ => 'Đang chờ',
    };
  }

  String _checkInStatusLabel(String status) {
    return status == 'checked_in' ? 'Đã check-in' : 'Chưa check-in';
  }

  String _safeFilePart(String value) {
    final safe = value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    return safe.isEmpty ? 'event' : safe;
  }
}

class AttendeeExportResult {
  final String fileName;
  final String path;

  const AttendeeExportResult({required this.fileName, required this.path});
}
