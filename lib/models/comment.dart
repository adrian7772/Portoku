class Comment {
  final String id;
  final String videoId;
  final String author;
  final String message;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.videoId,
    required this.author,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'videoId': videoId,
    'author': author,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
  };

  static Comment fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'] as String,
    videoId: json['videoId'] as String,
    author: json['author'] as String,
    message: json['message'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
