import 'database_service.dart';

/// AI 助手性格设定（存储在本地 kv_store）
class AssistantPersonaService {
  static const _kAssistantPersonaKey = 'assistant_persona';

  final DatabaseService _db = DatabaseService();

  Future<String> getPersona() async {
    return (await _db.getKv(_kAssistantPersonaKey))?.trim() ?? '';
  }

  Future<void> setPersona(String persona) async {
    await _db.setKv(_kAssistantPersonaKey, persona.trim());
  }
}
