import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:conduit_password_hash/conduit_password_hash.dart';

Future<Map<String, dynamic>> generatePasswordHashUser(String mypass) async {

//Se crea la instancia generadora de PBKDF2
  var generator = PBKDF2();
  //Se crea la salt dada una longitud de 10 bytes, que luego es transformada a base64
  var salt = generateAsBase64String(10);
  //Se genera el hash invocando el metodo generateKey de la instancia PBKDF2, este recibe la contraseña en plano, la salt, las iteraciones que se realizarán durante el proceso de generación del hash y el tamaño de la clave resultando en bytes.
  var hash = generator.generateKey(mypass, salt, 1000, 32);
  //Realiza la codificación en base64 del valor contenido en la variable hash
  var encodedHash = base64.encode(hash);
  //Se toma el timestamp actual para ser almacenado como la primera y ultima vez que el usuario ingresó
  Map<String, dynamic> response = {'salt': salt, 'hash': encodedHash};

  return response;
}

//metodo que actualiza la ultia fecha de acceso del usuario dado su usurio y el tiempo en timestamp
Future<void> actualizarFechaAccesoUsuario(
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

//Metodo que actualiza la contrasesña del usuario dado su nombre de usuario, nueva salt y nuevo hash
Future<void> actualizarPasswordUsuario(
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
