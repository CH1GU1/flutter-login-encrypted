import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:conduit_password_hash/conduit_password_hash.dart';
import 'package:flutter/material.dart';

TextField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.black,
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: const Color.fromARGB(255, 41, 81, 114),
      ),
      labelText: text,
      labelStyle:
          TextStyle(color: const Color.fromARGB(255, 105, 103, 103).withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.blue.withOpacity(0.25),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

Future<String> generatePasswordHashComplete(
    String mypass, String rol, String userName) async {
// Create PBKDF2NS instance using the SHA256 hash. The default is to use SHA1
  var generator = PBKDF2();
  var salt = generateAsBase64String(10);
  var hash = generator.generateKey(mypass, salt, 1000, 32);
  var encodedHash = base64.encode(hash);
  var timestampActual = DateTime.now().millisecondsSinceEpoch;
  await guardarDatos(
      userName, rol, salt, encodedHash, timestampActual.toString());

  return hash.toString();
}

// Obtener la ruta del directorio de almacenamiento específico de la aplicación
Future<String> obtenerRutaArchivo() async {
  final directorio = await getApplicationDocumentsDirectory();
  return directorio.path;
}

// Guardar los datos en un archivo de texto
Future<void> guardarDatos(String nombreUsuario, String rol, String salt,
    String hash, String ultimoAcceso) async {
  final rutaArchivo = await obtenerRutaArchivo();
  print("RUTA: $rutaArchivo");
  final archivo = File('$rutaArchivo/datos.txt');

  // Verificar si el archivo ya existe
  if (await archivo.exists()) {
    final contenido = await archivo.readAsString();
    final usuarios = json.decode(contenido) as List<dynamic>;

    // Verificar si el usuario ya existe
    if (usuarios.any((usuario) => usuario['nombreUsuario'] == nombreUsuario)) {
      print('EL USUARIO "$nombreUsuario" YA EXISTE');
      return;
    } else {
      // Agregar nuevo usuario a la lista
      usuarios.add({
        'nombreUsuario': nombreUsuario,
        'rol': rol,
        'salt': salt,
        'hash': hash,
        'ultimoAcceso': ultimoAcceso,
      });

      // Guardar la lista actualizada en formato JSON
      await archivo.writeAsString(json.encode(usuarios));
    }
  } else {
    // Si el archivo no existe, crear uno nuevo con el usuario actual
    final usuario = {
      'nombreUsuario': nombreUsuario,
      'rol': rol,
      'salt': salt,
      'hash': hash,
      'ultimoAcceso': ultimoAcceso,
    };
    final contenido = json.encode([usuario]);

    await archivo.writeAsString(contenido);
  }
}

// Recuperar los usuarios desde el archivo
Future<List<Map<String, dynamic>>> recuperarUsuarios() async {
  final rutaArchivo = await obtenerRutaArchivo();
  final archivo = File('$rutaArchivo/datos.txt');

  if (await archivo.exists()) {
    final contenido = await archivo.readAsString();
    final usuarios = json.decode(contenido) as List<dynamic>;

    return usuarios.cast<Map<String, dynamic>>();
  }

  return [];
}

Future<Map<String, dynamic>> validarInicioSesion(
    String nombreUsuario, String password) async {
  final usuarios = await recuperarUsuarios();
  var usuarioReturn = <String, dynamic>{};

  for (var usuario in usuarios) {
    if (usuario['nombreUsuario'] == nombreUsuario) {
      final salt = usuario['salt'] as String;
      final hashAlmacenado = usuario['hash'] as String;

      final generator = PBKDF2();
      final hashIngresado = generator.generateKey(password, salt, 1000, 32);
      final encodedHashIngresado = base64.encode(hashIngresado);

      //print("hashAlmacenado: $hashAlmacenado");
      //print("encodedHashIngresado: $encodedHashIngresado");
      if (encodedHashIngresado == hashAlmacenado) {
        print("HASHES IGUALES");
        print("hashAlmacenado: $hashAlmacenado");
        print("encodedHashIngresado: $encodedHashIngresado");
        usuarioReturn = {
          'nombreUsuario': usuario['nombreUsuario'],
          'rol': usuario['rol'],
          'salt': usuario['salt'],
          'hash': usuario['hash'],
          'ultimoAcceso': usuario['ultimoAcceso'],
        };
        
        // La contraseña coincide, inicio de sesión exitoso
        return usuarioReturn;
      }
    }
  }

  // Si no se encuentra el usuario o la contraseña no coincide, el inicio de sesión falla
  return usuarioReturn;
}

// Eliminar el archivo
Future<void> eliminarArchivo() async {
  final rutaArchivo = await obtenerRutaArchivo();
  final archivo = File('$rutaArchivo/datos.txt');

  if (await archivo.exists()) {
    await archivo.delete();
    print('Archivo eliminado');
  }
}
