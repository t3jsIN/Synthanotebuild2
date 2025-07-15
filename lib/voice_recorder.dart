import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'models.dart';

// Voice Recorder Widget
class VoiceRecorderWidget extends StatefulWidget {
  final Function(VoiceNote) onVoiceNoteSaved;

  const VoiceRecorderWidget({
    super.key,
    required this.onVoiceNoteSaved,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final Directory voiceDir = Directory('${appDocDir.path}/voice_notes');
        if (!await voiceDir.exists()) {
          await voiceDir.create(recursive: true);
        }

        final String timestamp =
            DateTime.now().millisecondsSinceEpoch.toString();
        final String filePath = '${voiceDir.path}/voice_$timestamp.m4a';

        print('🎤 Recording to: $filePath');

        await _audioRecorder.start(
            RecordConfig(
              encoder: AudioEncoder.aacLc,
              bitRate: 128000,
              sampleRate: 44100,
            ),
            path: filePath);
        setState(() {
          _isRecording = true;
          _recordingPath = filePath;
          _recordingDuration = Duration.zero;
        });

        _startDurationTimer();
      } else {
        throw Exception('Microphone permission denied');
      }
    } catch (e) {
      print('✗ Recording error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recording failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startDurationTimer() {
    Future.doWhile(() async {
      if (!_isRecording) return false;

      setState(() {
        _recordingDuration =
            _recordingDuration + const Duration(milliseconds: 100);
      });

      await Future.delayed(const Duration(milliseconds: 100));
      return _isRecording;
    });
  }

  Future<void> _stopRecording() async {
    try {
      final String? path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });

      if (path != null) {
        _showSaveDialog();
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _playRecording() async {
    if (_recordingPath != null && !_isDisposed) {
      try {
        if (kDebugMode) {
          print('🎵 Playing audio...');
        }
        if (_isPlaying) {
          await _audioPlayer.stop();
          if (!_isDisposed) {
            setState(() {
              _isPlaying = false;
            });
          }
        } else {
          final file = File(_recordingPath!);
          if (await file.exists()) {
            await _audioPlayer.play(DeviceFileSource(_recordingPath!));

            if (!_isDisposed) {
              setState(() {
                _isPlaying = true;
              });

              _audioPlayer.onPlayerComplete.listen((_) {
                if (mounted && !_isDisposed) {
                  setState(() {
                    _isPlaying = false;
                  });
                }
              });
            }
          } else {
            throw Exception('Audio file not found at: $_recordingPath');
          }
        }
      } catch (e) {
        print('✗ Playback error: $e');
        if (mounted && !_isDisposed) {
          setState(() {
            _isPlaying = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Playback failed. Try recording again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showSaveDialog() {
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Save Voice Note',
          style: TextStyle(color: Color(0xFFF8F8F8)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Color(0xFFF8F8F8)),
              decoration: const InputDecoration(
                hintText: 'Enter voice note title...',
                hintStyle: TextStyle(color: Color(0xFFB0B0B0)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3C3C3C)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFF5C97E)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Duration: ${_formatDuration(_recordingDuration)}',
              style: const TextStyle(color: Color(0xFFB0B0B0)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_recordingPath != null) {
                File(_recordingPath!).deleteSync();
              }
              Navigator.pop(context);
              setState(() {
                _recordingPath = null;
                _recordingDuration = Duration.zero;
              });
            },
            child: const Text(
              'Discard',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && _recordingPath != null) {
                final voiceNote = VoiceNote(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  filePath: _recordingPath!,
                  title: titleController.text,
                  createdAt: DateTime.now(),
                  durationMs: _recordingDuration.inMilliseconds,
                );

                widget.onVoiceNoteSaved(voiceNote);
                Navigator.pop(context);

                setState(() {
                  _recordingPath = null;
                  _recordingDuration = Duration.zero;
                });
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3C3C3C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (_isRecording)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recording ${_formatDuration(_recordingDuration)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: _isRecording ? _stopRecording : _startRecording,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFFD4AF37),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              if (_recordingPath != null)
                GestureDetector(
                  onTap: _playRecording,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF90EE90),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isRecording
                ? 'Tap stop when finished'
                : (_recordingPath != null
                    ? 'Tap play to preview, then save or discard'
                    : 'Tap mic to start recording'),
            style: const TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Voice Note Player Widget
class VoiceNotePlayerWidget extends StatefulWidget {
  final VoiceNote voiceNote;
  final VoidCallback onDelete;

  const VoiceNotePlayerWidget({
    super.key,
    required this.voiceNote,
    required this.onDelete,
  });

  @override
  State<VoiceNotePlayerWidget> createState() => _VoiceNotePlayerWidgetState();
}

class _VoiceNotePlayerWidgetState extends State<VoiceNotePlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
        });
      } else {
        final file = File(widget.voiceNote.filePath);
        if (await file.exists()) {
          print('Playing voice note: ${widget.voiceNote.filePath}');
          await _audioPlayer.play(DeviceFileSource(widget.voiceNote.filePath));
          setState(() {
            _isPlaying = true;
          });

          _audioPlayer.onPlayerComplete.listen((_) {
            if (mounted && !_isDisposed) {
              setState(() {
                _isPlaying = false;
              });
            }
          });
        } else {
          print('Voice note file does not exist: ${widget.voiceNote.filePath}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Voice note file not found'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error playing voice note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playback failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDuration(int milliseconds) {
    Duration duration = Duration(milliseconds: milliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _playPause,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF90EE90),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.voiceNote.title,
                  style: const TextStyle(
                    color: Color(0xFFF8F8F8),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDuration(widget.voiceNote.durationMs)} • ${_formatDate(widget.voiceNote.createdAt)}',
                  style: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onDelete,
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFFF6B6B),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
