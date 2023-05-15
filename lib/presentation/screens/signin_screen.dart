import 'package:flutter/material.dart';
import 'package:login_encrypted/presentation/screens/signup_screen.dart';
import 'package:login_encrypted/presentation/views/admin_view.dart';
import 'package:login_encrypted/presentation/views/user_view.dart';

import '../reusable_widget/reusable_widget.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late String _email;
  late String _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 90),
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('images/login.png'),
              ),
              const Text(
                'Login',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 50),
              ),
              const Divider(
                height: 20,
              ),
              const Text(
                'Seguridad 2023-1',
                style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 20, letterSpacing: 2),
              ),
              SizedBox(
                width: 160,
                height: 40,
                child: Divider(
                  color: Colors.blueGrey[600],
                ),
              ),
              TextField(
                enableInteractiveSelection: false,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    hintText: 'Email',
                    labelText: 'Type Email',
                    suffixIcon: Icon(Icons.verified_user_outlined),
                    border: OutlineInputBorder()),
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              const Divider(
                height: 20,
              ),
              TextField(
                decoration: const InputDecoration(
                    hintText: 'Password',
                    labelText: 'Type Your Password',
                    suffixIcon: Icon(Icons.password_outlined),
                    border: OutlineInputBorder()),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              const Divider(
                height: 20,
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color(0xFF0D47A1),
                              Color(0xFF1986D2),
                              Color(0xFF42A5F5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 25),
                        ),
                        onPressed: _login,
                        child: const Text('Sign In')),
                  ],
                ),
              ),
              const Divider(
                height: 20,
              ),
              signUpOption()
            ],
          )
        ],
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Dont have account?  ",
            style: TextStyle(color: Colors.black87)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()));
          },
          child: const Text("Sign Up",
              style: TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Future<void> _login() async {
    final navigator = Navigator.of(context);
    // Verificar si las credenciales coinciden con las quemadas
    if (_email != '' && _password != '') {
      var resultado = await validarInicioSesion(_email, _password);
      if (resultado.isNotEmpty) {
        // Inicio de sesión exitoso
        print("Inicio de sesión exitoso");
        print("A LOGUEAR: $resultado");

        if (resultado['rol'] == 'Admin') {
          navigator.push(MaterialPageRoute(builder: (context) => const AdminView()));
        } else if (resultado['rol'] == 'User') {
          navigator.push(MaterialPageRoute(builder: (context) => const UserView()));
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error de inicio de sesión'),
              content:
                  const Text('El usuario no existe o credenciales incorrectas'),
              actions: [
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    navigator.pop();
                  },
                ),
              ],
            );
          },
        );
      }
      var map = await recuperarUsuarios();
      var map2 = map.toString();
      print("MAP: $map2");
      //await eliminarArchivo();
    } else {
      // Mostrar un diálogo de error si las credenciales son incorrectas
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error de inicio de sesión'),
            content: const Text('Ingrese todos los campos.'),
            actions: [
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
