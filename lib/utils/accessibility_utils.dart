import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Utility class untuk accessibility features
/// Menyediakan helper methods dan constants untuk accessibility
class AccessibilityUtils {
  AccessibilityUtils._();

  // Minimum touch target size untuk accessibility
  static const double minTouchTargetSize = 48.0;

  // Semantic labels dalam bahasa Indonesia
  static const String addTaskButtonLabel = 'Tambah tugas baru';
  static const String searchButtonLabel = 'Cari tugas';
  static const String refreshButtonLabel = 'Muat ulang daftar tugas';
  static const String closeSearchLabel = 'Tutup pencarian';
  static const String taskCompletedLabel = 'Tugas selesai';
  static const String taskPendingLabel = 'Tugas belum selesai';
  static const String editTaskLabel = 'Edit tugas';
  static const String deleteTaskLabel = 'Hapus tugas';
  static const String saveTaskLabel = 'Simpan tugas';
  static const String cancelLabel = 'Batal';
  static const String selectDateLabel = 'Pilih tanggal deadline';
  static const String clearDateLabel = 'Hapus tanggal';
  static const String filterAllLabel = 'Tampilkan semua tugas';
  static const String filterPendingLabel = 'Tampilkan tugas belum selesai';
  static const String filterCompletedLabel = 'Tampilkan tugas selesai';
  static const String filterOverdueLabel = 'Tampilkan tugas terlambat';

  /// Membuat semantic label untuk task card
  static String getTaskCardSemantics({
    required String title,
    required String subject,
    required String deadline,
    required bool isCompleted,
    required bool isOverdue,
    required bool isDueSoon,
    String? description,
  }) {
    final buffer = StringBuffer();

    // Status tugas
    if (isCompleted) {
      buffer.write('Tugas selesai: ');
    } else if (isOverdue) {
      buffer.write('Tugas terlambat: ');
    } else if (isDueSoon) {
      buffer.write('Tugas segera deadline: ');
    } else {
      buffer.write('Tugas: ');
    }

    // Judul tugas
    buffer.write(title);

    // Mata pelajaran
    buffer.write(', mata pelajaran $subject');

    // Deadline
    buffer.write(', deadline $deadline');

    // Deskripsi jika ada
    if (description != null && description.isNotEmpty) {
      buffer.write(', deskripsi: $description');
    }

    // Instruksi interaksi
    buffer.write(
      '. Ketuk untuk edit, geser kanan untuk edit, geser kiri untuk hapus',
    );

    return buffer.toString();
  }

  /// Membuat semantic label untuk filter chip
  static String getFilterChipSemantics({
    required String filterName,
    required int count,
    required bool isSelected,
  }) {
    final buffer = StringBuffer();

    if (isSelected) {
      buffer.write('Filter aktif: ');
    } else {
      buffer.write('Filter: ');
    }

    buffer.write(filterName);

    if (count > 0) {
      buffer.write(', $count tugas');
    } else {
      buffer.write(', tidak ada tugas');
    }

    if (!isSelected) {
      buffer.write('. Ketuk untuk mengaktifkan filter');
    }

    return buffer.toString();
  }

  /// Membuat semantic label untuk form field
  static String getFormFieldSemantics({
    required String label,
    required bool isRequired,
    String? value,
    String? error,
    String? hint,
  }) {
    final buffer = StringBuffer();

    buffer.write(label);

    if (isRequired) {
      buffer.write(', wajib diisi');
    }

    if (value != null && value.isNotEmpty) {
      buffer.write(', nilai saat ini: $value');
    }

    if (error != null) {
      buffer.write(', error: $error');
    }

    if (hint != null) {
      buffer.write(', petunjuk: $hint');
    }

    return buffer.toString();
  }

  /// Membuat semantic label untuk button dengan state
  static String getButtonSemantics({
    required String label,
    bool isLoading = false,
    bool isEnabled = true,
  }) {
    final buffer = StringBuffer();

    if (isLoading) {
      buffer.write('Sedang memproses, ');
    } else if (!isEnabled) {
      buffer.write('Tidak aktif, ');
    }

    buffer.write(label);

    if (isLoading) {
      buffer.write(', mohon tunggu');
    } else if (!isEnabled) {
      buffer.write(', tidak dapat ditekan');
    }

    return buffer.toString();
  }

  /// Membuat semantic label untuk empty state
  static String getEmptyStateSemantics({
    required String title,
    required String subtitle,
    String? actionLabel,
  }) {
    final buffer = StringBuffer();

    buffer.write(title);
    buffer.write('. ');
    buffer.write(subtitle);

    if (actionLabel != null) {
      buffer.write(' $actionLabel untuk memulai.');
    }

    return buffer.toString();
  }

  /// Membuat semantic label untuk loading state
  static String getLoadingSemantics(String message) {
    return 'Sedang memuat, $message, mohon tunggu';
  }

  /// Membuat semantic label untuk error state
  static String getErrorSemantics({
    required String title,
    required String message,
    String? actionLabel,
  }) {
    final buffer = StringBuffer();

    buffer.write('Error: $title. ');
    buffer.write(message);

    if (actionLabel != null) {
      buffer.write(' $actionLabel untuk mencoba lagi.');
    }

    return buffer.toString();
  }

  /// Helper untuk membuat widget dengan minimum touch target
  static Widget ensureMinTouchTarget({required Widget child, double? minSize}) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize ?? minTouchTargetSize,
        minHeight: minSize ?? minTouchTargetSize,
      ),
      child: child,
    );
  }

  /// Helper untuk membuat focus node dengan debugging
  static FocusNode createFocusNode({
    String? debugLabel,
    bool canRequestFocus = true,
  }) {
    return FocusNode(debugLabel: debugLabel, canRequestFocus: canRequestFocus);
  }

  /// Helper untuk announce message ke screen reader
  static void announceMessage(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Helper untuk membuat semantic widget dengan custom properties
  static Widget createSemanticWidget({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool? button,
    bool? header,
    bool? textField,
    bool? focusable,
    bool? enabled,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onIncrease,
    VoidCallback? onDecrease,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      header: header,
      textField: textField,
      focusable: focusable,
      enabled: enabled,
      onTap: onTap,
      onLongPress: onLongPress,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      child: child,
    );
  }

  /// Helper untuk membuat ExcludeSemantics widget
  static Widget excludeSemantics({
    required Widget child,
    bool excluding = true,
  }) {
    return ExcludeSemantics(excluding: excluding, child: child);
  }

  /// Helper untuk membuat MergeSemantics widget
  static Widget mergeSemantics({required Widget child}) {
    return MergeSemantics(child: child);
  }

  /// Konstanta untuk semantic actions
  static const SemanticsAction tapAction = SemanticsAction.tap;
  static const SemanticsAction longPressAction = SemanticsAction.longPress;
  static const SemanticsAction increaseAction = SemanticsAction.increase;
  static const SemanticsAction decreaseAction = SemanticsAction.decrease;
  static const SemanticsAction scrollLeftAction = SemanticsAction.scrollLeft;
  static const SemanticsAction scrollRightAction = SemanticsAction.scrollRight;
  static const SemanticsAction scrollUpAction = SemanticsAction.scrollUp;
  static const SemanticsAction scrollDownAction = SemanticsAction.scrollDown;

  /// Helper untuk membuat accessible divider
  static Widget createAccessibleDivider({
    String? semanticLabel,
    double height = 1.0,
    Color? color,
  }) {
    return Semantics(
      label: semanticLabel ?? 'Pemisah',
      child: Divider(height: height, color: color),
    );
  }

  /// Helper untuk membuat accessible spacer
  static Widget createAccessibleSpacer({
    double? width,
    double? height,
    String? semanticLabel,
  }) {
    final spacer = SizedBox(width: width, height: height);

    if (semanticLabel != null) {
      return Semantics(label: semanticLabel, child: spacer);
    }

    return ExcludeSemantics(child: spacer);
  }
}

/// Extension untuk menambahkan accessibility helpers ke Widget
extension AccessibilityWidgetExtension on Widget {
  /// Menambahkan semantic label ke widget
  Widget withSemanticLabel(String label) {
    return Semantics(label: label, child: this);
  }

  /// Menambahkan semantic hint ke widget
  Widget withSemanticHint(String hint) {
    return Semantics(hint: hint, child: this);
  }

  /// Menambahkan semantic value ke widget
  Widget withSemanticValue(String value) {
    return Semantics(value: value, child: this);
  }

  /// Menandai widget sebagai button untuk accessibility
  Widget asSemanticButton({String? label, String? hint, VoidCallback? onTap}) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      onTap: onTap,
      child: this,
    );
  }

  /// Menandai widget sebagai header untuk accessibility
  Widget asSemanticHeader({String? label}) {
    return Semantics(header: true, label: label, child: this);
  }

  /// Mengecualikan widget dari semantic tree
  Widget excludeFromSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// Menggabungkan semantic children
  Widget mergeSemantics() {
    return MergeSemantics(child: this);
  }

  /// Memastikan minimum touch target size
  Widget withMinTouchTarget({double? minSize}) {
    return AccessibilityUtils.ensureMinTouchTarget(
      child: this,
      minSize: minSize,
    );
  }
}
