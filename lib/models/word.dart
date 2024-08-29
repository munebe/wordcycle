class Word {
  int? id;
  String title;
  String type;
  String mean;
  String? example1;
  String? example2;
  bool isLearned;
  int correctCount;
  DateTime? createdAt;

  Word({
    this.id,
    required this.title,
    required this.type,
    required this.mean,
    this.example1,
    this.example2,
    this.isLearned = false, // Varsayılan değer false
    this.correctCount = 0, // Varsayılan değer 0
    this.createdAt,
  });

  // Supabase'den gelen verileri Word nesnesine dönüştürmek için
  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as int?,
      title: map['title'] as String,
      type: map['type'] as String,
      mean: map['mean'] as String,
      example1: map['example1'] as String?,
      example2: map['example2'] as String?,
      isLearned: map['isLearned'] as bool? ?? false, // Null ise false yap
      correctCount: map['correctCount'] as int? ?? 0, // Null ise 0 yap
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  // Word nesnesini Map formatına dönüştürmek için (Supabase'e veri eklemek için)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'mean': mean,
      'example1': example1,
      'example2': example2,
      'isLearned': isLearned,
      'correctCount': correctCount,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
