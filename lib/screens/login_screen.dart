import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bin_flutter/addon/signup.dart';
import 'package:smart_bin_flutter/screens/area_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  final _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String email = '';
  String password = '';
  String error = '';
  bool visible = true;
  bool isLoggedIn = false; // Added to track login status

  void passwordVisible() {
    setState(() {
      visible = !visible;
    });
  }

  Future<void> keepLogin(String emailValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', emailValue);
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> removeLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('isLoggedIn');
  }

  Future<bool> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? isLoggedIn = prefs.getBool('isLoggedIn');
    return isLoggedIn ?? false;
  }

  Future<void> logout() async {
    await _auth.signOut();
    await removeLogin();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((uid) {
        keepLogin(email);
        Fluttertoast.showToast(msg: "Login Successfully");
        setState(() {
          isLoggedIn = true;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AreaList()),
        );
      }).catchError((e) {
        Fluttertoast.showToast(msg: e?.message);
        return e;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    /*checkLoginStatus().then((loggedIn) {
      if (loggedIn) {
        setState(() {
          isLoggedIn = true;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AreaList()),
        );
      }
    });*/
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      validator: (value) {
        if (value!.isEmpty) {
          return null;
        }
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return "Invalid Email";
        } else {
          return null;
        }
      },
      autovalidateMode: AutovalidateMode.always,
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        emailController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.mail),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Enter User ID",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: visible,
      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return null;
        }
        if (!regex.hasMatch(value)) {
          return "Please Enter a valid Password (Min 6 characters)";
        }

        return null;
      },
      onSaved: (value) {
        passwordController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.vpn_key),
        suffixIcon: InkWell(
          onTap: passwordVisible,
          child: visible
              ? const Icon(Icons.visibility)
              : const Icon(Icons.visibility_off),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(10),
      color: Colors.redAccent,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          signIn(emailController.text, passwordController.text);
        },
        child: const Text(
          "Login",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    final signupButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(10),
      color: Colors.redAccent,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SignUpView()));
        },
        child: const Text(
          "Signup",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    final guest = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(10),
      color: Color.fromARGB(255, 2, 220, 93),
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AreaList()));
        },
        child: const Text(
          "Guest",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Waste Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 36),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 200,
                      child: Image.asset(
                        "assets/waste_image.png",
                        height: 500,
                        width: 800,
                      ),
                    ),
                    const Text(
                      "Login",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, height: 3),
                    ),
                    const SizedBox(height: 40),
                    emailField,
                    const SizedBox(height: 30),
                    passwordField,
                    const SizedBox(height: 30),
                    loginButton,
                    const SizedBox(height: 10),
                    signupButton,
                    const SizedBox(height: 10),
                    guest,
                    const SizedBox(height: 10),
                    SizedBox(
                      child: ElevatedButton(
                        child: const Icon(Icons.blur_circular),
                        onPressed: () async {
                          final Uri url =
                              Uri.parse('https://watchyourwaste.wa.gov.au/');
                          await launchUrl(
                            url,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
