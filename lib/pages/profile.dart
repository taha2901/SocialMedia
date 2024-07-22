import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_stack/image_stack.dart';
import 'package:provider/provider.dart';
import 'package:social_media/colors/app_color.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/pages/edit_user.dart';
import 'package:social_media/provider/user_provider.dart';
import 'package:social_media/services/cloud.dart';
import 'package:social_media/widgets/post_card.dart';

class Profile extends StatefulWidget {
  String? uid;
  Profile({
    super.key,
    this.uid,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  late TabController _tabController = TabController(length: 2, vsync: this);
  String myId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    widget.uid = widget.uid ?? FirebaseAuth.instance.currentUser!.uid;
    Provider.of<UserProvider>(context, listen: false).getDetails();
    getUserData();
    super.initState();
  }

  var userInfo = {};
  bool isLoad = true;
  bool isFollowing = false;
  int followers = 0;
  int following = 0;
  getUserData() async {
    try {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid ?? myId)
          .get();

      userInfo = userData.data()!;
      isFollowing = (userData.data()! as dynamic)['followers'].contains(myId);
      followers = (userData.data()! as dynamic)['followers'].length;
      following = (userData.data()! as dynamic)['following'].length;
      setState(() {
        isLoad = false;
      });
    } on Exception catch (e) {
      // TODO
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    UserModel userModel = Provider.of<UserProvider>(context).userModel!;
    return isLoad
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: userInfo['uid'] == myId
                ? AppBar(
                    actions: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const EditUserPage()));
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                        icon: const Icon(Icons.logout),
                      )
                    ],
                  )
                : AppBar(),
            body: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      userModel.profilePic == ""
                          ? const CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  AssetImage('assets/images/man.png'),
                            )
                          : CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  NetworkImage(userModel.profilePic),
                            ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: kWhiteColor,
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            ImageStack(
                              imageSource: ImageSource.Asset,
                              imageList: [
                                'assets/images/man.png',
                                'assets/images/woman.png'
                              ],
                              totalCount: 0,
                              imageRadius: 30,
                              imageBorderWidth: 2,
                              imageBorderColor: Colors.white,
                            ),
                            Gap(5),
                            Row(
                              children: [
                                Text(followers.toString()),
                                Gap(5),
                                Text("Followers")
                              ],
                            )
                          ],
                        ),
                      ),
                      Gap(15),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: kWhiteColor,
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            ImageStack(
                              imageSource: ImageSource.Asset,
                              imageList: const [
                                'assets/images/man.png',
                                'assets/images/woman.png'
                              ],
                              totalCount: 0,
                              imageRadius: 30,
                              imageBorderWidth: 2,
                              imageBorderColor: Colors.white,
                            ),
                            const Gap(5),
                            Row(
                              children: [
                                Text(following.toString()),
                                const Gap(5),
                                const Text("Following"),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(5),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: Text(
                            userInfo['displayName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('@user'),
                        ),
                      ),
                      userInfo['uid'] == myId
                          ? const SizedBox()
                          : Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      foregroundColor: kWhiteColor,
                                      backgroundColor: kSeconderyColor),
                                  onPressed: () {
                                    try {
                                      CloudMethods().followUser(
                                          uid: myId,
                                          followUserId: userInfo['uid']);
                                      setState(() {
                                        isFollowing ? followers-- : followers++;
                                        isFollowing = !isFollowing;
                                      });
                                    } on Exception catch (e) {
                                      // TODO
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Text(isFollowing ? "UnFollow" : "Follow"),
                                      const Gap(2),
                                      Icon(isFollowing
                                          ? Icons.remove
                                          : Icons.add)
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: CircleBorder(
                                            side: BorderSide(
                                                color: kSeconderyColor)),
                                        foregroundColor: kSeconderyColor,
                                        backgroundColor: Colors.white),
                                    onPressed: () {},
                                    child: const Icon(Icons.message)),
                              ],
                            ),
                    ],
                  ),
                  const Gap(10),
                  userInfo['bio'] == ""
                      ? const SizedBox()
                      : Row(
                          children: [
                            Expanded(
                                child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Center(
                                  child: Text(
                                userInfo['bio'],
                                style: TextStyle(
                                    color: kPrimaryColor, fontSize: 16),
                              )),
                            ))
                          ],
                        ),
                  const Gap(10),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(
                        text: "Photos",
                      ),
                      Tab(
                        text: "Posts",
                      ),
                    ],
                  ),
                  const Gap(20),
                  Expanded(
                      child: TabBarView(
                    controller: _tabController,
                    children: [
                      FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('posts')
                              .where("uid", isEqualTo: userInfo['uid'])
                              .get(),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.hasError) {
                              return const Text("Error");
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return RefreshIndicator(
                                onRefresh: () async {
                                  setState(() {});
                                },
                                child: GridView.builder(
                                  itemCount: snapshot.data.docs.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          mainAxisSpacing: 3,
                                          crossAxisSpacing: 3,
                                          crossAxisCount: 3),
                                  itemBuilder: (context, index) {
                                    dynamic item = snapshot.data.docs[index];
                                    return Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(
                                                  item['postImage']))),
                                    );
                                  },
                                ),
                              );
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }),
                      FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('posts')
                              .where(
                                "uid",
                                isEqualTo: userInfo['uid'],
                              )
                              .get(),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.hasError) {
                              return const Text("Error");
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return RefreshIndicator(
                                onRefresh: () async {
                                  setState(() {});
                                },
                                child: ListView.builder(
                                  itemCount: snapshot.data.docs.length == 0
                                      ? 1
                                      : snapshot.data.docs.length,
                                  itemBuilder: (context, index) {
                                    dynamic item =
                                        snapshot.data.docs.length == 0
                                            ? ""
                                            : snapshot.data.docs[index];

                                    return snapshot.data.docs.length == 0
                                        ? const Center(child: Text("No Posts"))
                                        : PostCard(item: item);
                                  },
                                ),
                              );
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }),
                    ],
                  ))
                ],
              ),
            ));
  }
}
