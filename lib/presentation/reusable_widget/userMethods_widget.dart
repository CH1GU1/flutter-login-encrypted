import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:conduit_password_hash/conduit_password_hash.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic>? activeUser;

Future<void> loadCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

// Recuperar el objeto usuarioReturn
  List<String>? usuarioReturnList = prefs.getStringList('activeUser');

  if (usuarioReturnList != null) {
    Map<String, dynamic> usuarioReturn = {
      'nombreUsuario': usuarioReturnList[0],
      'rol': usuarioReturnList[1],
      'salt': usuarioReturnList[2],
      'hash': usuarioReturnList[3],
      'ultimoAcceso': usuarioReturnList[4],
    };

    // Utiliza el objeto usuarioReturn en tu pantalla
  }
}

  void otroMetodo() {
    if (activeUser != null) {
      // Utiliza activeUser aquí
    }
  }
