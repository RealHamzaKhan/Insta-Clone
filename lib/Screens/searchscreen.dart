import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/Screens/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

import '../utils/circular_progress_indicator.dart';
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isShowusers=false;
  final searchController=TextEditingController();
  @override
  void dispose() {
    searchController.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: mobileBackgroundColor,
          title: TextFormField(
            controller: searchController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Search for a user'
            ),
            // onFieldSubmitted: (String _){
            //   setState(() {
            //     isShowusers=true;
            //   });
            // },
            onChanged: (String _){
              setState(() {

              });
            },
          ),
        ),
        body: searchController.text.isNotEmpty?StreamBuilder(
            stream: FirebaseFirestore
                .instance
                .collection('users')
                .where(
              'username',isGreaterThanOrEqualTo: searchController.text).snapshots(),
            builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>>snapshot){
              if(!snapshot.hasData || snapshot.data==null){
                return Center(child: CircularIndicator);
              }
              else{
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context,index){
                      return InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(uid: snapshot.data!.docs[index]['uid'],myProf: true,)));

                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage('${snapshot.data!.docs[index]['photourl']}'),
                          ),
                          title: Text(snapshot.data!.docs[index]['username']),
                        ),
                      );
                    });
              }

            })
            :FutureBuilder(
            future: FirebaseFirestore.instance.collection('posts').get(),
            builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>>snapshot){
              if(!snapshot.hasData || snapshot==null){
                return Center(child: CircularIndicator,);
              }
              else{
                return GridView.custom(
                  gridDelegate: SliverQuiltedGridDelegate(
                    crossAxisCount: 4,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    repeatPattern: QuiltedGridRepeatPattern.inverted,
                    pattern: [
                      const QuiltedGridTile(2, 2),
                      const QuiltedGridTile(1, 1),
                      const QuiltedGridTile(1, 1),
                      const QuiltedGridTile(1, 2),
                    ],
                  ),
                  childrenDelegate: SliverChildBuilderDelegate(
                    childCount: snapshot.data!.docs.length,
                        (context, index) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(image: NetworkImage(snapshot.data!.docs[index]['photourl']),fit:BoxFit.fill )
                            ),)
                            //child: Image.network(snapshot.data!.docs[index]['photourl'])),
                  ),
                );
              }
            })
      ),
    );
  }
}
