import 'package:flutter/material.dart';
import '../models/chess_piece.dart';

class PromotionDialog extends StatelessWidget {
  final String position;
  final PieceColor color;
  final Function(PieceType) onPieceSelected;

  const PromotionDialog({
    super.key,
    required this.position,
    required this.color,
    required this.onPieceSelected,
  });

  Widget _promotionButton(BuildContext context, PieceType type) {
    return GestureDetector(
      onTap: () {
        onPieceSelected(type);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          ChessPiece(
            type: type,
            color: color,
            position: 'a1', // Dummy-Position
          ).symbol,
          style: TextStyle(
            fontSize: 32,
            color: color == PieceColor.white ? Colors.amber[200] : Colors.black,
            shadows: [
              Shadow(
                color: color == PieceColor.white ? Colors.black54 : Colors.white54,
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bauernumwandlung'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _promotionButton(context, PieceType.queen),
          _promotionButton(context, PieceType.rook),
          _promotionButton(context, PieceType.bishop),
          _promotionButton(context, PieceType.knight),
        ],
      ),
    );
  }
} 