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
  // Weiß beginnt
  PieceColor currentPlayer = PieceColor.white;

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
    pieces.add(ChessPiece(type: PieceType.queen, color: PieceColor.white, position: 'd1'));
    pieces.add(ChessPiece(type: PieceType.king, color: PieceColor.white, position: 'e1'));
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
    pieces.add(ChessPiece(type: PieceType.queen, color: PieceColor.black, position: 'd8'));
    pieces.add(ChessPiece(type: PieceType.king, color: PieceColor.black, position: 'e8'));
    pieces.add(ChessPiece(type: PieceType.bishop, color: PieceColor.black, position: 'f8'));
    pieces.add(ChessPiece(type: PieceType.knight, color: PieceColor.black, position: 'g8'));
    pieces.add(ChessPiece(type: PieceType.rook, color: PieceColor.black, position: 'h8'));

    // Schwarze Bauern - siebte Reihe (7)
    for (var file in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) {
      pieces.add(ChessPiece(type: PieceType.pawn, color: PieceColor.black, position: '${file}7'));
    }
  }

  String _getPositionFromIndex(int index) {
    // Wir drehen das Brett um 180 Grad, indem wir den Index umkehren
    final adjustedIndex = 63 - index;
    final file = String.fromCharCode('a'.codeUnitAt(0) + (adjustedIndex % 8));
    final rank = (adjustedIndex ~/ 8) + 1;
    return '$file$rank';
  }

  ChessPiece? _getPieceAtPosition(String position) {
    final matches = pieces.where((piece) => piece.position == position);
    return matches.isEmpty ? null : matches.first;
  }

  void _onTileTapped(String position) {
    setState(() {
      final tappedPiece = _getPieceAtPosition(position);
      
      if (selectedPiece == null) {
        // Nur Figuren der aktuellen Farbe können ausgewählt werden
        if (tappedPiece != null && tappedPiece.color == currentPlayer) {
          selectedPiece = tappedPiece;
        }
      } else {
        bool moveMade = false;
        
        // Prüfen ob der Zug legal ist
        if (_isValidMove(selectedPiece!, position)) {
          // Bewege die Figur
          pieces.removeWhere((piece) => piece.position == selectedPiece!.position);
          pieces.removeWhere((piece) => piece.position == position);
          pieces.add(ChessPiece(
            type: selectedPiece!.type,
            color: selectedPiece!.color,
            position: position,
          ));
          moveMade = true;
        }
        
        selectedPiece = null;

        // Spieler wechseln nach erfolgreichem Zug
        if (moveMade) {
          currentPlayer = (currentPlayer == PieceColor.white) 
              ? PieceColor.black 
              : PieceColor.white;
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
    final fromFile = from[0];
    final fromRank = int.parse(from[1]);
    final toFile = to[0];
    final toRank = int.parse(to[1]);

    final fileStep = (toFile.codeUnitAt(0) - fromFile.codeUnitAt(0)).sign;
    final rankStep = (toRank - fromRank).sign;

    var currentFile = fromFile.codeUnitAt(0) + fileStep;
    var currentRank = fromRank + rankStep;

    while (String.fromCharCode(currentFile) != toFile || currentRank != toRank) {
      final position = '${String.fromCharCode(currentFile)}$currentRank';
      if (_getPieceAtPosition(position) != null) {
        return false;
      }
      currentFile += fileStep;
      currentRank += rankStep;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight 
            ? constraints.maxWidth 
            : constraints.maxHeight * 0.9; // Reduzieren um 10% für Text
        
        final squareSize = size / 8; // Größe eines Schachfeldes
        final fontSize = squareSize * 0.6; // Schriftgröße relativ zum Feld

        return SizedBox(
          height: size + 50, // Extra Platz für den Text oben
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${currentPlayer == PieceColor.white ? "Weiß" : "Schwarz"} ist am Zug',
                  style: TextStyle(fontSize: fontSize * 0.5),
                ),
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
                    final row = index ~/ 8;
                    final col = index % 8;
                    final isWhite = (row + col) % 2 == 0;
                    final position = _getPositionFromIndex(index);
                    final piece = _getPieceAtPosition(position);
                    final isSelected = selectedPiece?.position == position;

                    return GestureDetector(
                      onTap: () => _onTileTapped(position),
                      child: Container(
                        color: isSelected 
                            ? Colors.yellow[700]
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