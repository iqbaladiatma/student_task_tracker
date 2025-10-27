# Design Document

## Overview

Student Task Tracker adalah aplikasi Flutter yang menggunakan arsitektur MVC (Model-View-Controller) dengan penyimpanan lokal menggunakan Hive. Aplikasi ini dirancang untuk memberikan pengalaman pengguna yang sederhana dan intuitif dalam mengelola tugas sekolah dengan performa yang optimal.

## Architecture

### Arsitektur Aplikasi
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      Views      │    │   Controllers   │    │     Models      │
│   (UI Widgets)  │◄──►│  (Business      │◄──►│  (Data Models)  │
│                 │    │   Logic)        │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │    Services     │
                    │ (Data Storage)  │
                    └─────────────────┘
```

### Struktur Direktori
```
lib/
├── main.dart
├── models/
│   └── task.dart
├── controllers/
│   └── task_controller.dart
├── services/
│   └── storage_service.dart
├── views/
│   ├── home_view.dart
│   ├── add_task_view.dart
│   └── edit_task_view.dart
├── widgets/
│   ├── task_card.dart
│   └── filter_chips.dart
└── utils/
    └── constants.dart
```

## Components and Interfaces

### 1. Model Layer

#### Task Model
```dart
@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  String subject;
  
  @HiveField(4)
  DateTime deadline;
  
  @HiveField(5)
  bool isCompleted;
  
  @HiveField(6)
  DateTime createdAt;
  
  @HiveField(7)
  DateTime updatedAt;
}
```

### 2. Service Layer

#### StorageService Interface
```dart
abstract class StorageService {
  Future<void> initialize();
  Future<List<Task>> getAllTasks();
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<void> toggleTaskStatus(String taskId);
}
```

#### HiveStorageService Implementation
- Menggunakan Hive untuk penyimpanan lokal yang cepat
- Implementasi CRUD operations untuk Task
- Error handling untuk operasi database
- Automatic backup dan recovery

### 3. Controller Layer

#### TaskController
```dart
class TaskController extends GetxController {
  // Observable lists untuk reactive UI
  RxList<Task> allTasks = <Task>[].obs;
  RxList<Task> filteredTasks = <Task>[].obs;
  Rx<TaskFilter> currentFilter = TaskFilter.all.obs;
  RxBool isLoading = false.obs;
  
  // CRUD operations
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<void> toggleTaskStatus(String taskId);
  
  // Filter operations
  void setFilter(TaskFilter filter);
  void applyFilter();
  
  // Search functionality
  void searchTasks(String query);
}
```

### 4. View Layer

#### HomeView
- Menampilkan daftar tugas dengan filter
- FloatingActionButton untuk menambah tugas
- AppBar dengan search functionality
- Filter chips untuk status tugas
- Empty state ketika tidak ada tugas

#### AddTaskView
- Form untuk input tugas baru
- Validasi input fields
- Date picker untuk deadline
- Dropdown untuk mata pelajaran
- Save dan Cancel buttons

#### EditTaskView
- Form pre-filled dengan data tugas existing
- Sama seperti AddTaskView tapi untuk editing
- Delete option dengan konfirmasi

### 5. Widget Layer

#### TaskCard
- Card widget untuk menampilkan informasi tugas
- Checkbox untuk toggle status
- Visual indicator untuk status (completed/pending)
- Swipe actions untuk edit/delete
- Color coding berdasarkan deadline proximity

#### FilterChips
- Chip widgets untuk filter (All, Pending, Completed)
- Active state indication
- Smooth animations

## Data Models

### Task Entity
```dart
class Task {
  String id;              // UUID untuk unique identification
  String title;           // Judul tugas (required, max 100 chars)
  String description;     // Deskripsi detail (optional, max 500 chars)
  String subject;         // Mata pelajaran (required)
  DateTime deadline;      // Tanggal deadline (required)
  bool isCompleted;       // Status completion (default: false)
  DateTime createdAt;     // Timestamp creation
  DateTime updatedAt;     // Timestamp last update
  
  // Computed properties
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(deadline);
  bool get isDueSoon => !isCompleted && deadline.difference(DateTime.now()).inDays <= 1;
}
```

### TaskFilter Enum
```dart
enum TaskFilter {
  all,        // Semua tugas
  pending,    // Tugas belum selesai
  completed,  // Tugas selesai
  overdue     // Tugas terlambat (bonus feature)
}
```

### Subject Model (Optional Enhancement)
```dart
class Subject {
  String name;
  Color color;
  IconData icon;
}
```

## Error Handling

### Storage Error Handling
1. **Database Initialization Errors**
   - Fallback ke SharedPreferences jika Hive gagal
   - User notification dengan retry option
   - Logging untuk debugging

2. **CRUD Operation Errors**
   - Rollback mechanism untuk failed operations
   - User-friendly error messages
   - Automatic retry untuk network-related issues

3. **Data Corruption Handling**
   - Data validation sebelum save
   - Backup mechanism
   - Recovery dari corrupted data

### UI Error Handling
1. **Form Validation Errors**
   - Real-time validation feedback
   - Clear error messages
   - Field highlighting

2. **Network/Storage Errors**
   - Snackbar notifications
   - Retry mechanisms
   - Offline mode indicators

## Testing Strategy

### Unit Tests
1. **Model Tests**
   - Task model validation
   - Date calculations (isOverdue, isDueSoon)
   - Serialization/deserialization

2. **Service Tests**
   - StorageService CRUD operations
   - Error handling scenarios
   - Data persistence verification

3. **Controller Tests**
   - Business logic validation
   - Filter functionality
   - State management

### Widget Tests
1. **View Tests**
   - UI rendering dengan different states
   - User interaction testing
   - Navigation testing

2. **Widget Tests**
   - TaskCard behavior
   - FilterChips functionality
   - Form validation

### Integration Tests
1. **End-to-End Scenarios**
   - Complete task lifecycle (add → edit → complete → delete)
   - Filter dan search functionality
   - Data persistence across app restarts

## Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6              # State management
  hive: ^2.2.3             # Local database
  hive_flutter: ^1.1.0     # Hive Flutter integration
  uuid: ^4.1.0             # UUID generation
  intl: ^0.19.0            # Date formatting

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1   # Code generation untuk Hive
  build_runner: ^2.4.7     # Build system
  mockito: ^5.4.2          # Mocking untuk tests
```

## Performance Considerations

### Database Optimization
- Hive boxes untuk efficient data access
- Lazy loading untuk large datasets
- Indexing untuk search operations
- Periodic cleanup untuk deleted items

### UI Optimization
- ListView.builder untuk efficient scrolling
- Cached network images jika ada
- Debounced search untuk better performance
- Minimal rebuilds dengan GetX reactive programming

### Memory Management
- Proper disposal dari controllers
- Stream subscription cleanup
- Image caching strategies
- Background task management

## Security Considerations

### Data Protection
- Local data encryption dengan Hive encryption
- Input sanitization untuk XSS prevention
- Secure storage untuk sensitive data
- Data backup encryption

### Privacy
- No external data transmission
- Local-only data storage
- User consent untuk data usage
- Clear data deletion policies

## Accessibility

### Screen Reader Support
- Semantic labels untuk semua interactive elements
- Proper heading hierarchy
- Alternative text untuk icons
- Focus management

### Visual Accessibility
- High contrast color schemes
- Scalable text sizes
- Color-blind friendly design
- Touch target sizing (minimum 44px)

### Motor Accessibility
- Large touch targets
- Swipe alternatives
- Voice input support
- Keyboard navigation support