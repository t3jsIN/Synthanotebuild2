import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'models.dart';

// Note Detail Screen
class NoteDetailScreen extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;

  const NoteDetailScreen({
    super.key,
    required this.note,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFFB0B0B0),
                      size: 20,
                    ),
                  ),
                  Text(
                    _getNoteTypeDisplayName(note.type),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF8F8F8),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _exportNote(note),
                        child: const Icon(
                          Icons.share_outlined,
                          color: Color(0xFFD4AF37),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _showDeleteConfirmation(context),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFFF6B6B),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5C97E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF121212),
                        ),
                      ),
                    ),
                    if (note.shortDescription.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          note.shortDescription,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFB0B0B0),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                    if (note.inspiration?.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3C3C3C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Inspiration:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              note.inspiration!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFF8F8F8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (note.type == NoteType.music &&
                        note.musicSections != null) ...[
                      for (int i = 0; i < note.musicSections!.length; i++) ...[
                        _buildMusicSectionCard(note.musicSections![i], i),
                        const SizedBox(height: 12),
                      ],
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SelectableText(
                          note.content,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFF8F8F8),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicSectionCard(MusicSection section, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5C97E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  section.type.toLowerCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF8F8F8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '* ${section.subtitle} *',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF121212),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          if (section.content.isNotEmpty) ...[
            const SizedBox(height: 12),
            SelectableText(
              section.content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF121212),
                height: 1.4,
              ),
            ),
          ],
          if (section.voiceNotes?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF121212), thickness: 1),
            const SizedBox(height: 8),
            const Text(
              'Voice Notes:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF121212),
              ),
            ),
            const SizedBox(height: 8),
            ...section.voiceNotes!.map(
              (voiceNote) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.play_circle_outline,
                      color: Color(0xFF90EE90),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voiceNote.title,
                            style: const TextStyle(
                              color: Color(0xFFF8F8F8),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(voiceNote.durationMs),
                            style: const TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    Duration duration = Duration(milliseconds: milliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  String _getNoteTypeDisplayName(NoteType type) {
    switch (type) {
      case NoteType.music:
        return 'ID Hub';
      case NoteType.mixtip:
        return 'MixBook';
      case NoteType.quick:
        return 'QuickNote';
    }
  }

  void _exportNote(Note note) async {
    String exportText = '';
    if (note.type == NoteType.quick || note.type == NoteType.mixtip) {
      exportText = '${note.title}\n${note.shortDescription}\n\n${note.content}';
    } else {
      exportText = '${note.title}\n${note.shortDescription}';
      if (note.inspiration?.isNotEmpty == true) {
        exportText += '\nInspiration: ${note.inspiration}';
      }
      for (var section in note.musicSections ?? []) {
        exportText +=
            '\n\n${section.type}\n> ${section.subtitle}\n> ${section.content}';
      }
    }
    Share.share(exportText, subject: note.title);
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: const Text(
            'Delete Note',
            style: TextStyle(color: Color(0xFFF8F8F8)),
          ),
          content: const Text(
            'Are you sure you want to delete this note? This action cannot be undone.',
            style: TextStyle(color: Color(0xFFB0B0B0)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFB0B0B0)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                onDelete();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFFF6B6B)),
              ),
            ),
          ],
        );
      },
    );
  }
}
