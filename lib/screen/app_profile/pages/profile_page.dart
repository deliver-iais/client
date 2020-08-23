import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool notification = true;
  List<String> imageList = [
    "https://picsum.photos/250?image=9",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/200/300?grayscale",
    "https://picsum.photos/250?image=9",
    /* "https://picsum.photos/250?image=9",
   "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/seed/picsum/200/300",
    "https://picsum.photos/250?image=9",
    "https://picsum.photos/250?image=9",
    "https://picsum.photos/250?image=9",*/
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: DefaultTabController(
            length: 4,
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                      forceElevated: innerBoxIsScrolled,
                      leading: BackButton(
                        color: ExtraTheme.of(context).infoChat,
                      ),
                      expandedHeight: 200.0,
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        collapseMode: CollapseMode.pin,
                        titlePadding: const EdgeInsets.all(0),
                        title: Container(
                          child: Text("Jain",
                              //textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ExtraTheme.of(context).infoChat,
                                fontSize: 28.0,
                                shadows: <Shadow>[
                                  Shadow(
                                    blurRadius: 30.0,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ],
                              )),
                        ),
                        background: Container(
                          child: Image.network(
                            'https://picsum.photos/250?image=9',
                            fit: BoxFit.cover,
                          ),
                          foregroundDecoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Color.fromARGB(150, 0, 0, 0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.6, 1],
                            ),
                          ),
                        ),
                      )),
                  SliverList(
                      delegate: SliverChildListDelegate([
                    Container(
                      height: 80,
                      // padding:
                      //const EdgeInsetsDirectional.only(start: 20, end: 15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        // child:Padding(
                        //  padding: EdgeInsets.fromLTRB(20,20,0,0),
                        child: Wrap(
                            direction: Axis.vertical,
                            runSpacing: 40,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: Text(
                                  "info",
                                  style: TextStyle(
                                    color: ExtraTheme.of(context)
                                        .blueOfProfilePage,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: Text(
                                  "No Description",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                              )
                            ]),
                        // )
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  ExtraTheme.of(context).borderOfProfilePage),
                          color: ExtraTheme.of(context).backgroundOfProfilePage,
                        ),
                        height: 60,
                        padding:
                            const EdgeInsetsDirectional.only(start: 5, end: 15),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.message),
                              onPressed: () {},
                            ),
                            /* Icon(
                  Icons.message,
                  size: 30,
                ),*/
                            //  SizedBox(width: 10),
                            Text('Send Message'),
                          ],
                        )),
                    Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  ExtraTheme.of(context).borderOfProfilePage),
                          color: ExtraTheme.of(context).backgroundOfProfilePage,
                        ),
                        height: 60,
                        padding: const EdgeInsetsDirectional.only(
                            start: 13, end: 15),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.notifications_active,
                                      size: 30,
                                    ),
                                    SizedBox(width: 10),
                                    Text('Notification'),
                                  ],
                                ),
                              ),
                              Switch(
                                activeColor:
                                    ExtraTheme.of(context).blueOfProfilePage,
                                value: notification,
                                onChanged: (newNotifState) {
                                  setState(() {
                                    notification = newNotifState;
                                  });
                                },
                              )
                              /*IconButton(
                   icon: Icon(Icons.notifications_active),
                   onPressed: () {
                   },
                 ),*/
                            ])),
                    Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  ExtraTheme.of(context).borderOfProfilePage),
                          color: ExtraTheme.of(context).backgroundOfProfilePage,
                        ),
                        height: 60,
                        padding:
                            const EdgeInsetsDirectional.only(start: 7, end: 15),
                        child: Row(children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.phone),
                            onPressed: () {},
                          ),
                          /*Icon(
                        Icons.phone,
                        size: 30,
                      ),*/
                          //SizedBox(width:10),
                          Text('Phone'),
                        ])),
                    SizedBox(
                      height: 40,
                    )
                  ])),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      maxHeight: 60,
                      minHeight: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  ExtraTheme.of(context).borderOfProfilePage),
                          color: ExtraTheme.of(context).backgroundOfProfilePage,
                        ),
                        // constraints: BoxConstraints(maxHeight: 300.0),
                        child: TabBar(
                          indicatorColor:
                              ExtraTheme.of(context).blueOfProfilePage,
                          labelColor: ExtraTheme.of(context).blueOfProfilePage,
                          unselectedLabelColor:
                              ExtraTheme.of(context).tabsColor,
                          tabs: [
                            Tab(
                              text: "Media",
                            ),
                            Tab(
                              text: "File",
                            ),
                            Tab(
                              text: "Links",
                            ),
                            Tab(
                              text: "Groups",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Container(
                  child: TabBarView(children: [
                GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: imageList.length,
                    //scrollDirection: Axis.vertical,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      //crossAxisSpacing: 2.0, mainAxisSpacing: 2.0,
                    ),
                    itemBuilder: (context, position) {
                      return Container(
                        decoration: new BoxDecoration(
                          image: new DecorationImage(
                              image: new NetworkImage(
                                imageList[position],
                              ),
                              fit: BoxFit.cover),
                          border: Border.all(
                            width: 1,
                            color: ExtraTheme.of(context).tabsColor,
                          ),
                        ),
                      );
                    }),
                ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Text("File"),
                    Text("File"),
                    Text("File"),
                    Text("File"),
                    Text("File"),
                  ],
                ),
                ListView(),
                ListView(),
              ])),
            )));
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight > minHeight ? maxHeight : minHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
