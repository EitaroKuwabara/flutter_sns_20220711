import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sns_20220711/utils/authentication.dart';
import 'package:flutter_sns_20220711/utils/firestore/users.dart';
import 'package:flutter_sns_20220711/utils/function_utils.dart';
import 'package:flutter_sns_20220711/utils/widget_utils.dart';
import 'package:flutter_sns_20220711/view/start_up/check_email_page.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/account.dart';
import '../screen.dart';

class CreateAccountPage extends StatefulWidget {
  final bool isSignInWithGoogle;
  CreateAccountPage({this.isSignInWithGoogle=false});
  // const CreateAccountPage({Key? key, isSignInWithGoogle}) : super(key: key);

  @override
  // State<CreateAccountPage> createState() => _CreateAccountPageState();
  _CreateAccountPageState createState() => _CreateAccountPageState();

}

class _CreateAccountPageState extends State<CreateAccountPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController selfIntroductionController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  File? image;
  ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.createAppBar("新規登録"),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () async {
                  var result = await FunctionUtils.getImageFromGallery();
                  if (result != null) {
                    setState(() {
                      image = File(result.path);
                    });
                  }
                },
                child: CircleAvatar(
                  foregroundImage: image == null ? null : FileImage(image!),
                  radius: 40,
                  child: const Icon(Icons.add),
                ),
              ),
              Container(
                width: 300,
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "NAME"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                  width: 300,
                  child: TextField(
                    controller: userIdController,
                    decoration: const InputDecoration(hintText: "USER ID"),
                  ),
                ),
              ),
              Container(
                width: 300,
                child: TextField(
                  controller: selfIntroductionController,
                  decoration:
                      const InputDecoration(hintText: "SELF INTRODUCTION"),
                ),
              ),
              widget.isSignInWithGoogle ? Container() : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Container(
                      width: 300,
                      child: TextField(
                        controller: emailController,
                        decoration: const InputDecoration(hintText: "EMAIL"),
                      ),
                    ),
                  ),
                  Container(
                    width: 300,
                    child: TextField(
                      controller: passController,
                      decoration: const InputDecoration(hintText: "PASSWORD"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),
              ElevatedButton(
                  onPressed: () async {
                    // 全部入力されていたら戻れる
                    if (nameController.text.isNotEmpty &&
                        userIdController.text.isNotEmpty &&
                        selfIntroductionController.text.isNotEmpty &&
                        image != null) {
                      if(widget.isSignInWithGoogle){
                        var _result = await createAccount(Authentication.currentFirebaseUser!.uid);
                        if(_result==true){
                          await UserFirestore.getUser(Authentication.currentFirebaseUser!.uid);
                          Navigator.pop(context);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Screen()));
                        }
                      }
                      var result = await Authentication.signUp(
                          email: emailController.text,
                          pass: passController.text);
                      if (result is UserCredential) {
                        var _result = await createAccount(result.user!.uid);
                        if (_result == true) {
                          result.user!.sendEmailVerification();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CheckEmailPage(
                                      email: emailController.text,
                                      pass: passController.text)));
                        }
                      }
                    }
                  },
                  child: const Text("アカウント作成"))
            ],
          ),
        ),
      ),
    );
  }
  Future<dynamic>createAccount(String uid)async{
    String imagePath = await FunctionUtils.uploadImage(
        uid, image!);
    Account newAccount = Account(
      id: uid,
      name: nameController.text,
      userId: userIdController.text,
      selfIntroduction: selfIntroductionController.text,
      imagePath: imagePath,
    );
    var _result = await UserFirestore.setUser(newAccount);
    return _result;
  }
}
