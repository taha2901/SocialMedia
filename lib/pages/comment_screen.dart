import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:social_media/colors/app_color.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/provider/user_provider.dart';
import 'package:social_media/services/cloud.dart';

class CommentScreen extends StatefulWidget {
  final postId;
  const CommentScreen({super.key, required this.postId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  TextEditingController commentCon = TextEditingController();

  postComment(String uid, String profilePic, String displayName,
      String username) async {
    String res = await CloudMethods().commentToPost(
      postId: widget.postId,
      uid: uid,
      commentText: commentCon.text,
      profilePic: profilePic,
      displayName: displayName,
      username: username,
    );
    if (res == "success") {
      setState(() {
        commentCon.text = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel userData = Provider.of<UserProvider>(context).userModel!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('comments')
                      .snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        dynamic data = snapshot.data.docs[index];
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kWhiteColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/images/man.png')),
                                  const Gap(10),
                                  Text(data['displayName']),
                                ],
                              ),
                              const Gap(10),
                              Row(
                                children: [
                                  Expanded(child: Text(data['commentText']))
                                ],
                              )
                            ]),
                          ),
                        );
                      },
                    );
                  })),
          const Gap(10),
          Row(
            children: [
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(color: kPrimaryColor),
                        color: kWhiteColor,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: TextField(
                        controller: commentCon,
                        cursorColor: kPrimaryColor,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(8),
                          hintText: "Type here ...",
                          border: InputBorder.none,
                        ),
                      ))),
              const Gap(10),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: const CircleBorder(),
                    backgroundColor: kSeconderyColor,
                    foregroundColor: kWhiteColor,
                  ),
                  onPressed: () {
                    postComment(
                      userData.uid,
                      userData.profilePic,
                      userData.displayName,
                      userData.username,
                    );
                  },
                  child: const Icon(Icons.arrow_circle_right_outlined))
            ],
          ),
          const Gap(10),
        ]),
      ),
    );
  }
}
