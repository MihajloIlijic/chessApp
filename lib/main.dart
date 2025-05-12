import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_config.dart';
import 'screens/login_screen.dart';
import 'widgets/chess_board.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initializeFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        // Fügen Sie hier weitere Routen hinzu
      },
    );
  }
}

class ChessPuzzlePage extends StatefulWidget {
  const ChessPuzzlePage({super.key, required this.title});

  final String title;

  @override
  State<ChessPuzzlePage> createState() => _ChessPuzzlePageState();
}

class _ChessPuzzlePageState extends State<ChessPuzzlePage> {
  int _puzzlesSolved = 0;

  void _nextPuzzle() {
    setState(() {
      _puzzlesSolved++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: const ChessBoard(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Gelöste Puzzles: $_puzzlesSolved',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nextPuzzle,
        tooltip: 'Nächstes Puzzle',
        child: const Icon(Icons.skip_next),
      ),
    );
  }
}
