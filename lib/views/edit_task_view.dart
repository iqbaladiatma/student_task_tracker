import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import '../model/task.dart';
import '../routes/app_routes.dart';

// --- Palet Warna Modern ---
const Color primaryColor = Color(0xFF0A57E7); // Biru Kuat
const Color primaryColorLight = Color(0xFF4285F4); // Biru Lebih Terang
const Color accentColorRed = Color(0xFFD32F2F); // Merah Kuat
const Color accentColorRedLight = Color(0xFFE57373); // Merah Lebih Terang
const Color completedColor = Color(0xFF388E3C); // Hijau (Diperlukan untuk Snackbar)
const Color pendingColor = Color(0xFFF57C00); // Oranye
const Color backgroundColor = Color(0xFFF4F6F8); // Latar Belakang Abu-abu Muda
const Color cardColor = Colors.white;
const Color textColorPrimary = Color(0xFF212121); // Hitam Pekat
const Color textColorSecondary = Color(0xFF757575); // Abu-abu
// ---

/// EditTaskView untuk mengubah tugas yang sudah ada
/// Menyediakan form dengan data pre-filled dan opsi delete
class EditTaskView extends StatefulWidget {
  final Task task;

  const EditTaskView({required this.task, super.key});

  @override
  State<EditTaskView> createState() => _EditTaskViewState();
}

class _EditTaskViewState extends State<EditTaskView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();

  DateTime? _selectedDeadline;
  bool _isLoading = false;
  bool _hasChanges = false;

  // Focus nodes untuk navigasi antar field
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _subjectFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  /// Initialize form dengan data task yang akan diedit
  void _initializeForm() {
    _titleController.text = widget.task.title;
    _descriptionController.text = widget.task.description;
    _subjectController.text = widget.task.subject;
    _selectedDeadline = widget.task.deadline;

    // Listen untuk perubahan pada form
    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
    _subjectController.addListener(_onFormChanged);
  }

  /// Callback ketika form berubah
  void _onFormChanged() {
    final hasChanges = _titleController.text != widget.task.title ||
        _descriptionController.text != widget.task.description ||
        _subjectController.text != widget.task.subject ||
        _selectedDeadline != widget.task.deadline;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _descriptionController.removeListener(_onFormChanged);
    _subjectController.removeListener(_onFormChanged);
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
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody());
  }

  /// Build AppBar dengan tombol cancel, save, dan delete
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Edit Tugas',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white, size: 28),
        onPressed: _handleCancel,
        tooltip: 'Batal',
      ),
      actions: [
        // Delete button
        IconButton(
          onPressed: _isLoading ? null : _handleDelete,
          icon: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
          tooltip: 'Hapus Tugas',
        ),
        // Save button
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: TextButton(
            onPressed: (_isLoading || !_hasChanges) ? null : _handleSave,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              // Kontrol warna saat disable (tidak ada perubahan)
              disabledForegroundColor: Colors.white.withOpacity(0.5),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Simpan',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _hasChanges
                            ? Colors.white
                            : Colors.white.withOpacity(0.5)),
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
                color: cardColor,
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
            _buildSaveButton(), // Tombol Simpan Biru
            const SizedBox(height: 12),
            _buildDeleteButton(), // Tombol Hapus Merah
            const SizedBox(height: 12),
            _buildCancelButton(), // Tombol Batal Outline
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
            cardColor.withOpacity(0.1),
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
              Icons.edit_outlined,
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
                  'Edit Tugas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Perbarui detail tugas "${widget.task.title}"',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: textColorSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build field untuk judul tugas
  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Judul Tugas *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          focusNode: _titleFocusNode,
          style: const TextStyle(
            fontSize: 16,
            height: 1.3,
            color: textColorPrimary, // Teks input HITAM
          ),
          decoration: InputDecoration(
            hintText: 'Masukkan judul tugas yang jelas dan deskriptif',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon:
                const Icon(Icons.assignment_outlined, color: primaryColor),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
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
    );
  }

  /// Build field untuk mata pelajaran
  Widget _buildSubjectField() {
    final taskController = Get.find<TaskController>();
    final existingSubjects = taskController.getUniqueSubjects();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mata Pelajaran *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _subjectController,
          focusNode: _subjectFocusNode,
          style: const TextStyle(
            fontSize: 16,
            height: 1.3,
            color: textColorPrimary, // Teks input HITAM
          ),
          decoration: InputDecoration(
            hintText: 'Contoh: Matematika, Bahasa Indonesia, Fisika',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.school_outlined, color: primaryColor),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
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
        if (existingSubjects.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Mata pelajaran yang sudah ada:',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: textColorSecondary),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: existingSubjects.take(5).map((subject) {
              final color = _getSubjectColor(subject);
              return ActionChip(
                label: Text(subject),
                onPressed: () {
                  _subjectController.text = subject;
                  _onFormChanged();
                },
                // START Perubahan: Mengubah background chip menjadi TRANSPARAN
                backgroundColor: const Color.fromARGB(255, 233, 233, 233), // TRANSPARAN
                labelStyle: TextStyle(
                  color: color, // Teks warna subjek
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                side: BorderSide(
                    color: color.withOpacity(0.5),
                    width: 1.5), // Border tetap terlihat
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                avatar: Icon(
                  Icons.school_outlined,
                  size: 16,
                  color: color,
                ),
                // END Perubahan
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  /// Get warna untuk mata pelajaran berdasarkan hash
  Color _getSubjectColor(String subject) {
    final hash = subject.hashCode;
    final colors = [
      primaryColor,
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

  /// Build field untuk deskripsi tugas
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
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
        TextFormField(
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
            color: textColorPrimary, // Teks input HITAM
          ),
          decoration: InputDecoration(
            hintText:
                'Jelaskan detail tugas, instruksi khusus, atau catatan penting...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon:
                const Icon(Icons.description_outlined, color: primaryColor),
            alignLabelWithHint: true,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
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
      ],
    );
  }

  /// Build field untuk deadline dengan DatePicker
  Widget _buildDeadlineField() {
    final deadlineText = _selectedDeadline != null
        ? _formatDeadline(_selectedDeadline!)
        : 'Pilih tanggal dan waktu deadline';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deadline *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDeadline,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: 'Pilih tanggal deadline',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              errorText: _getDeadlineError(),
              prefixIcon:
                  const Icon(Icons.schedule_outlined, color: primaryColor),
              suffixIcon: _selectedDeadline != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: accentColorRed),
                      onPressed: () {
                        setState(() {
                          _selectedDeadline = null;
                        });
                        _onFormChanged();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            child: Text(
              deadlineText,
              style: TextStyle(
                color: _selectedDeadline != null
                    ? textColorPrimary
                    : textColorSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build tombol simpan utama dengan gradasi biru
  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: (_isLoading || !_hasChanges)
              ? [
                  primaryColor.withOpacity(0.5),
                  primaryColorLight.withOpacity(0.5)
                ]
              : [primaryColorLight, primaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: (_isLoading || !_hasChanges) ? null : _handleSave,
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
          _isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
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
        ),
      ),
    );
  }

  /// Build tombol delete dengan gradasi merah
  Widget _buildDeleteButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isLoading
              ? [
                  accentColorRedLight.withOpacity(0.5),
                  accentColorRed.withOpacity(0.5)
                ]
              : [accentColorRedLight, accentColorRed],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: accentColorRed.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleDelete,
        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.white),
        label: const Text(
          'Hapus Tugas',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
            fontSize: 16, fontWeight: FontWeight.w600, color: textColorSecondary),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: textColorSecondary,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey[400]!, width: 1.5),
      ),
    );
  }

  /// Handle pemilihan deadline dengan DatePicker bertema
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
      // Theming picker
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: primaryColor,
                  onPrimary: Colors.white,
                  onSurface: textColorPrimary,
                ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor, // Tombol "Pilih" dan "Batal"
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      if (!mounted) return;
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDeadline ?? DateTime(now.year, now.month, now.day, 23, 59),
        ),
        helpText: 'Pilih Waktu Deadline',
        cancelText: 'Batal',
        confirmText: 'Pilih',
        // Theming picker
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    onSurface: textColorPrimary,
                  ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
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
        _onFormChanged();
      }
    }
  }

  /// Format deadline untuk ditampilkan
  String _formatDeadline(DateTime deadline) {
    try {
      final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
      final timeFormat = DateFormat('HH:mm', 'id_ID');
      return '${dateFormat.format(deadline)} pukul ${timeFormat.format(deadline)}';
    } catch (e) {
      // Fallback
      final dateFormat = DateFormat('EEEE, dd MMMM yyyy');
      final timeFormat = DateFormat('HH:mm');
      return '${dateFormat.format(deadline)} at ${timeFormat.format(deadline)}';
    }
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

    if (!_formKey.currentState!.validate()) {
      isValid = false;
    }

    if (_selectedDeadline == null) {
      _showErrorSnackbar('Deadline harus dipilih');
      isValid = false;
    } else if (_getDeadlineError() != null) {
      _showErrorSnackbar(_getDeadlineError()!);
      isValid = false;
    }

    return isValid;
  }

  /// Handle save perubahan tugas
  Future<void> _handleSave() async {
    if (!_hasChanges || !_validateForm()) {
      if (!_hasChanges) {
        _showErrorSnackbar('Tidak ada perubahan untuk disimpan.');
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subject: _subjectController.text.trim(),
        deadline: _selectedDeadline!,
        updatedAt: DateTime.now(),
      );

      final taskController = Get.find<TaskController>();
      final success = await taskController.updateTask(updatedTask);

      if (success) {
        _showSuccessSnackbar('Tugas berhasil diperbarui');
        // Hapus parameter 'transition'
        Get.offAllNamed(AppRoutes.home);
      } else {
        _showErrorSnackbar(
          taskController.errorMessage.isNotEmpty
              ? taskController.errorMessage
              : 'Gagal memperbarui tugas',
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

  /// Handle delete tugas dengan konfirmasi
  Future<void> _handleDelete() async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final taskController = Get.find<TaskController>();
      final success = await taskController.deleteTask(widget.task.id);

      if (success) {
        _showSuccessSnackbar('Tugas berhasil dihapus');
        // Hapus parameter 'transition'
        Get.offAllNamed(AppRoutes.home);
      } else {
        _showErrorSnackbar(
          taskController.errorMessage.isNotEmpty
              ? taskController.errorMessage
              : 'Gagal menghapus tugas',
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
    if (_hasChanges) {
      _showCancelConfirmation();
    } else {
      // Hapus parameter 'transition'
      Get.offAllNamed(AppRoutes.home);
    }
  }

  /// Tampilkan dialog konfirmasi delete
  Future<bool> _showDeleteConfirmation() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Tugas?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
            const SizedBox(height: 8),
            Text(
              'Judul: ${widget.task.title}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Mata Pelajaran: ${widget.task.subject}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
                  color: accentColorRed.withOpacity(0.9), fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child:
                const Text('Batal', style: TextStyle(color: textColorSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Tampilkan dialog konfirmasi cancel
  void _showCancelConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Perubahan?'),
        content: const Text(
          'Anda memiliki perubahan yang belum disimpan. '
          'Apakah Anda yakin ingin membatalkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tidak', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              // Hapus parameter 'transition'
              Get.offAllNamed(AppRoutes.home); // Kembali ke home
            },
            child:
                const Text('Ya, Batalkan', style: TextStyle(color: primaryColor)),
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