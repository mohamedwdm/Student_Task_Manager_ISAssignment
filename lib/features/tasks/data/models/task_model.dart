class TaskModel {
  final int? id;
  final int userId;
  final String title;
  final String? description;
  final String dueDate;
  final String priority;
  final bool isCompleted;
  final bool isSynced;
  final String? syncAction;

  TaskModel({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    this.isSynced = true,
    this.syncAction,
  });

  TaskModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? dueDate,
    String? priority,
    bool? isCompleted,
    bool? isSynced,
    String? syncAction,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      isSynced: isSynced ?? this.isSynced,
      syncAction: syncAction ?? this.syncAction,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['due_date'] as String,
      priority: map['priority'] as String,
      isCompleted: map['is_completed'] == 1 || map['is_completed'] == true,
      isSynced: (map['is_synced'] ?? 1) == 1,
      syncAction: map['sync_action'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'priority': priority,
      'is_completed': isCompleted ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
      'sync_action': syncAction,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
