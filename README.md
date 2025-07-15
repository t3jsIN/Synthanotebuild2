# Synthanote 🎵

A beautiful, dark-themed note-taking app designed for music producers and creators. Built with Flutter for iOS.

## ✨ Features

- **🎵 ID Hub** - Organize music ideas with structured sections (Intro, Drop, Build-up, etc.)
- **🎤 Voice Recording** - Capture audio notes directly within music sections
- **🎛️ MixBook** - Document mixing techniques and tips by audio element
- **📝 QuickNote** - Fast text notes for instant thoughts
- **🔍 Smart Search** - Find notes instantly with full-text search
- **🏷️ Filter System** - Organize notes by type (ID Hub, MixBook, QuickNote)
- **💾 Offline Storage** - Works completely offline with local data persistence
- **🌙 Dark Theme** - Carefully designed dark UI that's easy on the eyes
- **📱 iOS Optimized** - Native iOS experience with proper SafeArea handling

## 🎨 Design

- **Typography**: SF Pro Display fonts for authentic iOS feel
- **Color Scheme**: Dark theme with amber accent colors
- **Layout**: Clean, minimal interface focused on productivity
- **Interactions**: Smooth animations and transitions

## 🛠️ Technical Features

- **Flutter Framework** - Cross-platform development
- **Local Storage** - SharedPreferences + file-based caching
- **Audio Recording** - High-quality voice note recording
- **Search Engine** - Real-time search with debouncing
- **State Management** - Efficient state handling
- **Error Handling** - Robust error management

## 📱 Screenshots

*Screenshots coming soon...*

## 🚀 Installation

### Prerequisites
- Flutter SDK (>=3.10.0)
- Xcode (for iOS development)
- iOS device or simulator

### Setup
1. Clone the repository:
```bash
git clone https://github.com/t3jsIN/Synthanotebuild2.git
cd Synthanotebuild2
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run on iOS:
```bash
flutter run -d ios
```

## 📋 Usage

### Creating Notes
1. **QuickNote**: Tap "QuickNote" → Add title → Start typing
2. **ID Hub**: Tap "ID Hub" → Add metadata → Create sections → Add voice notes
3. **MixBook**: Tap "MixBook" → Select mix element → Document techniques

### Voice Recording
- Available in ID Hub sections
- Tap microphone icon → Record → Preview → Save with title

### Search & Filter
- Use search bar for full-text search
- Filter by note type using chips
- Real-time results with 300ms debounce

## 🏗️ Project Structure

```
lib/
├── main.dart              # Main app entry point
├── models.dart            # Data models
├── screens/
│   ├── home_screen.dart   # Main dashboard
│   ├── quick_note.dart    # Quick note editor
│   ├── music_note.dart    # ID Hub editor
│   └── mix_tip.dart       # MixBook editor
└── widgets/
    ├── voice_recorder.dart # Voice recording widget
    └── note_cards.dart     # Note display components
```

## 🎵 For Music Producers

Synthanote is specifically designed for music production workflows:

- **Track Structure**: Document song sections with standard naming (Intro, Verse, Chorus, Drop, etc.)
- **Mix Elements**: Organize mixing tips by audio elements (Drums, Bass, Vocals, FX)
- **Voice Ideas**: Record musical ideas instantly with voice notes
- **Quick Access**: Fast note-taking during creative sessions

## 🔧 Dependencies

- `flutter/material.dart` - UI framework
- `shared_preferences` - Local data storage
- `path_provider` - File system access
- `share_plus` - Note sharing functionality
- `record` - Audio recording
- `audioplayers` - Audio playback

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**t3jsIN**
- GitHub: [@t3jsIN](https://github.com/t3jsIN)

## 🙏 Acknowledgments

- Built with Flutter framework
- Inspired by music production workflows
- Designed for creative professionals

---

*Built with ❤️ for music creators*
