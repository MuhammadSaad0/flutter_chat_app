import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(String email, String username, String password,
      bool isLogin, BuildContext ctx) submitFn;
  AuthForm(this.submitFn);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _userEmail = "";
  var _userName = "";
  var _userPassword = "";
  var _waiting = false;

  void _trySubmit() async {
    final FormValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (FormValid) {
      _formKey.currentState.save();
      setState(() {
        _waiting = true;
      });
    }
    await widget.submitFn(_userEmail.trim(), _userName.trim(),
        _userPassword.trim(), _isLogin, context);
    setState(() {
      _waiting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  key: ValueKey("email"),
                  validator: (value) {
                    if (value.isEmpty || !value.contains("@")) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userEmail = value;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      label: Text(
                        "Email Address",
                        style: TextStyle(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink))),
                ),
                SizedBox(
                  height: 5,
                ),
                if (!_isLogin)
                  TextFormField(
                    key: ValueKey("username"),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Please enter a username";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userName = value;
                    },
                    decoration: InputDecoration(
                        label: Text(
                          "Username",
                          style: TextStyle(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.pink))),
                  ),
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  key: ValueKey("password"),
                  validator: (value) {
                    if (value.isEmpty || value.length < 7) {
                      return "Password must be at least 7 characters long";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userPassword = value;
                  },
                  decoration: InputDecoration(
                      label: Text(
                        "Password",
                        style: TextStyle(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink))),
                  obscureText: true,
                ),
                SizedBox(
                  height: 12,
                ),
                if (!_waiting)
                  ElevatedButton(
                    onPressed: _trySubmit,
                    child: Text(_isLogin ? "Log In" : "Sign Up"),
                  ),
                if (!_waiting)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(_isLogin
                        ? "Create New Account"
                        : "I already have an account "),
                  ),
                if (_waiting)
                  Center(
                    child: CircularProgressIndicator(
                      color: Colors.pink,
                    ),
                  )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
