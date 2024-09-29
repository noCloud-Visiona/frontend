import 'package:jwt_decoder/jwt_decoder.dart';

/// Verifica se o token JWT ainda é válido.
/// Retorna `true` se o token não estiver expirado e `false` caso contrário.
bool isTokenValid(String token) {
  return !JwtDecoder.isExpired(token);
}

/// Imprime as informações contidas no token JWT, se válido.
void printTokenInfo(String token) {
  if (isTokenValid(token)) {
    // Decodifica o token JWT
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    // Imprime o token inteiro decodificado
    print("Token Decodificado:");
    print(decodedToken);
  } else {
    print("O token está expirado.");
  }
}

/// Retorna o tempo de expiração restante do token em segundos.
/// Se o token já estiver expirado, retorna `Duration.zero`.
Duration getTokenExpirationDuration(String token) {
  if (isTokenValid(token)) {
    return JwtDecoder.getRemainingTime(token); // Usa a função getRemainingTime
  } else {
    return Duration.zero;
  }
}

/// Obtém as informações decodificadas do token JWT como um mapa.
/// Retorna `null` se o token estiver expirado.
Map<String, dynamic>? getDecodedToken(String token) {
  return isTokenValid(token) ? JwtDecoder.tryDecode(token) : null;
}
