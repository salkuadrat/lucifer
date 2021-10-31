import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

///
/// JSON Web Token Handler
///
class Jwt {
  ///
  /// Sign JSON Web Token
  ///
  String sign(
    Map<String, dynamic> payload,
    String secret, {
    JWTAlgorithm algorithm = JWTAlgorithm.HS256,
    Duration? expiresIn,
    Duration? notBefore,
    bool noIssueAt = false,
    Audience? audience,
    String? subject,
    String? issuer,
    String? jwtId,
    Map<String, dynamic>? header,
  }) {
    final jwt = JWT(
      payload,
      audience: audience,
      subject: subject,
      issuer: issuer,
      jwtId: jwtId,
      header: header,
    );
    final key = SecretKey(secret);
    return jwt.sign(
      key,
      algorithm: algorithm,
      expiresIn: expiresIn,
      notBefore: notBefore,
      noIssueAt: noIssueAt,
    );
  }

  ///
  /// Verify JSON Web Token
  ///
  Map<String, dynamic>? verify(
    String token,
    String secret, [
    void Function(dynamic error, Map<String, dynamic>? data)? done,
  ]) {
    try {
      final jwt = JWT.verify(token, SecretKey(secret));
      done?.call(null, jwt.payload as Map<String, dynamic>);
      return jwt.payload;
    } on JWTExpiredError {
      if (done != null) {
        done.call('JWTExpiredError', null);
      } else {
        throw JWTExpiredError();
      }
    } on JWTError catch (e) {
      if (done != null) {
        done.call(e.message, null);
      } else {
        throw JWTError(e.message);
      }
    } on Exception catch (e) {
      if (done != null) {
        done.call('Verify token failed', null);
      } else {
        throw Exception(e);
      }
    }
  }
}
