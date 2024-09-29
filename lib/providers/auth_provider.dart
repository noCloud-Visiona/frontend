import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _jwtToken;
  Timer? _logoutTimer; // Timer para deslogar automaticamente

  String? get jwtToken => _jwtToken;

  /// Define o JWT token e agenda o logout automático com base na expiração do token.
  void setJwtToken(String token) {
    _jwtToken = token;
    _scheduleLogout(token); // Agendar logout quando o token for definido
    _saveTokenToPrefs(token); // Salvar o token no SharedPreferences
    notifyListeners();
  }

  /// Agenda o logout automático quando o token expirar.
  void _scheduleLogout(String token) {
    // Obter o tempo restante até a expiração do token
    Duration timeRemaining = JwtDecoder.getRemainingTime(token);
    
    // Se o token já estiver expirado, realizar logout imediato
    if (timeRemaining.isNegative) {
      logout();
      return;
    }

    // Cancelar qualquer timer anterior
    _logoutTimer?.cancel();

    // Agendar o logout quando o token expirar
    _logoutTimer = Timer(timeRemaining, logout);
  }

  /// Salva o token JWT no SharedPreferences.
  Future<void> _saveTokenToPrefs(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  /// Remove o token JWT do SharedPreferences e notifica os listeners sobre o logout.
  Future<void> logout() async {
    _jwtToken = null;

    // Remover o token do SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');

    _logoutTimer?.cancel(); // Cancelar o timer de logout, se existir
    notifyListeners(); // Notificar os ouvintes sobre o logout
  }

  /// Tenta logar o usuário automaticamente se um token JWT válido estiver salvo.
  Future<void> tryAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    // Verificar se o token existe e se não está expirado
    if (token != null && !JwtDecoder.isExpired(token)) {
      setJwtToken(token); // Definir o token e agendar o logout
    } else {
      logout(); // Token inválido ou expirado, forçar logout
    }
  }
}
