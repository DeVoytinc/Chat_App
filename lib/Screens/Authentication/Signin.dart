import 'package:chatapp/Logic/CubitLogic.dart';
import 'package:chatapp/Screens/Authentication/Signup.dart';
// import 'package:chatapp/Screens/HomePage.dart';
import 'package:chatapp/auxilaries/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<GetUsersListCubit>().getSnapshotValue();
    FlutterNativeSplash.remove();
  }

  var email;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  Widget_formField(String field, bool isObscure, TextEditingController controller) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextFormField(
        validator: ((value) {
          if (value == null || value.isEmpty) {
            return "Пожалуста введите $field";
          }
          return null;
        }),
        obscureText: isObscure,
        controller: controller,
        decoration: InputDecoration(label: Text(field), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
      ),
    );
  }

  //Signin:
  void Signin() async {
    _formkey.currentState!.save();

    try {
      context.read<GetUserName>().gotUserName(_userNameController.text);
      UserCredential? user;
      if (context.read<GetUserDataCubit>().state["emailId"] != null) {
        user = await _auth.signInWithEmailAndPassword(
          email: context.read<GetUserDataCubit>().state["emailId"],
          password: _passwordController.text,
        );
      }

      // context.read<AuthCubit>().authSignin();
      if (user != null) {
        context.read<AuthCubit>().authSignin();
      }
    } on FirebaseAuthException catch (e) {
      showError(e.message);
    }
  }

  //Show error:
  showError(String? errorMessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Ошибка"),
            content: Text(errorMessage.toString()),
            actions: <Widget>[
              MaterialButton(
                child: const Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  //Navigators:
  navigateToSignupScreen() {
    Navigator.push(context, MaterialPageRoute(builder: ((context) => const Signup())));
  }

  //Text Editing controllers:
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //Show snackbar:
  SnackBar snackBar = SnackBar(
    duration: const Duration(milliseconds: 1200),
    dismissDirection: DismissDirection.up,
    content: Container(
      decoration: foregroundGradient(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Регистрация",
              style: TextStyle(color: colors1[5], fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircularProgressIndicator(
              color: colors1[5],
            ),
          )
        ],
      ),
    ),
    elevation: 5.0,
    padding: const EdgeInsets.all(5.0),
  );

  @override
  Widget build(BuildContext context) {
    context.read<GetUserDataCubit>().getSnapshotValue(context.read<InputSearchCubit>().state);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: foregroundGradient(),
        ),
        title: const Text(
          "Чат студентов СибАДИ",
          style: TextStyle(fontFamily: 'Alkatra'),
        ),
        actions: const [Icon(Icons.chat_bubble_rounded), SizedBox(width: 20)],
      ),
      body: Container(
        decoration: backgroundGradient(),
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: BlocBuilder<InputSearchCubit, String>(
            builder: (context, state) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 250,
                        height: 250,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Form(
                          key: _formkey,
                          child: Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: TextFormField(
                                  validator: ((value) {
                                    if (value == null || value.isEmpty) {
                                      return "Пожалуйста введите имя";
                                    }
                                    return null;
                                  }),
                                  controller: _userNameController,
                                  onChanged: (value) {
                                    context.read<InputSearchCubit>().startInputing(_userNameController.text);
                                  },
                                  decoration: InputDecoration(label: const Text("Имя"), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.all(30)),
                              Widget_formField("Пароль", true, _passwordController),
                            ],
                          )),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0.0),
                        elevation: 5,
                      ),
                      child: Ink(
                        decoration: foregroundGradient(),
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            constraints: const BoxConstraints(minWidth: 88.0),
                            child: const Text(
                              "Вход",
                              textAlign: TextAlign.center,
                            )),
                      ),
                      onPressed: () async {
                        if (_formkey.currentState!.validate()) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (!context.read<GetUsersListCubit>().state.contains(context.read<InputSearchCubit>().state)) {
                            showError("Имя пользователя не существует");
                          }
                          Signin();

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                    ),
                    const Padding(padding: EdgeInsets.all(10.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Нет акаунта?"),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () => navigateToSignupScreen(),
                          child: Text(
                            "Регистрация",
                            style: TextStyle(color: colors1[1]),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
