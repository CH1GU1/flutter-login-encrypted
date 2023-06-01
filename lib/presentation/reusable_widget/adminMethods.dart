import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> eliminarPasswordUsuario(String nombreUsuario) async {
  //Se obtiene el direcotrio raiz donde se almacenan los datos generados por el usuario
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
      usuario['salt'] = "";
      usuario['hash'] = "";
      // Resetea la contraseña del usuario
      break;
    }
  }

  // Convierte la lista de usuarios actualizada a JSON
  String usuariosActualizados = json.encode(usuarios);

  // Guarda los cambios en el archivo JSON
  file.writeAsStringSync(usuariosActualizados);
}

Future<void> eliminarUsuarioDB(String nombreUsuario) async {
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
      usuarios.remove(usuario);
      // Borra al usuario
      break;
    }
  }

  // Convierte la lista de usuarios actualizada a JSON
  String usuariosActualizados = json.encode(usuarios);

  // Guarda los cambios en el archivo JSON
  file.writeAsStringSync(usuariosActualizados);
}
