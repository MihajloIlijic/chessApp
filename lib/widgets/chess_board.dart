import 'package:flutter/material.dart';
import '../models/chess_piece.dart';
import 'promotion_dialog.dart';
import '../models/chess_move.dart';

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

  // Neue Variablen für das Tracking der Bewegungen
  Map<String, bool> hasMoved = {};

  // Variable für En Passant
  String? enPassantTargetSquare;

  // Neue Variablen hinzufügen
  List<ChessMove> moveHistory = [];
  int currentMoveIndex = -1;

  @override
  void initState() {
    super.initState();
    _setupInitialBoard();
    // Initialisiere hasMoved für Könige und Türme
    hasMoved['e1'] = false; // Weißer König
    hasMoved['e8'] = false; // Schwarzer König
    hasMoved['a1'] = false; // Weißer Turm links
    hasMoved['h1'] = false; // Weißer Turm rechts
    hasMoved['a8'] = false; // Schwarzer Turm links
    hasMoved['h8'] = false; // Schwarzer Turm rechts
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
          // Simuliere den Zug temporär
          final originalPosition = piece.position;
          final capturedPiece = _getPieceAtPosition(targetPosition);

          // Führe den Zug temporär aus
          if (capturedPiece != null) {
            pieces.remove(capturedPiece);
          }
          pieces.remove(piece);
          pieces.add(ChessPiece(
            type: piece.type,
            color: piece.color,
            position: targetPosition
          ));

          // Prüfe ob der eigene König nach dem Zug im Schach steht
          if (!_isInCheck(currentPlayer)) {
            possibleMoves.add(targetPosition);
          }

          // Mache den Zug rückgängig
          pieces.remove(pieces.last);
          pieces.add(piece);
          if (capturedPiece != null) {
            pieces.add(capturedPiece);
          }
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
        final movingPiece = selectedPiece!;
        bool moveMade = false;

        if (_isValidMove(movingPiece, position)) {
          // Speichere den Zustand vor dem Zug
          final originalPosition = movingPiece.position;
          final boardStateBefore = List<ChessPiece>.from(pieces);
          final moveStateBefore = Map<String, bool>.from(hasMoved);

          final capturedPiece = _getPieceAtPosition(position);

          // Prüfe auf En Passant
          if (movingPiece.type == PieceType.pawn) {
            // Check En Passant: Zielfeld ist leer und == enPassantTargetSquare?
            if (capturedPiece == null && position == enPassantTargetSquare) {
              final file = position[0];
              final rank = int.parse(position[1]);
              
              // Wenn weiß zieht, stand der schwarze Bauer eine Reihe tiefer
              // Wenn schwarz zieht, stand der weiße Bauer eine Reihe höher
              final capturedRank = (movingPiece.color == PieceColor.white) 
                  ? rank - 1 
                  : rank + 1;
              final capturedPos = '$file$capturedRank';

              final capturedPawn = _getPieceAtPosition(capturedPos);
              if (capturedPawn != null) {
                pieces.remove(capturedPawn);
              }
            }

            // Setze En Passant Target bei Doppelzug
            final fromRank = int.parse(originalPosition[1]);
            final toRank = int.parse(position[1]);
            
            if ((movingPiece.color == PieceColor.white && fromRank == 2 && toRank == 4) ||
                (movingPiece.color == PieceColor.black && fromRank == 7 && toRank == 5)) {
              final file = originalPosition[0];
              final intermediateRank = (fromRank + toRank) ~/ 2;
              enPassantTargetSquare = '$file$intermediateRank';
            } else {
              enPassantTargetSquare = null;
            }
          } else {
            enPassantTargetSquare = null;
          }

          // Normaler Zug (existierender Code)
          if (capturedPiece != null) {
            pieces.remove(capturedPiece);
          }
          pieces.remove(movingPiece);
          pieces.add(ChessPiece(
            type: movingPiece.type,
            color: movingPiece.color,
            position: position
          ));

          // Aktualisiere hasMoved für König und Türme
          if (movingPiece.type == PieceType.king || movingPiece.type == PieceType.rook) {
            hasMoved[originalPosition] = true;
          }

          if (!_isInCheck(currentPlayer)) {
            moveMade = true;

            // Prüfe auf Bauernumwandlung
            if (movingPiece.type == PieceType.pawn) {
              final rank = int.parse(position[1]);
              if ((movingPiece.color == PieceColor.white && rank == 8) ||
                  (movingPiece.color == PieceColor.black && rank == 1)) {
                // Entferne den Bauern temporär
                pieces.remove(pieces.last);
                
                // Zeige Dialog für Figurenauswahl
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return PromotionDialog(
                      position: position,
                      color: movingPiece.color,
                      onPieceSelected: (PieceType selectedType) {
                        setState(() {
                          pieces.add(ChessPiece(
                            type: selectedType,
                            color: movingPiece.color,
                            position: position,
                          ));
                          
                          // Speichere den Zug NACH der Promotion
                          if (currentMoveIndex < moveHistory.length - 1) {
                            moveHistory.removeRange(currentMoveIndex + 1, moveHistory.length);
                          }

                          moveHistory.add(ChessMove(
                            from: originalPosition,
                            to: position,
                            boardState: List<ChessPiece>.from(pieces),
                            currentPlayer: currentPlayer,
                            enPassantTarget: enPassantTargetSquare,
                            moveState: Map<String, bool>.from(hasMoved),
                            isCapture: false,
                            isCheck: false,
                            isMate: false,
                            pieceType: movingPiece.type,
                          ));
                          currentMoveIndex++;
                        });
                      },
                    );
                  },
                );
                return; // Beende die Methode hier
              }
            }

            // Wenn der Zug erfolgreich war, speichere ihn in der Historie
            // Lösche alle Züge nach dem aktuellen Index
            if (currentMoveIndex < moveHistory.length - 1) {
              moveHistory.removeRange(currentMoveIndex + 1, moveHistory.length);
            }

            moveHistory.add(ChessMove(
              from: originalPosition,
              to: position,
              boardState: List<ChessPiece>.from(pieces),
              currentPlayer: currentPlayer,
              enPassantTarget: enPassantTargetSquare,
              moveState: Map<String, bool>.from(hasMoved),
              isCapture: capturedPiece != null || position == enPassantTargetSquare,
              isCheck: _isInCheck(currentPlayer == PieceColor.white ? PieceColor.black : PieceColor.white),
              isMate: _isCheckmate(currentPlayer == PieceColor.white ? PieceColor.black : PieceColor.white),
              pieceType: movingPiece.type,
            ));
            currentMoveIndex++;
          } else {
            // Mache den Zug rückgängig
            pieces.remove(pieces.last);
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
      }});
  }

  bool _isValidMove(ChessPiece piece, String targetPosition, {bool checkCastling = true}) {
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
        // Prüfe auf Rochade nur wenn checkCastling true ist
        if (checkCastling && _canCastle(piece, targetPosition)) {
          return true;
        }
        // Normale Königszüge
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
        if (piece.color == PieceColor.white) {
          // Normaler Zug vorwärts
          if (fileDiff == 0) {
            if (rankDiff == 1 && _getPieceAtPosition(targetPosition) == null) {
              return true;
            }
            if (currentRank == 2 && rankDiff == 2 &&
                _getPieceAtPosition(targetPosition) == null &&
                _getPieceAtPosition('$currentFile${currentRank + 1}') == null) {
              return true;
            }
          }
          // Schlagen diagonal (inkl. En Passant)
          if (rankDiff == 1 && fileDiff.abs() == 1) {
            final targetPiece = _getPieceAtPosition(targetPosition);
            // Normales Schlagen
            if (targetPiece != null && targetPiece.color != piece.color) {
              return true;
            }
            // En Passant
            if (targetPiece == null && targetPosition == enPassantTargetSquare) {
              return true;
            }
          }
        } else {
          // Schwarzer Bauer
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
          // Schlagen diagonal (inkl. En Passant)
          if (rankDiff == -1 && fileDiff.abs() == 1) {
            final targetPiece = _getPieceAtPosition(targetPosition);
            // Normales Schlagen
            if (targetPiece != null && targetPiece.color != piece.color) {
              return true;
            }
            // En Passant
            if (targetPiece == null && targetPosition == enPassantTargetSquare) {
              return true;
            }
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
    final king = pieces.firstWhere(
      (piece) => piece.type == PieceType.king && piece.color == kingColor
    );
    
    return _isSquareAttacked(king.position, kingColor);
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

  // Neue Methode zur Prüfung der Rochade
  bool _canCastle(ChessPiece king, String targetPosition) {
    if (king.type != PieceType.king) return false;
    if (_isInCheck(king.color)) return false;

    // Prüfe ob König sich bereits bewegt hat
    if (hasMoved[king.position] == true) return false;

    final rankStr = king.color == PieceColor.white ? '1' : '8';
    final isKingSide = targetPosition == 'g$rankStr'; // Kleine Rochade
    final isQueenSide = targetPosition == 'c$rankStr'; // Große Rochade

    if (!isKingSide && !isQueenSide) return false;

    final rookFile = isKingSide ? 'h' : 'a';
    final rookPos = '$rookFile$rankStr';

    // Prüfe ob Turm sich bereits bewegt hat
    if (hasMoved[rookPos] == true) return false;

    // Prüfe ob Felder zwischen König und Turm frei sind
    final betweenFiles = isKingSide ? ['f', 'g'] : ['b', 'c', 'd'];
    for (final file in betweenFiles) {
      final pos = '$file$rankStr';
      if (_getPieceAtPosition(pos) != null) return false;
      // Prüfe auch, ob die Felder bedroht sind (für den König)
      if (file == 'c' || file == 'f' || file == 'g') {
        if (_isSquareAttacked(pos, king.color)) return false;
      }
    }

    return true;
  }

  // Neue Methode zur Ausführung der Rochade
  void _performCastling(ChessPiece king, String targetPosition) {
    final rankStr = king.color == PieceColor.white ? '1' : '8';
    final isKingSide = targetPosition == 'g$rankStr';

    // Bewege den König
    pieces.remove(king);
    pieces.add(ChessPiece(
      type: PieceType.king,
      color: king.color,
      position: targetPosition
    ));

    // Bewege den Turm
    final oldRookFile = isKingSide ? 'h' : 'a';
    final newRookFile = isKingSide ? 'f' : 'd';
    final oldRookPos = '$oldRookFile$rankStr';
    final newRookPos = '$newRookFile$rankStr';

    final rook = _getPieceAtPosition(oldRookPos)!;
    pieces.remove(rook);
    pieces.add(ChessPiece(
      type: PieceType.rook,
      color: king.color,
      position: newRookPos
    ));
  }

  // Neue Hilfsmethode zur Prüfung ob ein Feld bedroht ist
  bool _isSquareAttacked(String position, PieceColor defendingColor) {
    for (final piece in pieces) {
      if (piece.color != defendingColor && 
          _isValidMove(piece, position, checkCastling: false)) { // Wichtig: checkCastling: false
        return true;
      }
    }
    return false;
  }

  // Neue Methoden für die Navigation
  void _goToMove(int index) {
    if (index >= -1 && index < moveHistory.length) {
      setState(() {
        currentMoveIndex = index;
        if (index == -1) {
          // Zurück zum Anfang
          _setupInitialBoard();
          currentPlayer = PieceColor.white;
          enPassantTargetSquare = null;
          hasMoved.clear();
          hasMoved['e1'] = false;
          hasMoved['e8'] = false;
          hasMoved['a1'] = false;
          hasMoved['h1'] = false;
          hasMoved['a8'] = false;
          hasMoved['h8'] = false;
        } else {
          // Stelle den Zustand nach dem gewählten Zug wieder her
          final move = moveHistory[index];
          pieces = List<ChessPiece>.from(move.boardState);
          currentPlayer = move.currentPlayer == PieceColor.white 
              ? PieceColor.black 
              : PieceColor.white;
          enPassantTargetSquare = move.enPassantTarget;
          hasMoved = Map<String, bool>.from(move.moveState);
        }
        selectedPiece = null;
        possibleMoves = [];
      });
    }
  }

  // Neue Hilfsmethode für die Schachnotation
  String _getNotation(String from, String to, ChessPiece piece, bool isCapture, bool isCheck, bool isMate) {
    String notation = '';
    
    // Figur-Symbol (außer bei Bauern)
    if (piece.type != PieceType.pawn) {
      switch (piece.type) {
        case PieceType.king: notation += 'K';
        case PieceType.queen: notation += 'D';
        case PieceType.rook: notation += 'T';
        case PieceType.bishop: notation += 'L';
        case PieceType.knight: notation += 'S';
        case PieceType.pawn: break;
      }
    }
    
    notation += from; // Ausgangsfeld
    notation += isCapture ? 'x' : '-';
    notation += to; // Zielfeld
    
    if (isMate) {
      notation += '#';
    } else if (isCheck) {
      notation += '+';
    }
    
    return notation;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight 
            ? constraints.maxWidth 
            : constraints.maxHeight * 0.7;
        
        final squareSize = size / 8;
        final fontSize = squareSize * 0.6;

        return SingleChildScrollView(
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
              // Notationsliste
              Container(
                height: 100,
                width: size,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < moveHistory.length; i += 2) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Zugnummer
                            SizedBox(
                              width: 40,
                              child: Text('${(i ~/ 2) + 1}.'),
                            ),
                            // Weißer Zug
                            Expanded(
                              child: Text(moveHistory[i].notation),
                            ),
                            // Schwarzer Zug (wenn vorhanden)
                            if (i + 1 < moveHistory.length) Expanded(
                              child: Text(moveHistory[i + 1].notation),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 