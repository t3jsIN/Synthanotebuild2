import 'package:flutter/material.dart';

// Data Models
enum NoteType { quick, music, mixtip }

class Note {
  final String id;
  final String title;
  final String shortDescription;
  final String? inspiration;
  final String content;
  final NoteType type;
  final String preview;
  final List<MusicSection>? musicSections;

  Note({
    String? id,
    required this.title,
    required this.shortDescription,
    this.inspiration,
    required this.content,
    required this.type,
    required this.preview,
    this.musicSections,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'shortDescription': shortDescription,
        'inspiration': inspiration,
        'content': content,
        'type': type.index,
        'preview': preview,
        'musicSections': musicSections?.map((s) => s.toJson()).toList(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] ?? 'Untitled',
        shortDescription: json['shortDescription'] ?? '',
        inspiration: json['inspiration'],
        content: json['content'] ?? '',
        type: NoteType.values[json['type'] ?? 0],
        preview: json['preview'] ?? '',
        musicSections: (json['musicSections'] as List?)
            ?.map((s) => MusicSection.fromJson(s))
            .toList(),
      );
}

class MusicSection {
  final String type;
  final String subtitle;
  final String content;
  final List<VoiceNote>? voiceNotes;

  MusicSection({
    required this.type,
    required this.subtitle,
    required this.content,
    this.voiceNotes,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'subtitle': subtitle,
        'content': content,
        'voiceNotes': voiceNotes?.map((v) => v.toJson()).toList(),
      };

  factory MusicSection.fromJson(Map<String, dynamic> json) => MusicSection(
        type: json['type'] ?? 'Untitled',
        subtitle: json['subtitle'] ?? '',
        content: json['content'] ?? '',
        voiceNotes: (json['voiceNotes'] as List?)
            ?.map((v) => VoiceNote.fromJson(v))
            .toList(),
      );

  MusicSection copyWith({
    String? type,
    String? subtitle,
    String? content,
    List<VoiceNote>? voiceNotes,
  }) {
    return MusicSection(
      type: type ?? this.type,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      voiceNotes: voiceNotes ?? this.voiceNotes,
    );
  }
}

class VoiceNote {
  final String id;
  final String filePath;
  final String title;
  final DateTime createdAt;
  final int durationMs;

  VoiceNote({
    required this.id,
    required this.filePath,
    required this.title,
    required this.createdAt,
    required this.durationMs,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'filePath': filePath,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'durationMs': durationMs,
      };

  factory VoiceNote.fromJson(Map<String, dynamic> json) => VoiceNote(
        id: json['id'] ?? '',
        filePath: json['filePath'] ?? '',
        title: json['title'] ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        durationMs: json['durationMs'] ?? 0,
      );
}

class MusicSectionController {
  final MusicSection section;
  final TextEditingController textController;
  final List<VoiceNote> voiceNotes;

  MusicSectionController({
    required this.section,
  })  : textController = TextEditingController(text: section.content),
        voiceNotes = List.from(section.voiceNotes ?? []);

  void dispose() {
    textController.dispose();
  }

  MusicSection getUpdatedSection() {
    return section.copyWith(
      content: textController.text,
      voiceNotes: voiceNotes,
    );
  }

  void addVoiceNote(VoiceNote voiceNote) {
    voiceNotes.add(voiceNote);
  }

  void removeVoiceNote(String id) {
    voiceNotes.removeWhere((note) => note.id == id);
  }
}
