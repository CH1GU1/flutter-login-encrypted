import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:login_encrypted/presentation/reusable_widget/adminMethods.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../reusable_widget/reusable_widget.dart';

class AdminView extends StatefulWidget {
  const AdminView({Key? key}) : super(key: key);

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  List<Map<String, dynamic>> thisUsuarios = [];

  @override
  void initState() {
    super.initState();
    // Aquí asigna los usuarios existentes a la lista 'usuarios'
    cargarUsuarios();
  }

//Metodo que carga la lista de usuarios provenientes de las sharedPref
  Future<void> cargarUsuarios() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usuariosJson = prefs.getString('usuarios');
    if (usuariosJson != null) {
      List<dynamic> usuariosList = json.decode(usuariosJson);
      List<Map<String, dynamic>> usuarios =
          usuariosList.map((item) => Map<String, dynamic>.from(item)).toList();

      print("Los usuarios son: $usuarios");

      setState(() {
        thisUsuarios = usuarios;
      });
    }

    // Utiliza la lista de usuarios cargada aquí
  }

//Metodo que elimina al usuario dado su index en la listview
  String eliminarUsuario(int index) {
    String name = thisUsuarios[index]['nombreUsuario'];
    setState(() {
      eliminarUsuarioDB(name);
      thisUsuarios.removeAt(index);
    });
    return name;
  }

  //Metodo que restablece la contrarseña del usuario dado su index en la listview
  String restablecerPassword(int index) {
    String name = thisUsuarios[index]['nombreUsuario'];
    setState(() {
      eliminarPasswordUsuario(name);
    });
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text("Administrator View"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: thisUsuarios.length,
              itemBuilder: (BuildContext context, int index) {
                final usuario = thisUsuarios[index];
                return ListTile(
                  title: Text(usuario['nombreUsuario']),
                  subtitle: Text(usuario['rol']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.delete_forever),
                          onPressed: () {
                            var thisName = eliminarUsuario(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('User $thisName eliminated!'),
                              ),
                            );
                          }),
                      IconButton(
                          icon: const Icon(Icons.lock_open_rounded),
                          onPressed: () {
                            var thisName = restablecerPassword(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$thisName password reseted'),
                              ),
                            );
                          }),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              eliminarArchivo();
            },
            child: const Text("DELETE DB"),
          ),
        ],
      ),
    );
  }
}
