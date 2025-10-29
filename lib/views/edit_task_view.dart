import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import '../model/task.dart';
import '../routes/app_routes.dart';
import '../utils/accessibility_utils.dart'; // Import AccessibilityUtils

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
  final _titleFocusNode = AccessibilityUtils.createFocusNode(debugLabel: 'Title Field');
  final _descriptionFocusNode = AccessibilityUtils.createFocusNode(debugLabel: 'Description Field');
  final _subjectFocusNode = AccessibilityUtils.createFocusNode(debugLabel: 'Subject Field');


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
    // Note: Perubahan deadline dihandle secara terpisah di _selectDeadline
  }

  /// Callback ketika form berubah (selain deadline)
  void _onFormChanged() {
    _checkForChanges();
  }

  /// Check for any changes in the form compared to the original task
  void _checkForChanges() {
     final hasFormChanges = _titleController.text != widget.task.title ||
        _descriptionController.text != widget.task.description ||
        _subjectController.text != widget.task.subject ||
        _selectedDeadline != widget.task.deadline;

    if (hasFormChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasFormChanges;
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
      title: AccessibilityUtils.createSemanticWidget( // Add Semantics
        header: true,
        label: 'Edit Tugas',
        child: const Text('Edit Tugas',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
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
      backgroundColor: Colors.transparent,
      elevation: 0,
       leading: AccessibilityUtils.ensureMinTouchTarget( // Add Semantics and Touch Target
        child: Semantics(
          button: true,
          label: AccessibilityUtils.cancelLabel,
          hint: 'Batalkan perubahan dan kembali',
          onTap: _handleCancel,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: _handleCancel,
            tooltip: 'Batal',
          ),
        ),
      ),
      actions: [
        // Delete button with Semantics and Touch Target
         AccessibilityUtils.ensureMinTouchTarget(
          child: Semantics(
            button: true,
            label: AccessibilityUtils.deleteTaskLabel,
            hint: 'Hapus tugas ini secara permanen',
            onTap: _isLoading ? null : _handleDelete,
            child: IconButton(
              onPressed: _isLoading ? null : _handleDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
              tooltip: 'Hapus Tugas',
            ),
          ),
        ),
        // Save button with Semantics and Touch Target
         AccessibilityUtils.ensureMinTouchTarget(
          child: Semantics(
            button: true,
            label: AccessibilityUtils.getButtonSemantics(
              label: 'Simpan Perubahan',
              isLoading: _isLoading,
              isEnabled: !_isLoading && _hasChanges,
            ),
            onTap: (_isLoading || !_hasChanges) ? null : _handleSave,
            child: Padding(
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
                          semanticsLabel: 'Menyimpan perubahan', // Semantics for loading
                        ),
                      )
                    : Text(
                        'Simpan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            // Change color based on _hasChanges
                            color: _hasChanges
                                ? Colors.white
                                : Colors.white.withOpacity(0.5)),
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
     return AccessibilityUtils.createSemanticWidget( // Add Semantics to body
      label: 'Form edit tugas',
      hint: 'Ubah detail tugas lalu simpan atau hapus tugas',
      child: SingleChildScrollView(
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
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
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
              Icons.edit_note_rounded, // Changed Icon
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
                  'Edit Detail Tugas', // Changed Text
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Perbarui informasi untuk "${widget.task.title}"', // Dynamic title
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

  // --- Form Field Widgets (Similar to AddTaskView, adapted slightly) ---

   /// Build field untuk judul tugas dengan styling modern
  Widget _buildTitleField() {
    return Semantics( // Added Semantics
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
        Semantics( // Added Semantics
          textField: true,
          label: AccessibilityUtils.getFormFieldSemantics(
            label: 'Mata Pelajaran',
            isRequired: true,
            value: _subjectController.text,
            hint: 'Masukkan nama mata pelajaran',
          ),
          child: TextFormField( // Consider using Autocomplete
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
         if (existingSubjects.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Pilih dari yang sudah ada:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColorSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Semantics( // Added Semantics
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
                    _onFormChanged(); // Update changes state
                     AccessibilityUtils.announceMessage('Mata pelajaran $subject dipilih');
                  },
                  backgroundColor: color.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  side: BorderSide(color: color.withOpacity(0.3), width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  avatar: Icon(Icons.school_outlined, size: 16, color: color),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ).asSemanticButton( // Add Semantics as button
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

   /// Get warna untuk mata pelajaran berdasarkan hash
  Color _getSubjectColor(String subject) {
    final hash = subject.hashCode;
    final colors = [
      primaryColor, completedColor, Colors.purple.shade600, pendingColor,
      Colors.teal.shade600, Colors.indigo.shade600, Colors.pink.shade600,
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
        Semantics( // Added Semantics
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
        Semantics( // Added Semantics
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
                    hintText: deadlineText,
                    prefixIcon: Icons.calendar_today_outlined,
                    errorText: _getDeadlineError(),
                  ).copyWith(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: hasError ? accentColorRed : Colors.grey[300]!, width: hasError ? 1.5 : 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: hasError ? accentColorRed : Colors.grey[300]!, width: hasError ? 1.5 : 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: hasError ? accentColorRed : primaryColor, width: 2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        deadlineText,
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDeadline != null
                              ? textColorPrimary
                              : textColorSecondary.withOpacity(0.7),
                        ),
                      ),
                      if (_selectedDeadline != null)
                        Semantics( // Added Semantics for clear button
                          button: true,
                          label: AccessibilityUtils.clearDateLabel,
                          hint: 'Hapus tanggal deadline yang dipilih',
                          onTap: () {
                            setState(() { _selectedDeadline = null; });
                            _onFormChanged(); // Update changes state
                            AccessibilityUtils.announceMessage('Deadline dihapus');
                          },
                          child: IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            color: accentColorRed,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: AccessibilityUtils.clearDateLabel,
                            onPressed: () {
                              setState(() { _selectedDeadline = null; });
                              _onFormChanged(); // Update changes state
                              AccessibilityUtils.announceMessage('Deadline dihapus');
                            },
                          ),
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
            color: primaryColor, // Label color consistent
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

  /// Build decoration dasar untuk TextFormField (konsisten dengan AddTaskView)
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
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      alignLabelWithHint: alignLabelWithHint,
      errorText: errorText,
    );
  }


  /// Build tombol simpan utama dengan gradasi biru
  Widget _buildSaveButton() {
     return AccessibilityUtils.ensureMinTouchTarget( // Add Semantics and Touch Target
      child: Semantics(
        button: true,
        label: AccessibilityUtils.getButtonSemantics(
          label: 'Simpan Perubahan',
          isLoading: _isLoading,
          isEnabled: !_isLoading && _hasChanges,
        ),
        enabled: !_isLoading && _hasChanges,
        onTap: (_isLoading || !_hasChanges) ? null : _handleSave,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: (_isLoading || !_hasChanges)
                  ? [ primaryColor.withOpacity(0.5), primaryColorLight.withOpacity(0.5) ]
                  : [primaryColorLight, primaryColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!_isLoading && _hasChanges) // Only show shadow when enabled
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
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : const Icon(Icons.save_outlined, size: 20, color: Colors.white),
            label: Text(
              _isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      ),
    );
  }

  /// Build tombol delete dengan gradasi merah
  Widget _buildDeleteButton() {
     return AccessibilityUtils.ensureMinTouchTarget( // Add Semantics and Touch Target
      child: Semantics(
        button: true,
        label: AccessibilityUtils.getButtonSemantics(
          label: AccessibilityUtils.deleteTaskLabel,
          isLoading: _isLoading,
          isEnabled: !_isLoading,
        ),
        onTap: _isLoading ? null : _handleDelete,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isLoading
                  ? [ accentColorRedLight.withOpacity(0.5), accentColorRed.withOpacity(0.5) ]
                  : [accentColorRedLight, accentColorRed],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
               if (!_isLoading) // Only show shadow when enabled
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      ),
    );
  }

  /// Build tombol cancel dengan styling modern (outline)
  Widget _buildCancelButton() {
     return AccessibilityUtils.ensureMinTouchTarget( // Add Semantics and Touch Target
      child: Semantics(
        button: true,
        label: AccessibilityUtils.getButtonSemantics(
          label: AccessibilityUtils.cancelLabel,
           isLoading: _isLoading,
           isEnabled: !_isLoading,
        ),
        onTap: _isLoading ? null : _handleCancel,
        child: OutlinedButton.icon(
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
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ),
    );
  }


  /// Handle pemilihan deadline dengan DatePicker bertema
  Future<void> _selectDeadline() async {
    final now = DateTime.now();
    final initialDate = _selectedDeadline ?? widget.task.deadline; // Use current task deadline as initial

     // Ensure initialDate is not before firstDate (now)
    final validInitialDate = initialDate.isBefore(now) ? now : initialDate;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: validInitialDate,
      firstDate: now, // Prevent past dates
      lastDate: now.add(const Duration(days: 365 * 2)),
      helpText: 'Pilih Tanggal Deadline',
      cancelText: 'Batal',
      confirmText: 'Pilih Waktu',
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
      final TimeOfDay initialTime = TimeOfDay.fromDateTime(_selectedDeadline ?? widget.task.deadline);

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
                    surface: cardColor,
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
        final newDeadline = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        // Only update state if the deadline actually changed
        if (newDeadline != _selectedDeadline) {
          setState(() {
            _selectedDeadline = newDeadline;
          });
          _checkForChanges(); // Check for changes after selecting deadline
           AccessibilityUtils.announceMessage('Deadline diubah menjadi ${_formatDeadline(newDeadline)}');
        }
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
      return DateFormat('dd MMM yyyy, HH:mm').format(deadline);
    }
  }

  /// Get error message untuk deadline
  String? _getDeadlineError() {
     if (_selectedDeadline == null) return null; // Validation happens in _validateForm
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
      setState(() {});
       _showErrorSnackbar('Deadline harus dipilih');
    } else if (_getDeadlineError() != null) {
      isDeadlineValid = false;
      _showErrorSnackbar(_getDeadlineError()!);
    }

    if (!isFormValid || !isDeadlineValid) {
       AccessibilityUtils.announceMessage('Validasi gagal. Periksa isian form.');
      return false;
    }
    return true;
  }

  /// Handle save perubahan tugas
  Future<void> _handleSave() async {
     // Hide keyboard
    FocusScope.of(context).unfocus();

    if (!_hasChanges) {
       _showInfoSnackbar('Tidak ada perubahan untuk disimpan.');
       return;
    }
     if (!_validateForm()) {
      return;
    }


    setState(() { _isLoading = true; });

    try {
      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subject: _subjectController.text.trim(),
        deadline: _selectedDeadline!,
        updatedAt: DateTime.now(), // Update timestamp
      );

      final taskController = Get.find<TaskController>();
      final success = await taskController.updateTask(updatedTask);

      if (success) {
        _showSuccessSnackbar('Tugas "${updatedTask.title}" berhasil diperbarui');
         AccessibilityUtils.announceMessage('Tugas berhasil diperbarui');
        Get.offAllNamed(AppRoutes.home);
      } else {
        final errorMsg = taskController.errorMessage.isNotEmpty
            ? taskController.errorMessage
            : 'Gagal memperbarui tugas. Coba lagi.';
        _showErrorSnackbar(errorMsg);
         AccessibilityUtils.announceMessage('Gagal menyimpan perubahan: $errorMsg');
      }
    } catch (e) {
      final errorMsg = 'Terjadi kesalahan tidak terduga: ${e.toString()}';
      _showErrorSnackbar(errorMsg);
       AccessibilityUtils.announceMessage('Error saat menyimpan: $errorMsg');
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  /// Handle delete tugas dengan konfirmasi
  Future<void> _handleDelete() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    setState(() { _isLoading = true; });

    try {
      final taskController = Get.find<TaskController>();
      final success = await taskController.deleteTask(widget.task.id);

      if (success) {
        _showSuccessSnackbar('Tugas "${widget.task.title}" berhasil dihapus');
         AccessibilityUtils.announceMessage('Tugas berhasil dihapus');
        Get.offAllNamed(AppRoutes.home);
      } else {
         final errorMsg = taskController.errorMessage.isNotEmpty
            ? taskController.errorMessage
            : 'Gagal menghapus tugas. Coba lagi.';
        _showErrorSnackbar(errorMsg);
        AccessibilityUtils.announceMessage('Gagal menghapus tugas: $errorMsg');
      }
    } catch (e) {
       final errorMsg = 'Terjadi kesalahan tidak terduga: ${e.toString()}';
      _showErrorSnackbar(errorMsg);
      AccessibilityUtils.announceMessage('Error saat menghapus: $errorMsg');
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  /// Handle cancel dengan konfirmasi jika ada perubahan
  void _handleCancel() {
     // Hide keyboard
    FocusScope.of(context).unfocus();

    if (_hasChanges && !_isLoading) {
      _showCancelConfirmation();
    } else if (!_isLoading){
       AccessibilityUtils.announceMessage('Membatalkan edit tugas');
      Get.offAllNamed(AppRoutes.home);
    }
  }

  /// Tampilkan dialog konfirmasi delete
  Future<bool> _showDeleteConfirmation() async {
     AccessibilityUtils.announceMessage('Dialog konfirmasi hapus tugas');
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [ Icon(Icons.warning_amber_rounded, color: accentColorRed), SizedBox(width: 8), Text('Hapus Tugas?') ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menghapus tugas ini secara permanen?'),
            const SizedBox(height: 12),
            Text('"${widget.task.title}"', style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('(${widget.task.subject})', style: TextStyle(color: textColorSecondary, fontSize: 14)),
            const SizedBox(height: 12),
            const Text('Tindakan ini tidak dapat dibatalkan.', style: TextStyle(color: accentColorRed, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal', style: TextStyle(color: textColorSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ya, Hapus'),
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
              AccessibilityUtils.announceMessage('Perubahan dibatalkan');
              Get.offAllNamed(AppRoutes.home); // Kembali ke home
            },
            child: const Text('Ya, Batalkan', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  // --- Snackbar Helper Functions ---
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Berhasil', message,
      snackPosition: SnackPosition.BOTTOM, backgroundColor: completedColor,
      colorText: Colors.white, icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      margin: const EdgeInsets.all(16), borderRadius: 12, duration: const Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error', message,
      snackPosition: SnackPosition.BOTTOM, backgroundColor: accentColorRed,
      colorText: Colors.white, icon: const Icon(Icons.error_outline, color: Colors.white),
      margin: const EdgeInsets.all(16), borderRadius: 12, duration: const Duration(seconds: 4),
    );
  }
   void _showInfoSnackbar(String message) {
    Get.snackbar(
      'Info', message,
      snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blueGrey,
      colorText: Colors.white, icon: const Icon(Icons.info_outline, color: Colors.white),
      margin: const EdgeInsets.all(16), borderRadius: 12, duration: const Duration(seconds: 3),
    );
  }
}
