import 'package:chatnew/controller/chat_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatelessWidget {
  ChatController controller = Get.put(ChatController());

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text("${controller.arg["email"]}", style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection("users").doc(controller.arg["receiver_id"]).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var otherUser = snapshot.data?.data() as Map<String, dynamic>;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (otherUser["isOnline"] == true) ? "Online" : "Offline",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: (otherUser["isOnline"] == true) ? Colors.green : Colors.red,
                        ),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/chat_bg.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("message").orderBy('time').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var msgList = snapshot.data?.docs ?? [];
                      controller.jumpToEnd();
                      return ListView.builder(
                        itemCount: msgList.length,
                        controller: controller.scrollController,
                        itemBuilder: (context, index) {
                          var msg = msgList[index];
                          Map<String, dynamic> data = msg.data() as Map<String, dynamic>;
                          bool isSender = data["sender"] == FirebaseAuth.instance.currentUser?.uid;
                          if (data["chat_room_id"] != controller.arg["chat_room_id"]) {
                            return SizedBox.shrink();
                          }
                          return Align(
                            alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSender ? Colors.teal : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width / 1.2),
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "${data["msg"]}",
                                style: TextStyle(color: isSender ? Colors.white : Colors.black),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.msgController,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: IconButton(
                    onPressed: () async {
                      if (controller.msgController.text.trim().isNotEmpty) {
                        if (controller.editMsgId.isNotEmpty) {
                          await FirebaseFirestore.instance.collection("message").doc(controller.editMsgId.value).update({
                            "msg": "${controller.msgController.text} (Edited)",
                          });
                          controller.editMsgId.value = "";
                        } else {
                          await FirebaseFirestore.instance.collection("message").add({
                            "msg": controller.msgController.text,
                            "time": DateTime.now(),
                            "chat_room_id": controller.arg["chat_room_id"],
                            "sender": FirebaseAuth.instance.currentUser?.uid,
                            "receiver": controller.arg["receiver_id"]
                          });
                          await FirebaseFirestore.instance.collection("chat_room").doc(controller.arg["chat_room_id"]).update({
                            "last_msg": controller.msgController.text,
                            "unread": FieldValue.increment(1),
                          });
                          controller.sendNotification(controller.msgController.text);
                        }
                        controller.msgController.clear();
                      }
                    },
                    icon: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
