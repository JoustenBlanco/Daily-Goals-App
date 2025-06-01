class Task {
  String? id;
  String name;
  int complete;
  String userId;
  bool remote;
  bool to_delete;

  Task({
    this.id,
    required this.name,
    this.complete = 0,
    required this.userId,
    this.remote = false,
    this.to_delete = false
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final completeValue = json['complete'];

    int completeInt;
    if (completeValue is bool) {
      completeInt = completeValue ? 1 : 0;
    } else if (completeValue is int) {
      completeInt = completeValue;
    } else {
      completeInt = 0; 
    }

    return Task(
      id: json['id'],
      name: json['name'] as String,
      complete: completeInt,
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'complete': complete,
      'user_id': userId,
      'remote': remote ? 1 : 0,
      'to_delete': to_delete ? 1 : 0,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      complete: map['complete'] ?? 0,
      userId: map['user_id'] ?? 0,
      remote: (map['remote'] ?? 0) == 1,
      to_delete: (map['to_delete'] ?? 0) == 1,
    );
  }
}