import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:conduit_password_hash/conduit_password_hash.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> generatePasswordHashUser(String mypass) async {
// Create PBKDF2NS instance using the SHA256 hash. The default is to use SHA1
  var generator = PBKDF2();
  var salt = generateAsBase64String(10);
  var hash = generator.generateKey(mypass, salt, 1000, 32);
  var encodedHash = base64.encode(hash);
  Map<String, dynamic> response = {'salt': salt, 'hash': encodedHash};

  return response;
}

Future <void> actualizarFechaAccesoUsuario(
    String nombreUsuario, String actualizarAcceso) async {
      
  final directorio = await getApplicationDocumentsDirectory();
  final directorioF = directorio.path;

  // Lee el contenido del archivo txt
  File file = File('$directorioF/datos.txt');
  String jsonString = file.readAsStringSync();

  // Convierte el JSON a una lista de usuarios
   var usuarios = json.decode(jsonString) as List<dynamic>;

  // Busca el usuario que deseas actualizar
  for (var usuario in usuarios) {
    if (usuario['nombreUsuario'] == nombreUsuario) {
      usuario['ultimoAcceso'] = actualizarAcceso;
      // Actualiza la fecha de acceso del usuario
      break;
    }
  }

  // Convierte la lista de usuarios actualizada a JSON
  String usuariosActualizados = json.encode(usuarios);

  // Guarda los cambios en el archivo JSON
  file.writeAsStringSync(usuariosActualizados);
}

Future <void> actualizarPasswordUsuario(
    String nombreUsuario, String salt, String hash) async {
      
  final directorio = await getApplicationDocumentsDirectory();
  final directorioF = directorio.path;

  // Lee el contenido del archivo txt
  File file = File('$directorioF/datos.txt');
  String jsonString = file.readAsStringSync();

  // Convierte el JSON a una lista de usuarios
   var usuarios = json.decode(jsonString) as List<dynamic>;

  // Busca el usuario que deseas actualizar
  for (var usuario in usuarios) {
    if (usuario['nombreUsuario'] == nombreUsuario) {
      usuario['salt'] = salt;
      usuario['hash'] = hash;
      // Actualiza la fecha de acceso del usuario
      break;
    }
  }

  // Convierte la lista de usuarios actualizada a JSON
  String usuariosActualizados = json.encode(usuarios);

  // Guarda los cambios en el archivo JSON
  file.writeAsStringSync(usuariosActualizados);
}
