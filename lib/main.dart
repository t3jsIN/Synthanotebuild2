// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Import all the other files
import 'models.dart';
import 'note_detail_screen.dart';
import 'initial_note_screen.dart';
import 'quick_note_screen.dart';
import 'music_note_screen.dart';
import 'mixtip_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set iOS status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(const SyntanoteApp());
}

class SyntanoteApp extends StatelessWidget {
  const SyntanoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syntanote',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  NoteType? selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getStringList('notes') ?? [];
      setState(() {
        notes = notesJson
            .map((noteStr) {
              try {
                return Note.fromJson(jsonDecode(noteStr));
              } catch (e) {
                return null;
              }
            })
            .where((note) => note != null)
            .cast<Note>()
            .toList();
        _applyFilters();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading notes. Please restart the app.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = notes.map((note) => jsonEncode(note.toJson())).toList();
      final success = await prefs.setStringList('notes', notesJson);
      if (!success) {
        throw Exception('SharedPreferences setStringList returned false');
      }
      await prefs.reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      filteredNotes = notes.where((note) {
        if (selectedFilter != null && note.type != selectedFilter) {
          return false;
        }

        if (_searchController.text.isNotEmpty) {
          String searchTerm = _searchController.text.toLowerCase();
          return note.title.toLowerCase().contains(searchTerm) ||
              note.shortDescription.toLowerCase().contains(searchTerm) ||
              note.content.toLowerCase().contains(searchTerm) ||
              (note.musicSections?.any((section) =>
                      section.type.toLowerCase().contains(searchTerm) ||
                      section.content.toLowerCase().contains(searchTerm)) ??
                  false);
        }

        return true;
      }).toList();
    });
  }

  void _deleteNote(int index) {
    if (index >= 0 && index < filteredNotes.length) {
      setState(() {
        Note noteToDelete = filteredNotes[index];
        notes.removeWhere((note) => note.id == noteToDelete.id);
        _applyFilters();
      });
      _saveNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              decoration: const BoxDecoration(
                color: Color(0xFF121212),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF2C2C2C),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Date and Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getCurrentDate(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB0B0B0),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'synthanote',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF8F8F8),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Color(0xFFF8F8F8)),
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFB0B0B0),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {});
                                _debounceTimer?.cancel();
                                _applyFilters();
                              },
                              child: const Icon(
                                Icons.clear,
                                color: Color(0xFFB0B0B0),
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFF5C97E),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      _debounceTimer?.cancel();
                      _debounceTimer = Timer(
                        const Duration(milliseconds: 300),
                        () => _applyFilters(),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('All', null),
                        const SizedBox(width: 8),
                        _buildFilterChip('ID Hub', NoteType.music),
                        const SizedBox(width: 8),
                        _buildFilterChip('MixBook', NoteType.mixtip),
                        const SizedBox(width: 8),
                        _buildFilterChip('QuickNote', NoteType.quick),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'ID Hub',
                      Icons.music_note_outlined,
                      () => _createMusicNote(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      'MixBook',
                      Icons.tune_outlined,
                      () => _createMixTip(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      'QuickNote',
                      Icons.edit_outlined,
                      () => _createQuickNote(),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Notes Section
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5C97E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildNotesContent(),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper method to build notes content
  Widget _buildNotesContent() {
    if (filteredNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchController.text.isNotEmpty || selectedFilter != null
                  ? Icons.search_off
                  : Icons.note_add_outlined,
              color: const Color(0xFF121212),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty || selectedFilter != null
                  ? 'No matching notes found'
                  : 'No notes yet',
              style: const TextStyle(
                color: Color(0xFF121212),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_searchController.text.isNotEmpty ||
                selectedFilter != null) ...[
              const SizedBox(height: 8),
              const Text(
                'Try adjusting your search or filters',
                style: TextStyle(
                  color: Color(0xFF121212),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        return _buildNoteCard(filteredNotes[index], index);
      },
    );
  }

  Widget _buildFilterChip(String label, NoteType? type) {
    bool isSelected = selectedFilter == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = isSelected ? null : type;
        });
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5C97E) : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFF5C97E) : const Color(0xFF3C3C3C),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color:
                isSelected ? const Color(0xFF121212) : const Color(0xFFB0B0B0),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFC7A144),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF121212),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                NoteDetailScreen(
              note: note,
              onDelete: () => _deleteNote(index),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeInOutCubic)),
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getNoteTypeColor(note.type),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getNoteTypeLabel(note.type),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF121212),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _exportNote(note),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      color: Color(0xFFD4AF37),
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF8F8F8),
              ),
            ),
            if (note.shortDescription.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                note.shortDescription,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFB0B0B0),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              note.preview,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFB0B0B0),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getNoteTypeColor(NoteType type) {
    switch (type) {
      case NoteType.music:
        return const Color(0xFF90EE90);
      case NoteType.mixtip:
        return const Color(0xFF87CEEB);
      case NoteType.quick:
        return const Color(0xFFFFB6C1);
    }
  }

  String _getNoteTypeLabel(NoteType type) {
    switch (type) {
      case NoteType.music:
        return 'ID HUB';
      case NoteType.mixtip:
        return 'MIX';
      case NoteType.quick:
        return 'QUICK';
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}';
  }

  void _createQuickNote() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            InitialNoteScreen(
          isMusic: false,
          onSave: (title, shortDesc, inspiration, content, sections) {
            setState(() {
              notes.insert(
                  0,
                  Note(
                    title: title,
                    shortDescription: shortDesc,
                    inspiration: inspiration,
                    content: content,
                    type: NoteType.quick,
                    preview: content.length > 80
                        ? '${content.substring(0, 80)}...'
                        : content,
                  ));
            });
            _applyFilters();
            _saveNotes();
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOutCubic)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _createMusicNote() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            InitialNoteScreen(
          isMusic: true,
          onSave: (title, shortDesc, inspiration, content, sections) {
            String preview = sections?.isNotEmpty == true
                ? sections!.first.content
                : 'Empty music note';
            setState(() {
              notes.insert(
                  0,
                  Note(
                    title: title,
                    shortDescription: shortDesc,
                    inspiration: inspiration,
                    content: content,
                    type: NoteType.music,
                    preview: preview.length > 80
                        ? '${preview.substring(0, 80)}...'
                        : preview,
                    musicSections: sections,
                  ));
            });
            _applyFilters();
            _saveNotes();
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOutCubic)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _createMixTip() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MixTipScreen(
          onSave: (title, shortDesc, content) {
            setState(() {
              notes.insert(
                  0,
                  Note(
                    title: title,
                    shortDescription: shortDesc,
                    inspiration: null,
                    content: content,
                    type: NoteType.mixtip,
                    preview: content.length > 80
                        ? '${content.substring(0, 80)}...'
                        : content,
                  ));
            });
            _applyFilters();
            _saveNotes();
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOutCubic)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
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
}
