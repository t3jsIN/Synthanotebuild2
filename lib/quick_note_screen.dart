import 'package:flutter/material.dart';
import 'models.dart';

// Quick Note Screen - iOS Optimized
class QuickNoteScreen extends StatefulWidget {
  final String title;
  final String shortDescription;
  final String? inspiration;
  final Function(String, String, String?, String, List<MusicSection>?) onSave;

  const QuickNoteScreen({
    super.key,
    required this.title,
    required this.shortDescription,
    this.inspiration,
    required this.onSave,
  });

  @override
  State<QuickNoteScreen> createState() => _QuickNoteScreenState();
}

class _QuickNoteScreenState extends State<QuickNoteScreen> {
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SizedBox(
          width: 380,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
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
                    const Text(
                      'Quick Note',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF8F8F8),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final content = _contentController.text.trim();
                        if (content.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please add some content before saving'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        // Save the note
                        widget.onSave(
                          widget.title.isEmpty ? 'Untitled' : widget.title,
                          widget.shortDescription,
                          widget.inspiration,
                          content,
                          null,
                        );

                        // Navigate back to home
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFF8F8F8),
                        height: 1.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Start typing your thoughts...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Color(0xFFB0B0B0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
