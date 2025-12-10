enum FieldType { paragraph, singleLine, dropdown, fileUpload, dates, multiple }

class QuestionField {
  String id;
  String label;          // displayed field label e.g., "Start Date"
  FieldType type;
  String variableName;   // system key
  String placeholder;
  List<String> options;  // for dropdown / multiple
  QuestionField({
    required this.id,
    required this.label,
    required this.type,
    this.variableName = '',
    this.placeholder = '',
    List<String>? options,
  }) : options = options ?? [];

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'label': label,
      'variable': variableName,
      'placeholder': placeholder,
      'options': options,
    };
  }
}
