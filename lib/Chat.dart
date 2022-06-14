

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatefulWidget {
  @override
  State<Chat> createState() => _ChatState();
  var nm = "";
  var pic = "";
  var email = "";
  var receiverid="";

  Chat({this.nm, this.pic, this.email,this.receiverid});
}

class _ChatState extends State<Chat> {


  var senderid="";

  getlogin() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      senderid=prefs.get("senderid").toString();
    });
  }

  TextEditingController _msg =TextEditingController();
  
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getlogin();
  }

  final TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool emojiShowing = false;

  _onEmojiSelected(Emoji emoji) {
    _controller
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
  }

  _onBackspacePressed() {
    _controller
      ..text = _controller.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50), // Set this height
          child: Container(
            color: Colors.orange,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    IconButton(
                        iconSize: 20,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back_ios)),
                    SizedBox(
                      height: 50,
                      child: VerticalDivider(
                        color: Colors.black,
                        thickness: 3,
                        indent: 5,
                        endIndent: 0,
                        width: 0,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.pic),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.nm,
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("Users").doc(senderid)
                      .collection("Chats").doc(widget.receiverid).collection("messages")
                      .orderBy("timestamp",descending: true).snapshots(),
                  builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot)
                  {
                    if(snapshot.hasData)
                      {
                        if(snapshot.data.size<=0)
                          {
                            return Center(child: Text("No Messages"),);
                          }
                        else
                          {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView(
                                controller: _scrollController,
                                reverse: true,
                                children: snapshot.data.docs.map((document){
                                  if(document["senderid"]==senderid)
                                    {
                                      return Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          margin: EdgeInsets.all(10.0),
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(document["msg"],style: TextStyle(color: Colors.white),),
                                          color: Colors.red,
                                        ),
                                      );
                                    }
                                  else
                                    {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          margin: EdgeInsets.all(10.0),
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(document["msg"],style: TextStyle(color: Colors.white),),
                                          color: Colors.red.shade900,
                                        ),
                                      );
                                    }
                                }).toList(),
                              ),
                            );
                          }
                      }
                    else
                      {
                        return Center(child: CircularProgressIndicator(),);
                      }
                  },
                ),
              ),
              Container(
                child: Row(children: [
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          emojiShowing = !emojiShowing;
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msg,
                      decoration: InputDecoration(
                          hintText: "Type Something...",
                          hintStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.photo_camera, color: Colors.blueAccent),
                    onPressed: () {},
                  ),
                  SizedBox(
                    width: 0,
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.blueAccent),
                    onPressed: () {

                      showModalBottomSheet(

                      );
                    },
                  ),
                  SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        color: Colors.blueAccent, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: () async{
                        // print("Receiver Id :"+widget.receiverid);
                        // print("Sener Id :"+senderid);
                        
                        var message = _msg.text.toString();
                        
                      if(message.length>=1)
                        {
                          await FirebaseFirestore.instance.collection("Users").doc(senderid)
                              .collection("Chats").doc(widget.receiverid).collection("messages").add({
                            "senderid":senderid,
                            "receiverid":widget.receiverid,
                            "msg":message,
                            "type":"text",
                            "timestamp":DateTime.now().millisecondsSinceEpoch
                          }).then((value) async{
                            await FirebaseFirestore.instance.collection("Users").doc(widget.receiverid)
                                .collection("Chats").doc(senderid).collection("messages").add({
                              "senderid":senderid,
                              "receiverid":widget.receiverid,
                              "msg":message,
                              "type":"text",
                              "timestamp":DateTime.now().millisecondsSinceEpoch
                            }).then((value){
                              _msg.text="";
                              _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(microseconds: 300), curve: Curves.easeOut);
                            });
                          });
                        }
                    },
                    ),
                  ),
                ]
                ),
              ),
            ],
          ),
        )
    );
  }
}
