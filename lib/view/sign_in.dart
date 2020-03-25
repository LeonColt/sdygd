import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:progress_indicator_button/progress_button.dart';

part 'sign_in.g.dart';

class SignIn extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => new _SignInState();
}

class _SignInState extends State<SignIn> {
    
    _SignInController _controller;
    
    @override
    Widget build(BuildContext context) => new Scaffold(
        body: new Padding(
            padding: const EdgeInsets.symmetric( horizontal: 20.0 ),
            child: new Center(
                child: new ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                        new Observer(
                            builder: ( _ ) => new TextField(
                                decoration: new InputDecoration(
                                    errorText: _controller.formErrorState.email,
                                    prefixIcon: const Icon( Icons.email ),
                                    labelText: "Email",
                                ),
                                onChanged: ( final String text ) => _controller.email = text,
                            ),
                        ),
                        new SizedBox( height: 20.0, ),
                        new Observer(
                            builder: ( _ ) => new TextField(
                                decoration: new InputDecoration(
                                    errorText: _controller.formErrorState.password,
                                    prefixIcon: const Icon( Icons.lock_open ),
                                    suffix: new IconButton(
                                        icon: _controller.obscurePassword ? const Icon( Icons.visibility ) : const Icon( Icons.visibility_off ),
                                        onPressed: () => _controller.obscurePassword = !_controller.obscurePassword,
                                    ),
                                    labelText: "Kata Sandi",
                                ),
                                obscureText: _controller.obscurePassword,
                                onChanged: ( final String text ) => _controller.password = text,
                            ),
                        ),
                        new SizedBox( height: 40.0, ),
                        new ProgressButton(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            child: const Text("Masuk", style: const TextStyle( color: Colors.white, ),),
                            onPressed: _controller.signIn,
                        ),
                    ],
                ),
            ),
        ),
    );
    
    @override
    void initState() {
        _controller = new _SignInController( context );
        super.initState();
    }
    
    @override
    void dispose() {
        _controller.dispose();
        super.dispose();
    }
}

class _SignInController = _SignInControllerBase with _$_SignInController;

abstract class _SignInControllerBase with Store {
    final formErrorState = new _FormErrorState();
    final _reactionDisposers = new List<ReactionDisposer>();
    final BuildContext context;
    
    @observable String email = "";
    @observable String password = "";
    @observable bool obscurePassword = true;
    
    _SignInControllerBase(this.context) {
        _reactionDisposers.addAll([
            reaction( ( _ ) => email, _validateEmail ),
            reaction( ( _ ) => password, _validatePassword ),
        ]);
    }
    
    @action void _validateEmail( final String email ) => formErrorState.email = email.isEmpty ? "Email tidak boleh kosong" : null;
    
    @action void _validatePassword( final String password ) => formErrorState.password = password.isEmpty ? "Password tidak boleh kosong" : null;
    
    @action Future<void> signIn( AnimationController controller ) async {
        _validateEmail(email);
        _validatePassword(password);
        if ( formErrorState.hasErrors ) return;
        await controller.forward();
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        await controller.reverse();
    }
    
    void dispose() {
        for ( final disposer in _reactionDisposers ) disposer();
    }
}

class _FormErrorState = _FormErrorStateBase with _$_FormErrorState;

abstract class _FormErrorStateBase with Store {
    @observable
    String email;
    @observable
    String password;
    
    @computed
    bool get hasErrors => email != null || password != null;
}
