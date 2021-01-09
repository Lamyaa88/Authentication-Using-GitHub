import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Flutter Auth Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription deepLinkSubscription;

//id and secret
  static const String CLIENT_ID = "--------- id -------";
  static const String CLIENT_SECRET =
      "-------------- secret-----------------";

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

//  get cobe

  String getCodeFromGitHubLink(String link) {
    if (link != null) {
      return link.substring(link.indexOf(RegExp('code=')) + 5);
    } else {
      return "";
    }
  }

  UserCredential user;
  @override
  void initState() {
    deepLinkSubscription = getLinksStream().listen((String link) {
      String code = getCodeFromGitHubLink(link);
      loginWithGitHub(code);
    }, cancelOnError: true);
    super.initState();
  }

  @override
  void dispose() {
    deepLinkSubscription;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return FlatButton(
              child: const Text('Sign out'),
              textColor: Theme.of(context).buttonColor,
              onPressed: () async {
                final User user = await firebaseAuth.currentUser;
                if (user == null) {
                  Scaffold.of(context).showSnackBar(const SnackBar(
                    content: Text('No one has signed in.'),
                  ));
                  return;
                }
                signOut();
              },
            );
          })
        ],
      ),
      body: Center(
          child: Column(
        children: [
          FlatButton(
              onPressed: () {
                signInWithGitHub();
              },
              child: Text("Sign In With GitHub")),
          Text((user != null) ? user.user.displayName : "Not logged in"),
        ],
      )),
    );
  }

  void signOut() async {
    await firebaseAuth.signOut().then((value) => {
          setState(() {
            user = null;
          })
        });
  }

  void signInWithGitHub() async {
    const String url = "https://github.com/login/oauth/authorize?client_id=" +
        CLIENT_ID +
        "&scope=user:email";

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }

  void loginWithGitHub(String code) async {
    //Step 4
    final response = await http.post(
      "https://github.com/login/oauth/access_token",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: "{\"client_id\":\"" +
          CLIENT_ID +
          "\",\"client_secret\":\"" +
          CLIENT_SECRET +
          "\",\"code\":\"" +
          code +
          "\"}",
    );
  }
}
