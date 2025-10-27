import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import '../model/task.dart';
import '../routes/app_routes.dart';
import '../utils/accessibility_utils.dart';

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
        child: const Text('Tambah Tugas Baru'),
      ),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
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

  /// Build body dengan form input
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildSubjectField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildDeadlineField(),
            const SizedBox(height: 32),
            _buildSaveButton(),
            const SizedBox(height: 16),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  /// Build field untuk judul tugas
  Widget _buildTitleField() {
    return Semantics(
      textField: true,
      label: AccessibilityUtils.getFormFieldSemantics(
        label: 'Judul Tugas',
        isRequired: true,
        value: _titleController.text,
        hint: 'Masukkan judul tugas, maksimal 100 karakter',
      ),
      child: TextFormField(
        controller: _titleController,
        focusNode: _titleFocusNode,
        decoration: const InputDecoration(
          labelText: 'Judul Tugas *',
          hintText: 'Masukkan judul tugas',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.assignment, size: 24),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: const TextStyle(fontSize: 16, height: 1.3),
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
    );
  }

  /// Build field untuk mata pelajaran
  Widget _buildSubjectField() {
    final taskController = Get.find<TaskController>();
    final existingSubjects = taskController.getUniqueSubjects();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            decoration: const InputDecoration(
              labelText: 'Mata Pelajaran *',
              hintText: 'Masukkan mata pelajaran',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.school, size: 24),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: const TextStyle(fontSize: 16, height: 1.3),
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
            'Mata pelajaran yang sudah ada:',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: 'Pilihan mata pelajaran yang sudah ada',
            hint:
                'Ketuk salah satu untuk menggunakan mata pelajaran yang sudah ada',
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: existingSubjects.take(5).map((subject) {
                return AccessibilityUtils.ensureMinTouchTarget(
                  child:
                      ActionChip(
                        label: Text(
                          subject,
                          style: const TextStyle(fontSize: 14),
                        ),
                        onPressed: () {
                          _subjectController.text = subject;
                          AccessibilityUtils.announceMessage(
                            'Mata pelajaran $subject dipilih',
                          );
                        },
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
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

  /// Build field untuk deskripsi tugas
  Widget _buildDescriptionField() {
    return Semantics(
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
        decoration: const InputDecoration(
          labelText: 'Deskripsi',
          hintText: 'Masukkan deskripsi tugas (opsional)',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.description, size: 24),
          alignLabelWithHint: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: const TextStyle(fontSize: 16, height: 1.4),
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
    );
  }

  /// Build field untuk deadline dengan DatePicker
  Widget _buildDeadlineField() {
    final deadlineText = _selectedDeadline != null
        ? _formatDeadline(_selectedDeadline!)
        : 'Pilih tanggal deadline';

    return Semantics(
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
        child: InkWell(
          onTap: _selectDeadline,
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Deadline *',
              hintText: 'Pilih tanggal deadline',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.calendar_today, size: 24),
              suffixIcon: _selectedDeadline != null
                  ? AccessibilityUtils.ensureMinTouchTarget(
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
                          icon: const Icon(Icons.clear, size: 24),
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
                    )
                  : null,
              errorText: _getDeadlineError(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            child: Text(
              deadlineText,
              style: TextStyle(
                fontSize: 16,
                height: 1.3,
                color: _selectedDeadline != null
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Theme.of(context).hintColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build tombol simpan utama
  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _handleSave,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save),
      label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Tugas'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Build tombol cancel
  Widget _buildCancelButton() {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _handleCancel,
      icon: const Icon(Icons.cancel_outlined),
      label: const Text('Batal'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16),
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
      return null; // Error akan ditampilkan saat validasi form
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
    }

    // Validasi deadline
    if (_selectedDeadline == null) {
      _showErrorSnackbar('Deadline harus dipilih');
      isValid = false;
    } else if (_selectedDeadline!.isBefore(DateTime.now())) {
      _showErrorSnackbar('Deadline tidak boleh di masa lalu');
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
        // Kembali ke home dan refresh data
        Get.offAllNamed(AppRoutes.home);
      } else {
        _showErrorSnackbar(
          taskController.errorMessage.isNotEmpty
              ? taskController.errorMessage
              : 'Gagal menambahkan tugas',
        );
      }
    } catch (e) {
      _showErrorSnackbar('Terjadi kesalahan: ${e.toString()}');
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
    final hasChanges =
        _titleController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _subjectController.text.isNotEmpty ||
        _selectedDeadline != null;

    if (hasChanges) {
      _showCancelConfirmation();
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  /// Tampilkan dialog konfirmasi cancel
  void _showCancelConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Batalkan Perubahan?'),
        content: const Text(
          'Anda memiliki perubahan yang belum disimpan. '
          'Apakah Anda yakin ingin membatalkan?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Tidak')),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.offAllNamed(AppRoutes.home); // Kembali ke home
            },
            child: const Text('Ya, Batalkan'),
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
      backgroundColor: Colors.green,
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
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }
}
