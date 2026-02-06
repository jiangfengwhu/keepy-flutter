
enum DataFieldType {
  text,
  number,
  date,
  checkbox;

  String get displayName {
    switch (this) {
      case DataFieldType.text:
        return '文本';
      case DataFieldType.number:
        return '数字';
      case DataFieldType.date:
        return '日期';
      case DataFieldType.checkbox:
        return '选项';
    }
  }
}

class DataFieldDefinition {
  final String id;
  String name;
  DataFieldType type;
  String description;

  DataFieldDefinition({
    String? id,
    required this.name,
    required this.type,
    this.description = '',
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();
}

class Notebook {
  String name;
  String description;
  List<DataFieldDefinition> structure;

  Notebook({
    required this.name,
    this.description = '',
    List<DataFieldDefinition>? structure,
  }) : structure = structure ?? [];
}
