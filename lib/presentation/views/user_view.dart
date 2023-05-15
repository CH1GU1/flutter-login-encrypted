import 'package:flutter/material.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false, //Esto quita la flecha hacia atrás
            backgroundColor: Colors.deepPurpleAccent,
            title: const Text("User View")),
        body: Center(
            child: Column(
          children: const [
            Text("¡Bienvenido a User!",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 35))
          ],
        )));
  }
}
