import 'package:flutter/material.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, //Esto quita la flecha hacia atrás
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text("Administrator View")
      ),
      body: Center(
            child: Column(
          children: const [
            Text("¡Bienvenido a Admin!",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 35))
          ],
        )));
  }
}
