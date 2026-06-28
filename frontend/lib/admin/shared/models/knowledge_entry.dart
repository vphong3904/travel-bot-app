// lib/admin/shared/models/knowledge_entry.dart

class KnowledgeEntry {
  final String id;
  final String title;
  final String content;
  final String? category;
  final List<String> tags;
  final String? source;
  final bool isActive;
  final String? qdrantId;
  final String? embeddingStatus; // "pending"|"done"|"error"|"not_embedded"
  final String? embeddingJobId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KnowledgeEntry({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    required this.tags,
    this.source,
    required this.isActive,
    this.qdrantId,
    this.embeddingStatus,
    this.embeddingJobId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KnowledgeEntry.fromJson(Map<String, dynamic> json) =>
      KnowledgeEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        category: json['category'] as String?,
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        source: json['source'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        qdrantId: json['qdrant_id'] as String?,
        embeddingStatus: json['embedding_status'] as String?,
        embeddingJobId: json['embedding_job_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}
