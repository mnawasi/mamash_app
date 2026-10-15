import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

enum GiftcardType { favi, mama, lucky }

class MamashGiftcard {
  final String id;
  final String code; // e.g. MAMASH-FAVI-5K-7QK2-M9XD
  final int amountNaira;
  final GiftcardType type;
  final bool isRedeemed;
  final DateTime createdAt;

  const MamashGiftcard({
    required this.id,
    required this.code,
    required this.amountNaira,
    required this.type,
    this.isRedeemed = false,
    required this.createdAt,
  });

  /// Makes an unguessable code. Letters that look alike (O/0, I/1) are left out.
  static String generateCode(int amountNaira, GiftcardType type) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    String block(int n) => List.generate(n, (_) => chars[rng.nextInt(chars.length)]).join();
    final amountLabel = amountNaira % 1000 == 0 ? '${amountNaira ~/ 1000}K' : '$amountNaira';
    return 'MAMASH-${type.name.toUpperCase()}-$amountLabel-${block(4)}-${block(4)}';
  }

  factory MamashGiftcard.fromMap(String id, Map<String, dynamic> m) {
    final created = m['createdAt'];
    return MamashGiftcard(
      id: id,
      code: (m['code'] ?? '') as String,
      amountNaira: (m['amount'] as num?)?.toInt() ?? 0,
      type: GiftcardType.values.firstWhere(
        (t) => t.name == m['type'],
        orElse: () => GiftcardType.favi,
      ),
      isRedeemed: m['isRedeemed'] == true,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'code': code,
        'amount': amountNaira,
        'type': type.name,
        'isRedeemed': isRedeemed,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  MamashGiftcard copyWith({bool? isRedeemed}) => MamashGiftcard(
        id: id,
        code: code,
        amountNaira: amountNaira,
        type: type,
        isRedeemed: isRedeemed ?? this.isRedeemed,
        createdAt: createdAt,
      );
}
