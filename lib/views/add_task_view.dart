import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import '../model/task.dart';
import '../routes/app_routes.dart';
import '../utils/accessibility_utils.dart';

// --- Palet Warna Modern (diimpor/didefinisikan ulang untuk konsistensi) ---
// Sebaiknya, konstanta ini diletakkan di file terpisah (misalnya, color_constants.dart)
// dan diimpor. Untuk tujuan contoh ini, saya mendefinisikannya langsung.
const Color primaryColor = Color(0xFF0A57E7); // Biru Kuat
const Color primaryColorLight = Color(0xFF4285F4); // Biru Lebih Terang
const Color accentColorRed = Color(0xFFD32F2F); // Merah Kuat
const Color completedColor = Color(0xFF388E3C); // Hijau
const Color pendingColor = Color(0xFFF57C00); // Oranye
const Color backgroundColor = Color(0xFFF4F6F8); // Latar Belakang Abu-abu Muda
const Color textColorPrimary = Color(0xFF212121); // Hitam Pekat
const Color textColorSecondary = Color(0xFF757575); // Abu-abu
// ---

/// AddTaskView untuk menambah tugas baru
/// Menyediakan form dengan validasi untuk input data tugas
class AddTaskView extends StatefulWidget {
  const AddTaskView({super.key});

  @override
  State<AddTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();

  DateTime? _selectedDeadline;
  bool _isLoading = false;

  // Focus nodes untuk navigasi antar field dengan accessibility
  final _titleFocusNode = AccessibilityUtils.createFocusNode(
    debugLabel: 'Title Field',
  );
  final _descriptionFocusNode = AccessibilityUtils.createFocusNode(
    debugLabel: 'Description Field',
  );
  final _subjectFocusNode = AccessibilityUtils.createFocusNode(
    debugLabel: 'Subject Field',
  );

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _subjectFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // Menggunakan warna latar belakang
      appBar: _buildAppBar(),
      body: AccessibilityUtils.createSemanticWidget(
        label: 'Form tambah tugas baru',
        hint: 'Isi semua field yang diperlukan untuk membuat tugas baru',
        child: _buildBody(),
      ),
    );
  }

  /// Build AppBar dengan tombol cancel dan save
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: AccessibilityUtils.createSemanticWidget(
        header: true,
        label: 'Tambah Tugas Baru',
        child: const Text(
          'Tambah Tugas Baru',
          style: TextStyle(color: Colors.white), // Warna teks putih
        ),
      ),
      // Gradasi biru modern
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColorLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      backgroundColor: Colors.transparent, // Latar belakang AppBar transparan
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white), // Warna icon putih
      leading: AccessibilityUtils.ensureMinTouchTarget(
        child: Semantics(
          button: true,
          label: AccessibilityUtils.cancelLabel,
          hint: 'Batalkan pembuatan tugas dan kembali ke daftar tugas',
          onTap: _handleCancel,
          child: IconButton(
            icon: const Icon(Icons.close, size: 28),
            onPressed: _handleCancel,
          ),
        ),
      ),
      actions: [
        AccessibilityUtils.ensureMinTouchTarget(
          child: Semantics(
            button: true,
            label: AccessibilityUtils.getButtonSemantics(
              label: AccessibilityUtils.saveTaskLabel,
              isLoading: _isLoading,
              isEnabled: !_isLoading,
            ),
            onTap: _isLoading ? null : _handleSave,
            child: TextButton(
              onPressed: _isLoading ? null : _handleSave,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                foregroundColor: Colors.white, // Warna teks tombol putih
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white, // Warna loading putih
                        semanticsLabel: 'Menyimpan tugas',
                      ),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build body dengan form input modern
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            _buildFormHeader(),
            const SizedBox(height: 24),

            // Form fields dalam card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTitleField(),
                  const SizedBox(height: 20),
                  _buildSubjectField(),
                  const SizedBox(height: 20),
                  _buildDescriptionField(),
                  const SizedBox(height: 20),
                  _buildDeadlineField(),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSaveButton(),
            const SizedBox(height: 12),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  /// Build header form yang menarik
  Widget _buildFormHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.1),
            primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_task,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat Tugas Baru',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Isi detail tugas yang ingin Anda buat',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: textColorSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build field untuk judul tugas dengan styling modern
  Widget _buildTitleField() {
    return Semantics(
      textField: true,
      label: AccessibilityUtils.getFormFieldSemantics(
        label: 'Judul Tugas',
        isRequired: true,
        value: _titleController.text,
        hint: 'Masukkan judul tugas, maksimal 100 karakter',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_outlined,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Judul Tugas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: accentColorRed,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            focusNode: _titleFocusNode,
            decoration: InputDecoration(
              hintText: 'Masukkan judul tugas yang jelas dan deskriptif',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              height: 1.3,
              color: textColorPrimary, // Diubah menjadi hitam
            ),
            maxLength: 100,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _subjectFocusNode.requestFocus(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Judul tugas tidak boleh kosong';
              }
              if (value.trim().length < 3) {
                return 'Judul tugas minimal 3 karakter';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Build field untuk mata pelajaran dengan styling modern
  Widget _buildSubjectField() {
    final taskController = Get.find<TaskController>();
    final existingSubjects = taskController.getUniqueSubjects();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.school_outlined,
              color: primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Mata Pelajaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: accentColorRed,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Semantics(
          textField: true,
          label: AccessibilityUtils.getFormFieldSemantics(
            label: 'Mata Pelajaran',
            isRequired: true,
            value: _subjectController.text,
            hint: 'Masukkan nama mata pelajaran',
          ),
          child: TextFormField(
            controller: _subjectController,
            focusNode: _subjectFocusNode,
            decoration: InputDecoration(
              hintText: 'Contoh: Matematika, Bahasa Indonesia, Fisika',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              height: 1.3,
              color: textColorPrimary, // Diubah menjadi hitam
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _descriptionFocusNode.requestFocus(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Mata pelajaran tidak boleh kosong';
              }
              return null;
            },
          ),
        ),
        if (existingSubjects.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Pilih dari mata pelajaran yang sudah ada:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: textColorSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: 'Pilihan mata pelajaran yang sudah ada',
            hint:
                'Ketuk salah satu untuk menggunakan mata pelajaran yang sudah ada',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: existingSubjects.take(5).map((subject) {
                final color = _getSubjectColor(subject);
                return AccessibilityUtils.ensureMinTouchTarget(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.1),
                          color.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () {
                          _subjectController.text = subject;
                          AccessibilityUtils.announceMessage(
                            'Mata pelajaran $subject dipilih',
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 16,
                                color: color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                subject,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).asSemanticButton(
                    label: 'Pilih mata pelajaran $subject',
                    hint: 'Ketuk untuk menggunakan mata pelajaran $subject',
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  /// Get warna untuk mata pelajaran berdasarkan hash
  Color _getSubjectColor(String subject) {
    final hash = subject.hashCode;
    final colors = [
      primaryColor, // Menggunakan warna dari palet yang baru
      completedColor,
      Colors.purple,
      pendingColor,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.brown,
    ];
    return colors[hash.abs() % colors.length];
  }

  /// Build field untuk deskripsi tugas dengan styling modern
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.description_outlined,
              color: primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Deskripsi Tugas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(Opsional)',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Semantics(
          textField: true,
          label: AccessibilityUtils.getFormFieldSemantics(
            label: 'Deskripsi Tugas',
            isRequired: false,
            value: _descriptionController.text,
            hint: 'Masukkan deskripsi tugas, maksimal 500 karakter, opsional',
          ),
          child: TextFormField(
            controller: _descriptionController,
            focusNode: _descriptionFocusNode,
            decoration: InputDecoration(
              hintText:
                  'Jelaskan detail tugas, instruksi khusus, atau catatan penting...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              alignLabelWithHint: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: textColorPrimary, // Diubah menjadi hitam
            ),
            maxLines: 4,
            maxLength: 500,
            textInputAction: TextInputAction.newline,
            validator: (value) {
              if (value != null && value.length > 500) {
                return 'Deskripsi maksimal 500 karakter';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  /// Build field untuk deadline dengan DatePicker modern
  Widget _buildDeadlineField() {
    final deadlineText = _selectedDeadline != null
        ? _formatDeadline(_selectedDeadline!)
        : 'Pilih tanggal dan waktu deadline';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.schedule_outlined,
              color: primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Deadline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: accentColorRed,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Semantics(
          button: true,
          label: AccessibilityUtils.getFormFieldSemantics(
            label: 'Deadline Tugas',
            isRequired: true,
            value: deadlineText,
            hint: 'Ketuk untuk membuka pemilih tanggal dan waktu deadline',
            error: _getDeadlineError(),
          ),
          onTap: _selectDeadline,
          child: AccessibilityUtils.ensureMinTouchTarget(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getDeadlineError() != null
                      ? accentColorRed
                      : Colors.grey[300]!,
                  width: _getDeadlineError() != null ? 2 : 1,
                ),
                color: Colors.grey[50],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _selectDeadline,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedDeadline != null
                                ? primaryColor.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: _selectedDeadline != null
                                ? primaryColor
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedDeadline != null
                                    ? 'Deadline dipilih'
                                    : 'Pilih Deadline',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                deadlineText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedDeadline != null
                                      ? textColorPrimary
                                      : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedDeadline != null)
                          Container(
                            decoration: BoxDecoration(
                              color: accentColorRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AccessibilityUtils.ensureMinTouchTarget(
                              child: Semantics(
                                button: true,
                                label: AccessibilityUtils.clearDateLabel,
                                hint: 'Hapus tanggal deadline yang dipilih',
                                onTap: () {
                                  setState(() {
                                    _selectedDeadline = null;
                                  });
                                  AccessibilityUtils.announceMessage(
                                    'Deadline dihapus',
                                  );
                                },
                                child: IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  color: accentColorRed,
                                  onPressed: () {
                                    setState(() {
                                      _selectedDeadline = null;
                                    });
                                    AccessibilityUtils.announceMessage(
                                      'Deadline dihapus',
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_getDeadlineError() != null) ...[
          const SizedBox(height: 8),
          Text(
            _getDeadlineError()!,
            style: const TextStyle(color: accentColorRed, fontSize: 12),
          ),
        ],
      ],
    );
  }

  /// Build tombol simpan utama dengan styling modern
  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleSave,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save_outlined, size: 20),
        label: Text(
          _isLoading ? 'Menyimpan Tugas...' : 'Simpan Tugas',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  /// Build tombol cancel dengan styling modern
  Widget _buildCancelButton() {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _handleCancel,
      icon:
          const Icon(Icons.close_outlined, size: 20, color: textColorSecondary),
      label: const Text(
        'Batal',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColorSecondary,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey[400]!, width: 1.5),
        foregroundColor: textColorSecondary,
      ),
    );
  }

  /// Handle pemilihan deadline dengan DatePicker
  Future<void> _selectDeadline() async {
    final now = DateTime.now();
    final initialDate = _selectedDeadline ?? now.add(const Duration(days: 1));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Pilih Deadline',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        // Ganti warna DatePicker
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor, // Warna header dan tombol utama
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textColorPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      // Pilih waktu juga
      if (!mounted) return;

      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDeadline ?? DateTime(now.year, now.month, now.day, 23, 59),
        ),
        helpText: 'Pilih Waktu Deadline',
        cancelText: 'Batal',
        confirmText: 'Pilih',
        builder: (context, child) {
          // Ganti warna TimePicker
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: primaryColor, // Warna header dan tombol utama
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: textColorPrimary,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
            ),
            child: child!,
          );
        },
      );

      if (selectedTime != null) {
        setState(() {
          _selectedDeadline = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
        AccessibilityUtils.announceMessage(
          'Deadline diatur ke ${_formatDeadline(_selectedDeadline!)}',
        );
      }
    }
  }

  /// Format deadline untuk ditampilkan
  String _formatDeadline(DateTime deadline) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm', 'id_ID');
    return '${dateFormat.format(deadline)} pukul ${timeFormat.format(deadline)}';
  }

  /// Get error message untuk deadline
  String? _getDeadlineError() {
    if (_selectedDeadline == null) {
      return null;
    }

    final now = DateTime.now();
    if (_selectedDeadline!.isBefore(now)) {
      return 'Deadline tidak boleh di masa lalu';
    }

    return null;
  }

  /// Validasi form secara keseluruhan
  bool _validateForm() {
    bool isValid = true;

    // Validasi form fields
    if (!_formKey.currentState!.validate()) {
      isValid = false;
      AccessibilityUtils.announceMessage(
        'Validasi form gagal. Periksa kembali field yang kosong atau salah',
      );
    }

    // Validasi deadline
    if (_selectedDeadline == null) {
      _showErrorSnackbar('Deadline harus dipilih');
      isValid = false;
    } else if (_selectedDeadline!.isBefore(DateTime.now())) {
      // Jika deadline di masa lalu, tampilkan error
      final errorMessage = 'Deadline tidak boleh di masa lalu';
      _showErrorSnackbar(errorMessage);
      isValid = false;
    }

    return isValid;
  }

  /// Handle save tugas
  Future<void> _handleSave() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final task = Task(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subject: _subjectController.text.trim(),
        deadline: _selectedDeadline!,
      );

      final taskController = Get.find<TaskController>();
      final success = await taskController.addTask(task);

      if (success) {
        _showSuccessSnackbar('Tugas berhasil ditambahkan');
        AccessibilityUtils.announceMessage('Tugas berhasil ditambahkan');
        // Kembali ke home dan refresh data
        Get.offAllNamed(AppRoutes.home);
      } else {
        final errorMsg = taskController.errorMessage.isNotEmpty
            ? taskController.errorMessage
            : 'Gagal menambahkan tugas';
        _showErrorSnackbar(errorMsg);
        AccessibilityUtils.announceMessage('Gagal menyimpan tugas: $errorMsg');
      }
    } catch (e) {
      final errorMsg = 'Terjadi kesalahan: ${e.toString()}';
      _showErrorSnackbar(errorMsg);
      AccessibilityUtils.announceMessage('Error saat menyimpan tugas: $errorMsg');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle cancel dengan konfirmasi jika ada perubahan
  void _handleCancel() {
    final hasChanges = _titleController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _subjectController.text.isNotEmpty ||
        _selectedDeadline != null;

    if (hasChanges) {
      _showCancelConfirmation();
    } else {
      AccessibilityUtils.announceMessage('Membatalkan penambahan tugas');
      Get.offAllNamed(AppRoutes.home);
    }
  }

  /// Tampilkan dialog konfirmasi cancel
  void _showCancelConfirmation() {
    Get.dialog(
      AlertDialog(
        // Tema AlertDialog akan mengikuti tema Get.theme atau ThemeData.
        // Untuk memastikan kontras tinggi, kita atur warna teks tombol.
        title: const Text('Batalkan Perubahan?'),
        content: const Text(
          'Anda memiliki perubahan yang belum disimpan. '
          'Apakah Anda yakin ingin membatalkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            // START Perubahan: Mengubah warna teks tombol 'Tidak' menjadi putih
            child: const Text('Tidak', style: TextStyle(color: Colors.white)),
            // END Perubahan
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              AccessibilityUtils.announceMessage('Penambahan tugas dibatalkan');
              Get.offAllNamed(AppRoutes.home); // Kembali ke home
            },
            child:
                const Text('Ya, Batalkan', style: TextStyle(color: accentColorRed)),
          ),
        ],
      ),
    );
  }

  /// Tampilkan success snackbar
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: completedColor,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  /// Tampilkan error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: accentColorRed,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }
}