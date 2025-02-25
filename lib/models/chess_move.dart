import 'chess_piece.dart';

class ChessMove {
  final String from;
  final String to;
  final List<ChessPiece> boardState;
  final PieceColor currentPlayer;
  final String? enPassantTarget;
  final Map<String, bool> moveState;
  final bool isCapture;
  final bool isCheck;
  final bool isMate;
  final PieceType pieceType;

  ChessMove({
    required this.from,
    required this.to,
    required this.boardState,
    required this.currentPlayer,
    required this.enPassantTarget,
    required this.moveState,
    required this.isCapture,
    required this.isCheck,
    required this.isMate,
    required this.pieceType,
  });

  String get notation {
    String note = '';
    
    // Figur-Symbol (außer bei Bauern)
    if (pieceType != PieceType.pawn) {
      switch (pieceType) {
        case PieceType.king: note += 'K';
        case PieceType.queen: note += 'D';
        case PieceType.rook: note += 'T';
        case PieceType.bishop: note += 'L';
        case PieceType.knight: note += 'S';
        case PieceType.pawn: break;
      }
    }
    
    note += from;
    note += isCapture ? 'x' : '-';
    note += to;
    
    if (isMate) {
      note += '#';
    } else if (isCheck) {
      note += '+';
    }
    
    return note;
  }
} 