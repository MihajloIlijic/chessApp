import 'package:flutter/material.dart';
import '../models/chess_piece.dart';

class ChessBoard extends StatefulWidget {
  const ChessBoard({super.key});

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  ChessPiece? selectedPiece;
  List<ChessPiece> pieces = [];
  List<String> possibleMoves = []; // Neue Liste für mögliche Züge
  // Weiß beginnt
  PieceColor currentPlayer = PieceColor.white;
  bool isRotated = false; // Neue Variable für die Drehung

  @override
  void initState() {
    super.initState();
    _setupInitialBoard();
  }

  void _setupInitialBoard() {
    // Weiße Figuren - erste Reihe (1)
    pieces.add(ChessPiece(type: PieceType.rook, color: PieceColor.white, position: 'a1'));
    pieces.add(ChessPiece(type: PieceType.knight, color: PieceColor.white, position: 'b1'));
    pieces.add(ChessPiece(type: PieceType.bishop, color: PieceColor.white, position: 'c1'));
    pieces.add(ChessPiece(type: PieceType.king, color: PieceColor.white, position: 'e1')); // König auf e1
    pieces.add(ChessPiece(type: PieceType.queen, color: PieceColor.white, position: 'd1')); // Dame auf d1
    pieces.add(ChessPiece(type: PieceType.bishop, color: PieceColor.white, position: 'f1'));
    pieces.add(ChessPiece(type: PieceType.knight, color: PieceColor.white, position: 'g1'));
    pieces.add(ChessPiece(type: PieceType.rook, color: PieceColor.white, position: 'h1'));

    // Weiße Bauern - zweite Reihe (2)
    for (var file in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) {
      pieces.add(ChessPiece(type: PieceType.pawn, color: PieceColor.white, position: '${file}2'));
    }

    // Schwarze Figuren - achte Reihe (8)
    pieces.add(ChessPiece(type: PieceType.rook, color: PieceColor.black, position: 'a8'));
    pieces.add(ChessPiece(type: PieceType.knight, color: PieceColor.black, position: 'b8'));
    pieces.add(ChessPiece(type: PieceType.bishop, color: PieceColor.black, position: 'c8'));
    pieces.add(ChessPiece(type: PieceType.king, color: PieceColor.black, position: 'e8')); // König auf e8
    pieces.add(ChessPiece(type: PieceType.queen, color: PieceColor.black, position: 'd8')); // Dame auf d8
    pieces.add(ChessPiece(type: PieceType.bishop, color: PieceColor.black, position: 'f8'));
    pieces.add(ChessPiece(type: PieceType.knight, color: PieceColor.black, position: 'g8'));
    pieces.add(ChessPiece(type: PieceType.rook, color: PieceColor.black, position: 'h8'));

    // Schwarze Bauern - siebte Reihe (7)
    for (var file in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) {
      pieces.add(ChessPiece(type: PieceType.pawn, color: PieceColor.black, position: '${file}7'));
    }
  }

  String _getPositionFromIndex(int index) {
    if (isRotated) {
      // Wenn das Brett gedreht ist, drehen wir die Reihen und Spalten
      final row = 7 - (index ~/ 8);
      final col = 7 - (index % 8);
      final newIndex = row * 8 + col;
      
      final file = String.fromCharCode('a'.codeUnitAt(0) + (newIndex % 8));
      final rank = 8 - (newIndex ~/ 8);
      return '$file$rank';
    } else {
      // Normale Berechnung für nicht gedrehtes Brett
      final file = String.fromCharCode('a'.codeUnitAt(0) + (index % 8));
      final rank = 8 - (index ~/ 8);
      return '$file$rank';
    }
  }

  ChessPiece? _getPieceAtPosition(String position) {
    final matches = pieces.where((piece) => piece.position == position);
    return matches.isEmpty ? null : matches.first;
  }

  // Neue Methode zum Berechnen aller möglichen Züge
  void _calculatePossibleMoves(ChessPiece piece) {
    possibleMoves = [];
    for (int rank = 1; rank <= 8; rank++) {
      for (String file in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) {
        final targetPosition = '$file$rank';
        if (_isValidMove(piece, targetPosition)) {
          possibleMoves.add(targetPosition);
        }
      }
    }
  }

  void _onTileTapped(String position) {
    setState(() {
      final tappedPiece = _getPieceAtPosition(position);
      
      if (selectedPiece == null) {
        if (tappedPiece != null && tappedPiece.color == currentPlayer) {
          selectedPiece = tappedPiece;
          _calculatePossibleMoves(tappedPiece);
        }
      } else {
        // Stellen Sie sicher, dass selectedPiece nicht null ist
        final movingPiece = selectedPiece!;
        bool moveMade = false;
        
        if (_isValidMove(movingPiece, position)) {
          // Simuliere den Zug um zu prüfen, ob er den eigenen König in Schach setzt
          final originalPosition = movingPiece.position;
          final capturedPiece = _getPieceAtPosition(position);
          
          // Führe den Zug temporär aus
          if (capturedPiece != null) {
            pieces.remove(capturedPiece);
          }
          pieces.remove(movingPiece);
          
          final newPiece = ChessPiece(
            type: movingPiece.type,
            color: movingPiece.color,
            position: position
          );
          pieces.add(newPiece);

          // Prüfe ob der eigene König nach dem Zug im Schach steht
          if (!_isInCheck(currentPlayer)) {
            moveMade = true;
          } else {
            // Mache den Zug rückgängig wenn er den eigenen König in Schach setzt
            pieces.remove(newPiece);
            pieces.add(movingPiece);
            if (capturedPiece != null) {
              pieces.add(capturedPiece);
            }
          }
        }
        
        selectedPiece = null;
        possibleMoves = [];

        if (moveMade) {
          currentPlayer = (currentPlayer == PieceColor.white) 
              ? PieceColor.black 
              : PieceColor.white;
            
          // Prüfe auf Schach oder Schachmatt
          if (_isInCheck(currentPlayer)) {
            if (_isCheckmate(currentPlayer)) {
              // Zeige Schachmatt-Dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Schachmatt!'),
                  content: Text('${currentPlayer == PieceColor.white ? "Schwarz" : "Weiß"} gewinnt!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Optional: Spiel neu starten
                        setState(() {
                          pieces.clear();
                          _setupInitialBoard();
                          currentPlayer = PieceColor.white;
                        });
                      },
                      child: const Text('Neues Spiel'),
                    ),
                  ],
                ),
              );
            } else {
              // Zeige Schach-Nachricht
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${currentPlayer == PieceColor.white ? "Weiß" : "Schwarz"} steht im Schach!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        }
      }
    });
  }

  bool _isValidMove(ChessPiece piece, String targetPosition) {
    // Prüfen ob auf dem Zielfeld eine eigene Figur steht
    final targetPiece = _getPieceAtPosition(targetPosition);
    if (targetPiece != null && targetPiece.color == piece.color) {
      return false;  // Eigene Figuren können nicht geschlagen werden
    }

    // Aktuelle Position in Koordinaten umwandeln
    final currentFile = piece.position[0];
    final currentRank = int.parse(piece.position[1]);
    final targetFile = targetPosition[0];
    final targetRank = int.parse(targetPosition[1]);

    // Horizontale und vertikale Distanz berechnen
    final fileDiff = targetFile.codeUnitAt(0) - currentFile.codeUnitAt(0);
    final rankDiff = targetRank - currentRank;

    switch (piece.type) {
      case PieceType.king:
        // König kann sich nur ein Feld in jede Richtung bewegen
        return (fileDiff.abs() <= 1 && rankDiff.abs() <= 1);

      case PieceType.queen:
        // Königin kann diagonal, horizontal oder vertikal beliebig weit ziehen
        return _isPathClear(piece.position, targetPosition) && 
               (fileDiff.abs() == rankDiff.abs() || // diagonal
                fileDiff == 0 || rankDiff == 0);    // horizontal/vertikal

      case PieceType.bishop:
        // Läufer kann nur diagonal ziehen
        return _isPathClear(piece.position, targetPosition) && 
               (fileDiff.abs() == rankDiff.abs());

      case PieceType.knight:
        // Springer bewegt sich in L-Form (2 in eine Richtung, 1 in die andere)
        return (fileDiff.abs() == 2 && rankDiff.abs() == 1) ||
               (fileDiff.abs() == 1 && rankDiff.abs() == 2);

      case PieceType.rook:
        // Turm kann nur horizontal oder vertikal ziehen
        return _isPathClear(piece.position, targetPosition) && 
               (fileDiff == 0 || rankDiff == 0);

      case PieceType.pawn:
        // Bauern haben komplexere Regeln
        if (piece.color == PieceColor.white) {
          // Weißer Bauer bewegt sich nach oben
          if (fileDiff == 0) {
            // Normaler Zug vorwärts
            if (rankDiff == 1 && _getPieceAtPosition(targetPosition) == null) {
              return true;
            }
            // Doppelzug von Startposition
            if (currentRank == 2 && rankDiff == 2 && 
                _getPieceAtPosition(targetPosition) == null &&
                _getPieceAtPosition('$currentFile${currentRank + 1}') == null) {
              return true;
            }
          }
          // Schlagen diagonal
          if (rankDiff == 1 && fileDiff.abs() == 1) {
            final targetPiece = _getPieceAtPosition(targetPosition);
            return targetPiece != null && targetPiece.color != piece.color;
          }
        } else {
          // Schwarzer Bauer bewegt sich nach unten
          if (fileDiff == 0) {
            if (rankDiff == -1 && _getPieceAtPosition(targetPosition) == null) {
              return true;
            }
            if (currentRank == 7 && rankDiff == -2 && 
                _getPieceAtPosition(targetPosition) == null &&
                _getPieceAtPosition('$currentFile${currentRank - 1}') == null) {
              return true;
            }
          }
          if (rankDiff == -1 && fileDiff.abs() == 1) {
            final targetPiece = _getPieceAtPosition(targetPosition);
            return targetPiece != null && targetPiece.color != piece.color;
          }
        }
        return false;
    }
  }

  // Hilfsmethode um zu prüfen, ob der Weg frei ist
  bool _isPathClear(String from, String to) {
    final fromFile = from[0].codeUnitAt(0);
    final fromRank = int.parse(from[1]);
    final toFile = to[0].codeUnitAt(0);
    final toRank = int.parse(to[1]);

    final fileStep = (toFile - fromFile).sign;
    final rankStep = (toRank - fromRank).sign;

    var currentFile = fromFile + fileStep;
    var currentRank = fromRank + rankStep;

    // Prüfe, ob wir noch innerhalb des Schachbretts sind
    while (currentFile >= 'a'.codeUnitAt(0) && 
           currentFile <= 'h'.codeUnitAt(0) && 
           currentRank >= 1 && 
           currentRank <= 8) {
      
      // Wenn wir das Zielfeld erreicht haben, beenden wir die Schleife
      if (currentFile == toFile && currentRank == toRank) {
        break;
      }

      // Prüfe, ob das aktuelle Feld frei ist
      final position = '${String.fromCharCode(currentFile)}$currentRank';
      if (_getPieceAtPosition(position) != null) {
        return false;
      }

      // Gehe zum nächsten Feld
      currentFile += fileStep;
      currentRank += rankStep;
    }

    return true;
  }

  // Prüft, ob ein König im Schach steht
  bool _isInCheck(PieceColor kingColor) {
    // Finde die Position des Königs
    final king = pieces.firstWhere(
      (piece) => piece.type == PieceType.king && piece.color == kingColor
    );
    
    // Prüfe, ob irgendeine gegnerische Figur den König angreifen kann
    for (final piece in pieces) {
      if (piece.color != kingColor && _isValidMove(piece, king.position)) {
        return true;
      }
    }
    return false;
  }

  // Prüft, ob Schachmatt vorliegt
  bool _isCheckmate(PieceColor kingColor) {
    if (!_isInCheck(kingColor)) return false;

    // Finde den König
    final king = pieces.firstWhere(
      (piece) => piece.type == PieceType.king && piece.color == kingColor
    );

    // 1. Kann der König sich bewegen?
    for (int rank = 1; rank <= 8; rank++) {
      for (String file in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) {
        final targetPosition = '$file$rank';
        if (_isValidMove(king, targetPosition)) {
          // Simuliere den Zug
          final originalPosition = king.position;
          final capturedPiece = _getPieceAtPosition(targetPosition);
          
          // Führe den Zug temporär aus
          pieces.remove(capturedPiece);
          pieces.remove(king);
          pieces.add(ChessPiece(
            type: king.type,
            color: king.color,
            position: targetPosition
          ));

          // Prüfe ob der König nach dem Zug noch im Schach steht
          final stillInCheck = _isInCheck(kingColor);

          // Mache den Zug rückgängig
          pieces.remove(pieces.last);
          pieces.add(king);
          if (capturedPiece != null) {
            pieces.add(capturedPiece);
          }

          if (!stillInCheck) {
            return false; // König kann sich bewegen
          }
        }
      }
    }

    // 2. Kann eine andere Figur das Schach abwehren?
    final ownPieces = pieces.where((p) => p.color == kingColor && p.type != PieceType.king);
    for (final piece in ownPieces) {
      for (int rank = 1; rank <= 8; rank++) {
        for (String file in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) {
          final targetPosition = '$file$rank';
          if (_isValidMove(piece, targetPosition)) {
            // Simuliere den Zug
            final originalPosition = piece.position;
            final capturedPiece = _getPieceAtPosition(targetPosition);
            
            // Führe den Zug temporär aus
            pieces.remove(capturedPiece);
            pieces.remove(piece);
            pieces.add(ChessPiece(
              type: piece.type,
              color: piece.color,
              position: targetPosition
            ));

            // Prüfe ob der König nach dem Zug noch im Schach steht
            final stillInCheck = _isInCheck(kingColor);

            // Mache den Zug rückgängig
            pieces.remove(pieces.last);
            pieces.add(piece);
            if (capturedPiece != null) {
              pieces.add(capturedPiece);
            }

            if (!stillInCheck) {
              return false; // Eine Figur kann das Schach abwehren
            }
          }
        }
      }
    }

    return true; // Keine Möglichkeit das Schach abzuwehren -> Schachmatt
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight 
            ? constraints.maxWidth 
            : constraints.maxHeight * 0.9;
        
        final squareSize = size / 8;
        final fontSize = squareSize * 0.6;

        return SizedBox(
          height: size + 50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${currentPlayer == PieceColor.white ? "Weiß" : "Schwarz"} ist am Zug',
                      style: TextStyle(fontSize: fontSize * 0.5),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.rotate_right),
                    onPressed: () {
                      setState(() {
                        isRotated = !isRotated;
                        // Leere die möglichen Züge beim Drehen
                        possibleMoves = [];
                        selectedPiece = null;
                      });
                    },
                    tooltip: 'Brett drehen',
                  ),
                ],
              ),
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemCount: 64,
                  itemBuilder: (context, index) {
                    final position = _getPositionFromIndex(index);
                    final piece = _getPieceAtPosition(position);
                    final isSelected = selectedPiece?.position == position;
                    final isPossibleMove = possibleMoves.contains(position);

                    // Berechne die Farbe des Feldes basierend auf der gedrehten Position
                    final row = isRotated ? (7 - (index ~/ 8)) : (index ~/ 8);
                    final col = isRotated ? (7 - (index % 8)) : (index % 8);
                    final isWhite = (row + col) % 2 == 0;

                    return GestureDetector(
                      onTap: () => _onTileTapped(position),
                      child: Container(
                        color: isSelected 
                            ? Colors.yellow[700]
                            : isPossibleMove 
                                ? Colors.green[300]
                                : (isWhite ? Colors.white : Colors.grey[800]),
                        child: Center(
                          child: piece != null
                              ? Text(
                                  piece.symbol,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    color: piece.color == PieceColor.white 
                                        ? Colors.amber[200]
                                        : Colors.black,
                                    shadows: [
                                      Shadow(
                                        color: piece.color == PieceColor.white 
                                            ? Colors.black54 
                                            : Colors.white54,
                                        offset: const Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 