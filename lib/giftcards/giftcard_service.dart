import 'package:cloud_functions/cloud_functions.dart';

class GiftcardException implements Exception {
  final String message;
  GiftcardException(this.message);
  @override
  String toString() => message;
}

class GiftcardService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> buy({required int amount, required String type}) async {
    try {
      final res = await _functions.httpsCallable('createGiftcard').call({'amount': amount, 'type': type});
      return Map<String, dynamic>.from(res.data as Map);
    } on FirebaseFunctionsException catch (e) {
      throw GiftcardException(e.message ?? 'Something went wrong. Please try again.');
    } catch (_) {
      throw GiftcardException('Could not reach the server. Check your connection.');
    }
  }

  Future<Map<String, dynamic>> redeem(String code) async {
    try {
      final res = await _functions.httpsCallable('redeemGiftcard').call({'code': code});
      return Map<String, dynamic>.from(res.data as Map);
    } on FirebaseFunctionsException catch (e) {
      throw GiftcardException(e.message ?? 'Something went wrong. Please try again.');
    } catch (_) {
      throw GiftcardException('Could not reach the server. Check your connection.');
    }
  }
}
