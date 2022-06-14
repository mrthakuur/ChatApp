import 'package:chatapp/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LoginWithGoogle extends StatefulWidget {

  @override
  State<LoginWithGoogle> createState() => _LoginWithGoogleState();
}

class _LoginWithGoogleState extends State<LoginWithGoogle> {

  FirebaseAuth auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  checklogin()async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("email"))
    {
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomePage()));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checklogin();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: SafeArea(
        child:SingleChildScrollView(
      child: Column(
        children: [
      SizedBox(height: 450,),
       Container(
         margin: EdgeInsets.only(left: 20.0,right: 20.0),
         child:  Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Expanded(
                 child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                         primary: Colors.purple,
                         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                         textStyle: TextStyle(
                             fontSize: 12,
                             fontWeight: FontWeight.bold)),
                     child: Text("Login"),
                     onPressed: ()async {
                       final GoogleSignIn googleSignIn = GoogleSignIn();
                       final GoogleSignInAccount googleSignInAccount = await googleSignIn
                           .signIn();
                       if (googleSignInAccount != null) {
                         final GoogleSignInAuthentication googleSignInAuthentication =
                         await googleSignInAccount.authentication;
                         final AuthCredential authCredential = GoogleAuthProvider
                             .credential(
                             idToken: googleSignInAuthentication.idToken,
                             accessToken: googleSignInAuthentication.accessToken);
                         // Getting users credential
                         UserCredential result = await auth.signInWithCredential(
                             authCredential);
                         User user = result.user;
                         var name = user.displayName.toString();
                         var emailid = user.email.toString();
                         var photo = user.photoURL.toString();
                         var googleid = user.uid.toString();

                         SharedPreferences prefs = await SharedPreferences.getInstance();
                         prefs.setString("name", name);
                         prefs.setString("email", emailid);
                         prefs.setString("photo", photo);
                         prefs.setString("id", googleid);

                         await FirebaseFirestore.instance.collection("Users").where("Email",isEqualTo: emailid)
                             .get().then((documents)async{
                           if(documents.size<=0)
                           {
                             await FirebaseFirestore.instance
                                 .collection("Users")
                                 .add({
                               "Name": name,
                               "Photo":photo,
                               "Email":emailid,
                               "Id":googleid,
                             }).then((document) {

                               prefs.setString("senderid", document.id.toString());


                               Navigator.of(context).pop();
                               Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomePage()));
                             });
                           }
                           else
                           {


                             prefs.setString("senderid",documents.docs.first.id.toString());

                             Navigator.of(context).pop();
                             Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomePage()));
                           }
                         });
                       };

                     }
                 ),
             )
           ],

         ),
       )
        ],
      ),
        ) ,
      ),
    );
  }
}
