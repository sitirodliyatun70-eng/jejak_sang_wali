class QuizModel {
  final int level;
  final String soal;
  final List<String> opsi;
  final int jawaban;
  final String tipe;

  QuizModel({
    required this.level,
    required this.soal,
    required this.opsi,
    required this.jawaban,
    required this.tipe,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      level: json['level'],
      soal: json['soal'],
      opsi: List<String>.from(json['opsi']),
      jawaban: json['jawaban'],
      tipe: json['tipe'],
    );
  }
}
