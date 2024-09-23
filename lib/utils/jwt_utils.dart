import 'package:jwt_decoder/jwt_decoder.dart';

bool isTokenValid(String token) {
  // Verifica se o token é válido
  return !JwtDecoder.isExpired(token);
}

void printTokenInfo(String token) {
  if (isTokenValid(token)) {
    // Decodifica o token
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    // Imprime o token inteiro decodificado
    print("Token Decodificado:");
    print(decodedToken); // Exibe todas as informações do token
  } else {
    print("O token está expirado.");
  }
}
