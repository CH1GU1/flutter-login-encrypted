import 'package:flutter/material.dart';
import 'package:login_encrypted/presentation/reusable_widget/userMethods_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../reusable_widget/adminMethods.dart';

class UserView extends StatefulWidget {
  const UserView({Key? key}) : super(key: key);

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  Map<String, dynamic>?
      thisActiveUser; // Variable de instancia para almacenar el activeUser

  late String _lastLoginDate = "";
  late String _userName = "";
  late TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Obtener la última fecha de inicio de sesión del usuario (suponiendo que se guarda en SharedPreferences)
    loadLastLoginDate();
  }

  //Metodo que carga la ultima fecha de acceso del usuario en la vista
  Future<void> loadLastLoginDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? activeUser = prefs.getStringList('activeUser');
    print("ActiveUser: $activeUser");
    if (activeUser != null) {
      thisActiveUser = {
        'nombreUsuario': activeUser[0],
        'rol': activeUser[1],
        'salt': activeUser[2],
        'hash': activeUser[3],
        'ultimoAcceso': activeUser[4],
      };

      //Se actualiza el usuario actual con la fecha actual dado a que se acaba de loguear
      Map<String, dynamic>? updateActiveUser;
      updateActiveUser = {
        'nombreUsuario': thisActiveUser!["nombreUsuario"],
        'rol': thisActiveUser!["rol"],
        'salt': thisActiveUser!["salt"],
        'hash': thisActiveUser!["hash"],
        'ultimoAcceso': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      print("ActiveUserBeforeLoging: $thisActiveUser");

      //Correccion horaria del timestamp debido a que por defecto está en hora UTC, y en Colombia se usa UTC-5
      int intValue = int.parse(thisActiveUser!['ultimoAcceso']);
      Duration offset = const Duration(hours: 5); // Duración de 5 horas UTC-5
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(intValue);
      DateTime subtractedDateTime = dateTime.subtract(offset);
      //Se formatean la fecha en dia, mes, año, hora, minutos y segundos.
      String formattedDate =
          DateFormat('dd/MM/yyyy HH:mm:ss').format(subtractedDateTime);

      //Se invoca el llamado a actualizar lo que haya cambiado en el widget
      setState(() {
        _lastLoginDate = formattedDate;
        _userName = thisActiveUser!['nombreUsuario'];
      });

      //Se actualiza el usuario actual con la hora de loggin actual para ser mostrada la proxima vez al siguiente login
      thisActiveUser = updateActiveUser;
      var timeNow = DateTime.now().millisecondsSinceEpoch;
      await actualizarFechaAccesoUsuario(
          thisActiveUser!['nombreUsuario'].toString(), timeNow.toString());

      print("UpdatedActiveUserAfterLoging: $thisActiveUser");
    }
  }

  //Metodo que cambia la contraseña del usuario
  Future<void> changePassword() async {
    String newPassword = passwordController.text;

    // Lógica para cambiar la contraseña del usuario
    if (newPassword.isNotEmpty) {
      //Se genera la salt y hash de la contraseña en texto plano a cambiar
      var response = await generatePasswordHashUser(newPassword);
      //print("Respuesta New Pass: $response");

      var salt = response['salt'];
      var hash = response['hash'];

      print("Respuesta New Salt: $salt");
      print("Respuesta New Hash: $hash");

      //Se valida que el usuario exista en los sahredPref, se procede a cambiar su salt y hash
      if (thisActiveUser != null) {
        print("ActiveUserAntes $thisActiveUser");
        Map<String, dynamic>? newActiveUser;
        newActiveUser = {
          'nombreUsuario': thisActiveUser!["nombreUsuario"],
          'rol': thisActiveUser!["rol"],
          'salt': salt,
          'hash': hash,
          'ultimoAcceso': thisActiveUser!["ultimoAcceso"],
        };
        //Se actualiza el usuario actual
        thisActiveUser = newActiveUser;
        print("ActiveUserDespues $thisActiveUser");
        //thisActiveUser;

        //Se invoca el metodo actualizarPasswordUsuario para actualizar la contraseña en el archivo de datos.txt
        await actualizarPasswordUsuario(
            thisActiveUser!['nombreUsuario'].toString(), salt, hash);
      }
    }

    // Mostrar un mensaje de éxito o error

    // Limpiar el campo de texto
    passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, //Esto quita la flecha hacia atrás
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text("User View"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text(
                "¡Bienvenido $_userName!",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 35),
              ),
              const SizedBox(height: 60),
              Text(
                "Última fecha de inicio de sesión: \n\n$_lastLoginDate",
                style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: changePassword,
                child: const Text('Cambiar contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
