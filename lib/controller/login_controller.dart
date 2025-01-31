import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  RxBool isLoad = false.obs;

  Future<void> login() async {
    isLoad.value = true;
    try {
      UserCredential user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      Get.toNamed("home_page");
      print(" user ===> ${user.user}");
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.code);
    } catch (e) {
      print("error $e");
    }
    isLoad.value = false;
  }

  Future<void> register() async {
    isLoad.value = true;
    try {
      UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      if (userCred.user != null) {
        await FirebaseFirestore.instance.collection("users").doc(userCred.user?.uid).set(
          {
            "id": userCred.user?.uid,
            "email": userCred.user?.email ?? "",
          },
        );

        // await FirebaseFirestore.instance.collection("users").add(
        //   {
        //     "id": userCred.user?.uid,
        //     "email": userCred.user?.email ?? "",
        //   },
        // );
        Get.toNamed("home_page");
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.code);
      print("FirebaseAuthException $e");
    } catch (e) {
      print("Exception $e");
    }
    isLoad.value = false;
  }
}