class Task {
  final int? id;
  String name;
  int complete;

  Task({
    this.id,
    required this.name,
    this.complete = 0,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int?,
      name: json['name'] as String,
      complete: json['complete'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'complete': complete,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      complete: map['complete'] ?? 0,
    );
  }
}