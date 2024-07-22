import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/colors/app_color.dart';
import 'package:social_media/pages/profile.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchCon = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Users"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          SearchBar(
            controller: searchCon,
            onChanged: (value) {
              setState(() {
                searchCon.text = value;
              });
            },
            //leading: Icon(Icons.search),
            trailing: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.search,
                  color: kPrimaryColor,
                ),
              )
            ],
            hintText: "Search by username",
            backgroundColor:
                MaterialStateColor.resolveWith((states) => Colors.white),
            elevation: MaterialStateProperty.resolveWith((states) => 0),
            shape: MaterialStateProperty.resolveWith((states) =>
                RoundedRectangleBorder(
                    side: BorderSide(color: kPrimaryColor),
                    borderRadius: BorderRadius.circular(12))),
          ),
          Expanded(
              child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .where('username', isEqualTo: searchCon.text)
                      .get(),
                  builder: (context, AsyncSnapshot snapshot) {
                    return ListView.builder(
                      itemCount:
                          searchCon.text == "" ? 0 : snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        dynamic item = snapshot.data.docs[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Profile(uid: item['uid']),
                                ));
                          },
                          child: ListTile(
                            leading: item['profilePic'] == ""
                                ? const CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/images/man.png'),
                                  )
                                : CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(item['profilePic']),
                                  ),
                            title: Text(item['displayName']),
                            subtitle: Text("@" + item["username"]),
                          ),
                        );
                      },
                    );
                  }))
        ]),
      ),
    );
  }
}
