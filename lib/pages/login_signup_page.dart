import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';

class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginSignUpPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _errorMessage;
  String _firstname;
  String _lastname;  

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_formMode == FormMode.LOGIN) {
          userId = await widget.auth.signIn(_email, _password);
          print('Signed in: $userId');
        } else {
          userId = await widget.auth.signUp(_email, _password);
          widget.auth.sendEmailVerification();
          _showVerifyEmailSentDialog();
          print('Signed up user: $userId');
        }
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null && _formMode == FormMode.LOGIN) {
          widget.onSignedIn();
        }

      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });
      }
    }
  }


  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        /*appBar: new AppBar(
          title: Center(child:new Text('Tracked You!')),
        ),*/
        body: new Stack(
          fit: StackFit.expand,
          children: <Widget>[
            new Image(
            image: new AssetImage("assets/bg.jpg"),
            fit: BoxFit.cover,
            color: Colors.black54,
            colorBlendMode: BlendMode.darken,
          ),
            _showBody(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress(){
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } return Container(height: 0.0, width: 0.0,);

  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                _changeFormToLogin();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showBody(){
    return 
      Center(
        child: new Container(
          padding: EdgeInsets.all(16.0),
          child: new Form(
            key: _formKey,
            child: _formMode == FormMode.LOGIN
            ? new ListView(
              shrinkWrap: true,
              children: <Widget>[
               _showLogo(),
                _showEmailInput(),
                _showPasswordInput(),
                _showPrimaryButton(),
                _showSecondaryButton(),
                _showErrorMessage(),
              ],
            )
            :new ListView(
              shrinkWrap: true,
              children: <Widget>[
                _showLogo(),
                _showFirstnameInput(),
                _showLastnameInput(),
                _showEmailInput(),
                _showPasswordInput(),
                _showPrimaryButton(),
                _showSecondaryButton(),
                _showErrorMessage(),
              ],
            )
          )),
      );
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child:  Image.asset("assets/flutter-iconcrt(1).png"),
        
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(color: Colors.white),
        autofocus: false,
        decoration: new InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.lightBlue),
            icon: new Icon(
              Icons.mail,
              color: Colors.lightBlue,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value,
      ),
    );
  }

  Widget _showFirstnameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        style: TextStyle(color: Colors.white),
        decoration: new InputDecoration(
            labelText: 'First Name',
            labelStyle: TextStyle( color: Colors.lightBlue),
            icon: new Icon(
              Icons.verified_user,
              color: Colors.lightBlue,
            )),
        validator: (value) => value.isEmpty ? 'First Name can\'t be empty' : null,
        onSaved: (value) =>  _firstname = value,
      ),
    );
  }

  Widget _showLastnameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        style: TextStyle(color: Colors.white),
        autofocus: false,
        decoration: new InputDecoration(
             labelText: 'Last Name',
            labelStyle: TextStyle( color: Colors.lightBlue),
            icon: new Icon(
              Icons.verified_user,
              color: Colors.lightBlue,
            )),
        validator: (value) => value.isEmpty ? 'Last Name can\'t be empty' : null,
        onSaved: (value) =>  _lastname = value,
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        style: TextStyle(color: Colors.white),
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
             labelText: 'Password',
            labelStyle: TextStyle( color: Colors.lightBlue),
            icon: new Icon(
              Icons.lock,
              color: Colors.lightBlue,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _showSecondaryButton() {
    return new FlatButton(
      child: _formMode == FormMode.LOGIN
          ? new Text('Create an account',
              style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300, color: Colors.white))
          : new Text('Have an account? Sign in',
              style:
                  new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300, color: Colors.white)),
      onPressed: _formMode == FormMode.LOGIN
          ? _changeFormToSignUp
          : _changeFormToLogin,
    );
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.lightBlue,
            child: _formMode == FormMode.LOGIN
                ? new Text('Login',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white))
                : new Text('Create account',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _validateAndSubmit,
          ),
        ));
  }
}
