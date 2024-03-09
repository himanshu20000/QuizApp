class Question {
  final String question;
  final Map<String, String> options;
  final String correctOption;

  Question({
    required this.question,
    required this.options,
    required this.correctOption,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final String question = json['question'] ?? '';
    final String correctOption = json['correctOption'] ?? '';
    final Map<String, dynamic> optionsMap = json['options'] ?? {};

    // Extract options from the nested map
    Map<String, String> options = {};
    optionsMap.forEach((key, value) {
      if (value is String) {
        options[key] = value;
      }
    });

    return Question(
      question: question,
      options: options,
      correctOption: correctOption,
    );
  }
}
