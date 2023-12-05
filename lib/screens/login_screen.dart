import 'package:flutter/material.dart';
import '../widgets/input.dart';
import '../widgets/button.dart';
import '../utils/api_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey for the form
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0x00fafafa),
        ),
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form (
                key: _formKey,
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.asset('lib/assets/images/logo_3plwinner.png'),
                  const SizedBox(height: 32.0),
                  const Text('Sign In',
                      style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey)),
                  const SizedBox(height: 12.0),
                  Input(
                    prefixIcon: const Icon(Icons.person, color: Colors.blueGrey, size: 20.0),
                    hintText: 'Username',
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 8.0),
                  Input(
                    prefixIcon: const Icon(Icons.lock, color: Colors.blueGrey, size: 20.0),
                    hintText: 'Password',
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Button(
                        text: 'Sign In',
                        onPressed: isLoading
                            ? null
                            : () async {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                              errorMessage = '';
                            });
                            final result = await handleSignIn(
                                context,
                                _usernameController.text,
                                _passwordController.text);
                            setState(() {
                              isLoading = false;
                            });
                            if (result != null) {
                              if (result['Error'] == null) {
                                Navigator.pushNamed(context, '/dashboard');
                              }
                              else {
                                setState(() {
                                  errorMessage = result['Error'];
                                });
                              }
                            } else {
                              setState(() {
                                errorMessage =
                                'Could not sign in. Please try again.';
                              });
                            }
                          }
                        },
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Sign In', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
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
