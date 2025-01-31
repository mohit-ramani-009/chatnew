import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal,
        title: Text("Select user"),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection("users").get().asStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List users = snapshot.data?.docs ?? [];
              return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    return ListTile(
                      title: Text("${user["email"]}"),
                      onTap: () async {
                        var chatroom = await FirebaseFirestore.instance
                            .collection("chat_room")
                            .where("user_a_sender",
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser?.uid)
                            .where("user_b_receiver", isEqualTo: user["id"]);
                        QuerySnapshot<Map<String, dynamic>> data =
                            await chatroom.get();
                        String chatroomId = "";
                        if (data.docs.isEmpty) {
                          DocumentReference dataAdd = await FirebaseFirestore.instance.collection("chat_room").add({
                            "user_a_sender":FirebaseAuth.instance.currentUser?.uid,
                            "user_b_receiver":user["id"],
                            "user_a_email":FirebaseAuth.instance.currentUser?.email,
                            "user_b_email":user["email"],
                            "users":[FirebaseAuth.instance.currentUser?.uid,user["id"]],
                            "last_msg":""
                          });
                          var chatRef= await dataAdd.get();
                          chatroomId=chatRef.id;
                        }
                        else {
                          chatroomId=data.docs.first.id;
                        }

                        Get.toNamed("chat",arguments: {
                          "email":"${user["email"]}",
                          "chatroomId" : chatroomId,
                          "receiver_id":user["id"],
                          // "fcmToken":user["fcmToken"]//notification
                        });
                      },
                    );
                  });
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
