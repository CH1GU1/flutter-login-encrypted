import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:conduit_password_hash/conduit_password_hash.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Widget para ser reutilizado en diversos momentos de forma personalizable, facilitando la legibilidad y sencillez del codigo
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
      labelStyle: TextStyle(
          color: const Color.fromARGB(255, 105, 103, 103).withOpacity(0.9)),
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

//Metodo que genera el cifrado de la contraseña del usuario a crear y luego lo guarda dado su contraseña, rol y email o username
Future<String> generatePasswordHashComplete(
    String mypass, String rol, String userName) async {
// Se crea la instancia generadora de PBKDF2
  var generator = PBKDF2();
  //Se crea la salt dada una longitud de 10 bytes, que luego es transformada a base64
  var salt = generateAsBase64String(10);
  //Se genera el hash invocando el metodo generateKey de la instancia PBKDF2, este recibe la contraseña en plano, la salt, las iteraciones que se realizarán durante el proceso de generación del hash y el tamaño de la clave resultando en bytes.
  var hash = generator.generateKey(mypass, salt, 1000, 32);
  //Realiza la codificación en base64 del valor contenido en la variable hash
  var encodedHash = base64.encode(hash);
  //Se toma el timestamp actual para ser almacenado como la primera y ultima vez que el usuario ingresó
  var timestampActual = DateTime.now().millisecondsSinceEpoch;
  //Se invoca al metodo de guardar datos en el archivo txt
  await guardarDatos(
      userName, rol, salt, encodedHash, timestampActual.toString());

  return hash.toString();
}

// Obtener la ruta del directorio de almacenamiento específico de la aplicación
Future<String> obtenerRutaArchivo() async {
  final directorio = await getApplicationDocumentsDirectory();
  return directorio.path;
}

// Guardar el usuario en un archivo de texto dado su nombre de usuario o correo, el rol, la salt, el hash de su password y la hora de su ultimo acceso
Future<void> guardarDatos(String nombreUsuario, String rol, String salt,
    String hash, String ultimoAcceso) async {
  //Se obtiene la ruta del archivo invocando al metodo obtenerRutaArchivo
  final rutaArchivo = await obtenerRutaArchivo();
  print("RUTA: $rutaArchivo");
  //Se obtiene el metodo del archivo donde se guardan los usuarios llamado datos.txt
  final archivo = File('$rutaArchivo/datos.txt');

  // Verificar si el archivo ya existe
  if (await archivo.exists()) {
    final contenido = await archivo.readAsString();
    final usuarios = json.decode(contenido) as List<dynamic>;

    // Verificar si el usuario ya existe, de lo contrario, se agrega como nuevo usuario
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
    //Guardar como json el unico usuario en una lista
    final contenido = json.encode([usuario]);

    await archivo.writeAsString(contenido);
  }
}

// Recuperar los usuarios desde el archivo
Future<List<Map<String, dynamic>>> recuperarUsuarios() async {
  final rutaArchivo = await obtenerRutaArchivo();
  final archivo = File('$rutaArchivo/datos.txt');

  //Verificar si el archivo existe, luego se procede a deserializarlo como json
  if (await archivo.exists()) {
    final contenido = await archivo.readAsString();
    final usuarios = json.decode(contenido) as List<dynamic>;

    return usuarios.cast<Map<String, dynamic>>();
  }

  //Si no existe, se retorna una lista vacía
  return [];
}

//Metodo que valida las credenciales del usuario al iniciar sesion
Future<Map<String, dynamic>> validarInicioSesion(
    String nombreUsuario, String password) async {
  final usuarios = await recuperarUsuarios();

  var usuarioReturn = <String, dynamic>{};

  //Se recorren los usuarios provenientes de la lista
  for (var usuario in usuarios) {
    if (usuario['nombreUsuario'] == nombreUsuario) {
      final salt = usuario['salt'] as String;
      final hashAlmacenado = usuario['hash'] as String;

      //Si el usuario existe pero su salt y su hash está vacío es porque desde el administrador se reseteó la contraseña
      if (salt.isEmpty && hashAlmacenado.isEmpty) {
        usuarioReturn = usuario;
        SharedPreferences userPref = await SharedPreferences.getInstance();
        userPref.setStringList('activeUser', [
          usuarioReturn['nombreUsuario'],
          usuarioReturn['rol'],
          usuarioReturn['salt'],
          usuarioReturn['hash'],
          usuarioReturn['ultimoAcceso'],
        ]);

        //Se guarda la lista de usuarios en los sharedPref para poder acceder en toda la aplicacion
        String usuariosJson = json.encode(usuarios);
        userPref.setString('usuarios', usuariosJson);
        break;
      }

      //Se hace la validación de la contraseña suministrada
      final generator = PBKDF2();
      final hashIngresado = generator.generateKey(password, salt, 1000, 32);
      //Se obtiene el hash de la contraseña ingresada formateada en base 64
      final encodedHashIngresado = base64.encode(hashIngresado);

      //Se realiza la comparación del hash ingresado vs el hash almacenado, si coinciden, entonces se le otorga el acceso
      if ((encodedHashIngresado == hashAlmacenado)) {
        print("HASHES IGUALES");
        print("hashAlmacenado: $hashAlmacenado");
        print("encodedHashIngresado: $encodedHashIngresado");

        //Se crea el usuario que el método va a devolver
        usuarioReturn = {
          'nombreUsuario': usuario['nombreUsuario'],
          'rol': usuario['rol'],
          'salt': usuario['salt'],
          'hash': usuario['hash'],
          'ultimoAcceso': usuario['ultimoAcceso'],
        };

        //Se guarda el usuario activo en los sharedPreferences de la aplicacion
        SharedPreferences userPref = await SharedPreferences.getInstance();
        userPref.setStringList('activeUser', [
          usuarioReturn['nombreUsuario'],
          usuarioReturn['rol'],
          usuarioReturn['salt'],
          usuarioReturn['hash'],
          usuarioReturn['ultimoAcceso'],
        ]);
        
        //Se guarda en formato json la lista de los usuarios en los sharedPreferences
        String usuariosJson = json.encode(usuarios);
        userPref.setString('usuarios', usuariosJson);

        // La contraseña coincide, inicio de sesión exitoso y se retona el usuario a loguear
        return usuarioReturn;
      }
    }
  }

  // Si no se encuentra el usuario o la contraseña no coincide, el inicio de sesión falla
  return usuarioReturn;
}

// Eliminar el archivo de los datos de todos los usuarios
Future<void> eliminarArchivo() async {
  final rutaArchivo = await obtenerRutaArchivo();
  final archivo = File('$rutaArchivo/datos.txt');

  if (await archivo.exists()) {
    await archivo.delete();
    print('Archivo eliminado');
  }
}
