import 'package:chatapp/Chat.dart';
import 'package:chatapp/LoginWithGoogle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  var name = "", email = "", photo = "", id = "";

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name").toString();
      email = prefs.getString("email").toString();
      photo = prefs.getString("photo").toString();
      id = prefs.getString("id").toString();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Welcome," + name),
        actions: [
          IconButton(
              onPressed: () async {
                AlertDialog alert = AlertDialog(
                  title: Text("Alert"),
                  content: Text("Are You Sure?"),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("No"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.clear();
                        _googleSignIn.signOut();
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LoginWithGoogle()));
                      },
                      child: Text("Yes"),
                    ),
                  ],
                );
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              },
              icon: Icon(Icons.logout)),
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .where("Email", isNotEqualTo: email)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) if (snapshot.data.size <= 0) {
              return Center(child: Text("No Data"));
            } else {
              return ListView(
                  children: snapshot.data.docs.map((document) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Chat(
                              nm: document["Name"],
                              pic: document["Photo"],
                              email: document["Email"],
                              receiverid: document.id.toString(),
                            )));
                  },
                  leading: CircleAvatar(
                      child: Image.network(
                    document["Photo"].toString(),
                    fit: BoxFit.scaleDown,
                  )),
                  title: Text(document["Name"].toString()),
                  subtitle: Text(document["Email"].toString()),
                );
              }).toList());
            }
            else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
