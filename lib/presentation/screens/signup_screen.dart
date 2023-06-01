import 'package:flutter/material.dart';
import 'package:login_encrypted/presentation/reusable_widget/reusable_widget.dart';
import 'package:login_encrypted/presentation/screens/signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  bool isAdmin = false; // Variable para almacenar el estado del checkbox

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.blue[500],
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Enter Email", Icons.email_rounded, false,
                    _emailTextController),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Enter Password", Icons.password_rounded,
                    true, _passwordTextController),
                const SizedBox(
                  height: 40,
                ),
                Checkbox(
                  value: isAdmin,
                  onChanged: (value) {
                    setState(() {
                      isAdmin = value ?? false;
                    });
                  },
                ),
                const Text("Administrator?"),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(90)),
                  child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await _register(_emailTextController,
                            _passwordTextController, isAdmin);

                        navigator.push(MaterialPageRoute(
                            builder: (context) => const LoginForm()));
                      },
                      child: const Text("SIGN UP")),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: 30,
                  margin: const EdgeInsets.fromLTRB(0, 200, 0, 20),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(90)),
                  child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await eliminarArchivo();
                        navigator.push(MaterialPageRoute(
                            builder: (context) => const LoginForm()));
                      },
                      child: const Text("DELETE DB")),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _register(TextEditingController emailTextController,
    TextEditingController passwordTextController, bool admin) async {
  var email = emailTextController.text;
  var password = passwordTextController.text;
  var role = "Admin";
  if (!admin) {
    role = "User";
  }

  await generatePasswordHashComplete(password, role, email);
}
