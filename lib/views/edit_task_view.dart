import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import '../model/task.dart';
import '../routes/app_routes.dart';
import '../utils/accessibility_utils.dart';
import '../utils/colors.dart'; // Import file colors.dart

// Palet warna sekarang diimpor dari utils/colors.dart

/// EditTaskView untuk memperbarui tugas yang sudah ada
/// Menyediakan form dengan validasi untuk input data tugas
class EditTaskView extends StatefulWidget {
  final Task task;
  const EditTaskView({super.key, required this.task});

  @override
  State<EditTaskView> createState() => _EditTaskViewState();
}

class _EditTaskViewState extends State<EditTaskView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _subjectController;

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
  void initState() {
    super.initState();
    // Isi controller dengan data dari task yang ada
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _subjectController = TextEditingController(text: widget.task.subject);
    _selectedDeadline = widget.task.deadline;
  }

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
    // 1. Menambahkan dekorasi gradien (sama seperti AddTaskView)
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            backgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        // Membuat scaffold transparan agar gradien terlihat
        backgroundColor: Colors.transparent,
        // Menghapus AppBar
        // appBar: _buildAppBar(),
        body: SafeArea( // Menambahkan SafeArea
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: AccessibilityUtils.createSemanticWidget(
                      label: 'Form edit tugas',
                      hint: 'Ubah field yang diperlukan untuk memperbarui tugas',
                      child: _buildBody(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Build body dengan form input modern
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // <-- Menambahkan ini untuk center
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            _buildFormHeader(),
            const SizedBox(height: 24),

            // Form fields dalam card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor, // Warna card putih
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08), // Shadow lebih halus
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTitleField(),
                  const SizedBox(height: 1),
                  _buildSubjectField(),
                  const SizedBox(height: 1),
                  _buildDescriptionField(),
                  const SizedBox(height: 1),
                  _buildDeadlineField(),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSaveButton(), // Tombol utama
            const SizedBox(height: 12),
            _buildCancelButton(), // Tombol sekunder
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
            cardColor.withOpacity(0.99), // Gradient ke warna card
            cardColor.withOpacity(0.80), // Gradient ke warna card
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
              Icons.edit_outlined, // <-- Ganti Ikon
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
                  'Edit Tugas', // <-- Ganti Judul
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Perbarui detail tugas Anda', // <-- Ganti Subjudul
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
          _buildFieldLabel('Judul Tugas', isRequired: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            focusNode: _titleFocusNode,
            decoration: _buildInputDecoration(
              hintText: 'Contoh: Kerjakan Latihan Bab 5',
              prefixIcon: Icons.assignment_outlined,
            ),
            style: const TextStyle(
              fontSize: 16,
              height: 1.3,
              color: textColorPrimary,
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

  /// Build field untuk mata pelajaran dengan styling modern dan auto-suggest
  Widget _buildSubjectField() {
    final taskController = Get.find<TaskController>();
    final existingSubjects = taskController.getUniqueSubjects();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Mata Pelajaran', isRequired: true),
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
            decoration: _buildInputDecoration(
              hintText: 'Contoh: Matematika, Bahasa Indonesia',
              prefixIcon: Icons.school_outlined,
            ),
            style: const TextStyle(
              fontSize: 16,
              height: 1.3,
              color: textColorPrimary,
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
        // Fitur chip mata pelajaran yang sudah ada (sama seperti AddTaskView)
        if (existingSubjects.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Pilih dari yang sudah ada:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColorSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: 'Pilihan mata pelajaran yang sudah ada',
            hint: 'Ketuk salah satu untuk menggunakan',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: existingSubjects.take(5).map((subject) {
                final color = _getSubjectColor(subject);
                return ActionChip(
                  label: Text(subject),
                  onPressed: () {
                    _subjectController.text = subject;
                    AccessibilityUtils.announceMessage(
                        'Mata pelajaran $subject dipilih');
                  },
                  backgroundColor: color.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  side: BorderSide(color: color.withOpacity(0.3), width: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  avatar: Icon(Icons.school_outlined, size: 16, color: color),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ).asSemanticButton(
                  label: 'Pilih mata pelajaran $subject',
                  hint: 'Ketuk untuk menggunakan $subject',
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  /// Get warna untuk mata pelajaran berdasarkan hash (sama seperti AddTaskView)
  Color _getSubjectColor(String subject) {
    final hash = subject.hashCode;
    final colors = [
      primaryColor,
      completedColor,
      Colors.purple.shade600,
      pendingColor,
      Colors.teal.shade600,
      Colors.indigo.shade600,
      Colors.pink.shade600,
      Colors.brown.shade600,
    ];
    return colors[hash.abs() % colors.length];
  }

  /// Build field untuk deskripsi tugas dengan styling modern
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Deskripsi Tugas', isRequired: false),
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
            decoration: _buildInputDecoration(
              hintText: 'Jelaskan detail tugas, instruksi, catatan...',
              prefixIcon: Icons.description_outlined,
              alignLabelWithHint: true,
            ),
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: textColorPrimary,
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
        : 'Pilih tanggal & waktu';

    final hasError = _getDeadlineError() != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Deadline', isRequired: true),
        const SizedBox(height: 8),
        Semantics(
          button: true,
          label: AccessibilityUtils.getFormFieldSemantics(
            label: 'Deadline Tugas',
            isRequired: true,
            value: deadlineText,
            hint: 'Ketuk untuk memilih tanggal dan waktu deadline',
            error: _getDeadlineError(),
          ),
          onTap: _selectDeadline,
          child: AccessibilityUtils.ensureMinTouchTarget(
            child: Material(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _selectDeadline,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: _buildInputDecoration(
                    hintText: deadlineText, // Show text inside
                    prefixIcon: Icons.calendar_today_outlined,
                    errorText: _getDeadlineError(), // Show error below
                  ).copyWith(
                    contentPadding: const EdgeInsets.fromLTRB(
                        16, 16, 8, 16), // Adjust padding for clear button
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: hasError ? accentColorRed : Colors.grey[300]!,
                          width: hasError ? 1.5 : 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: hasError ? accentColorRed : Colors.grey[300]!,
                          width: hasError ? 1.5 : 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: hasError ? accentColorRed : primaryColor,
                          width: 2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          deadlineText,
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedDeadline != null
                                ? textColorPrimary
                                : textColorSecondary.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_selectedDeadline != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          color: accentColorRed,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: AccessibilityUtils.clearDateLabel,
                          onPressed: () {
                            setState(() {
                              _selectedDeadline = null;
                            });
                            AccessibilityUtils.announceMessage('Deadline dihapus');
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build label untuk field form
  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primaryColor, // Label color
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              color: accentColorRed,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          Text(
            ' (Opsional)',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  /// Build decoration dasar untuk TextFormField
  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    bool alignLabelWithHint = false,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: primaryColor.withOpacity(0.8)),
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
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentColorRed, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentColorRed, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50], // Light background for fields
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      alignLabelWithHint: alignLabelWithHint,
      errorText: errorText, // Assign error text
    );
  }

  /// Build tombol simpan utama dengan gradasi biru
  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isLoading
              ? [
                  primaryColor.withOpacity(0.5),
                  primaryColorLight.withOpacity(0.5)
                ]
              : [primaryColorLight, primaryColor], // Gradient effect
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5), // Shadow effect
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
            : const Icon(Icons.save_outlined, size: 20, color: Colors.white),
        label: Text(
          _isLoading ? 'Menyimpan...' : 'Simpan Perubahan', // <-- Ganti Teks
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Let gradient show
          shadowColor: Colors.transparent, // No button shadow
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 50), // Full width
        ),
      ),
    );
  }

  /// Build tombol cancel dengan styling modern (outline)
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
        foregroundColor: textColorSecondary,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey[400]!, width: 1.5),
        minimumSize: const Size(double.infinity, 50), // Full width
      ),
    );
  }

  /// Handle pemilihan deadline dengan DatePicker bertema
  Future<void> _selectDeadline() async {
    final now = DateTime.now();
    // Gunakan tanggal yang ada atau 1 hari dari sekarang
    final initialDate = _selectedDeadline ?? now.add(const Duration(days: 1));

    // Pastikan initialDate tidak sebelum firstDate
    // Beri sedikit kelonggaran (misal 5 menit) jika deadline-nya hari ini
    final validFirstDate = now.subtract(const Duration(minutes: 5));
    final validInitialDate =
        initialDate.isBefore(validFirstDate) ? validFirstDate : initialDate;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: validInitialDate,
      firstDate: validFirstDate, // Izinkan memilih waktu hari ini
      lastDate: now.add(const Duration(days: 365 * 2)), // Allow up to 2 years
      helpText: 'Pilih Tanggal Deadline',
      cancelText: 'Batal',
      confirmText: 'Pilih Waktu', // Change confirm text
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: primaryColor,
                  onPrimary: Colors.white,
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
      if (!mounted) return;

      final TimeOfDay initialTime;
      // Jika sudah ada deadline, gunakan waktunya
      if (_selectedDeadline != null) {
        initialTime = TimeOfDay.fromDateTime(_selectedDeadline!);
      } else {
        initialTime = const TimeOfDay(hour: 23, minute: 59); // Default to end of day
      }

      final selectedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        helpText: 'Pilih Waktu Deadline',
        cancelText: 'Batal',
        confirmText: 'Simpan',
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    surface: cardColor, // Match card color
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
    try {
      final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
      final timeFormat = DateFormat('HH:mm', 'id_ID');
      return '${dateFormat.format(deadline)} - ${timeFormat.format(deadline)}';
    } catch (e) {
      // Fallback format
      return DateFormat('dd MMM yyyy, HH:mm').format(deadline);
    }
  }

  /// Get error message untuk deadline
  String? _getDeadlineError() {
    if (_selectedDeadline == null) {
      return null; // Akan ditangani oleh _validateForm
    }
    final now = DateTime.now();
    if (_selectedDeadline!.isBefore(now.subtract(const Duration(minutes: 5)))) {
      return 'Deadline tidak boleh di masa lalu';
    }
    return null;
  }

  /// Validasi form secara keseluruhan
  bool _validateForm() {
    bool isFormValid = _formKey.currentState?.validate() ?? false;
    bool isDeadlineValid = true;

    if (_selectedDeadline == null) {
      isDeadlineValid = false;
      setState(() {}); // Update UI to show potential error styling
      _showErrorSnackbar('Deadline harus dipilih');
    } else if (_getDeadlineError() != null) {
      isDeadlineValid = false;
      _showErrorSnackbar(_getDeadlineError()!);
    }

    if (!isFormValid || !isDeadlineValid) {
      AccessibilityUtils.announceMessage(
        'Validasi gagal. Periksa kembali isian form.',
      );
      return false;
    }
    return true;
  }

  /// Handle save tugas
  Future<void> _handleSave() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Buat objek Task yang diperbarui
      // PENTING: Pertahankan 'id', 'isCompleted', dan 'createdAt' dari task asli
      final updatedTask = Task(
        id: widget.task.id, // <-- PENTING
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subject: _subjectController.text.trim(),
        deadline: _selectedDeadline!,
        isCompleted: widget.task.isCompleted, // <-- PENTING
        createdAt: widget.task.createdAt, // <-- PENTING
      );

      final taskController = Get.find<TaskController>();
      // Panggil updateTask, bukan addTask
      final success =
          await taskController.updateTask(updatedTask);

      if (success) {
        _showSuccessSnackbar(
            'Tugas "${updatedTask.title}" berhasil diperbarui');
        AccessibilityUtils.announceMessage('Tugas berhasil diperbarui');
        // Kembali ke home dan refresh data
        Get.offAllNamed(AppRoutes.home);
      } else {
        final errorMsg = taskController.errorMessage.isNotEmpty
            ? taskController.errorMessage
            : 'Gagal memperbarui tugas. Coba lagi.';
        _showErrorSnackbar(errorMsg);
        AccessibilityUtils.announceMessage('Gagal menyimpan tugas: $errorMsg');
      }
    } catch (e) {
      final errorMsg = 'Terjadi kesalahan tidak terduga: ${e.toString()}';
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
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Cek perubahan berdasarkan data 'widget.task' asli
    final hasChanges = _titleController.text.trim() != widget.task.title ||
        _descriptionController.text.trim() != widget.task.description ||
        _subjectController.text.trim() != widget.task.subject ||
        _selectedDeadline != widget.task.deadline;

    if (hasChanges && !_isLoading) { // Don't show confirm if loading
      _showCancelConfirmation();
    } else if (!_isLoading) {
      AccessibilityUtils.announceMessage('Membatalkan edit tugas');
      Get.back(); // Cukup kembali ke halaman sebelumnya (detail/home)
    }
  }

  /// Tampilkan dialog konfirmasi cancel
  void _showCancelConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Perubahan?'), // <-- Ganti Teks
        content: const Text(
          'Perubahan yang Anda buat tidak akan disimpan. Apakah Anda yakin?',
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tidak', style: TextStyle(color: textColorSecondary)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              AccessibilityUtils.announceMessage('Edit tugas dibatalkan');
              Get.back(); // Kembali ke halaman sebelumnya
            },
            child: const Text('Ya, Batalkan',
                style: TextStyle(color: primaryColor)),
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
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
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
      icon: const Icon(Icons.error_outline, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }
}