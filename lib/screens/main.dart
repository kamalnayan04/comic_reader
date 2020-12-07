import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:comic_reader/Model/comic.dart';
import 'package:comic_reader/screens/chapter_screen.dart';
import 'package:comic_reader/state/state_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FirebaseApp app = await Firebase.initializeApp(
      name: 'comic_reader_app',
      options: Platform.isMacOS || Platform.isIOS
          ? FirebaseOptions(
              appId: 'IOS KEY',
              apiKey: 'AIzaSyBvDUSaaucDQlEK_3H2xnR3xHpFSCma824',
              projectId: 'comicreader-b5571',
              messagingSenderId: '772131957343',
              databaseURL:
                  'https://comicreader-b5571-default-rtdb.firebaseio.com/',
            )
          : FirebaseOptions(
              appId: '1:772131957343:android:b5c0cd3e251422e6ff49ea',
              apiKey: 'AIzaSyBvDUSaaucDQlEK_3H2xnR3xHpFSCma824',
              projectId: 'comicreader-b5571',
              messagingSenderId: '772131957343',
              databaseURL:
                  'https://comicreader-b5571-default-rtdb.firebaseio.com/',
            ));
  runApp(ProviderScope(
    child: MyApp(
      app: app,
    ),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  FirebaseApp app;

  MyApp({this.app});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter  Demo',
      routes: {'chapters': (context) => ChapterScreen()},
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Comic Reader', app: app),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.app}) : super(key: key);

  final String title;
  final FirebaseApp app;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseReference _bannerRef, _comicReference;

  @override
  void initState() {
    super.initState();

    final FirebaseDatabase _database = new FirebaseDatabase(app: widget.app);
    _bannerRef = _database.reference().child('Banners');
    _comicReference = _database.reference().child('Comic');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF44A3E),
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: getBanners(_bannerRef),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CarouselSlider(
                    items: snapshot.data
                        .map((e) => Builder(
                              builder: (context) {
                                return Image.network(
                                  e,
                                  fit: BoxFit.cover,
                                );
                              },
                            ))
                        .toList(),
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 1,
                      initialPage: 0,
                      height: MediaQuery.of(context).size.height / 3,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Container(
                          color: Color(0xFFF44A3E),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'NEW COMIC',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(''),
                          ),
                        ),
                      )
                    ],
                  ),
                  FutureBuilder(
                    future: getComic(_comicReference),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return Center(
                          child: Text('${snapshot.error}'),
                        );
                      else if (snapshot.hasData) {
                        List<Comic> comics = new List<Comic>();
                        snapshot.data.forEach((item) {
                          var comic =
                              Comic.fromJson(json.decode(json.encode(item)));
                          comics.add(comic);
                        });
                        return Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            padding: const EdgeInsets.all(4.0),
                            mainAxisSpacing: 1.0,
                            crossAxisSpacing: 1.0,
                            children: comics.map((comic) {
                              return GestureDetector(
                                onTap: () {
                                  context.read(comicSelected).state = comic;

                                  Navigator.pushNamed(context, "chapters");
                                },
                                child: Card(
                                  elevation: 12,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        comic.image,
                                        fit: BoxFit.cover,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            color: Color(0xAA434343),
                                            padding: EdgeInsets.all(8),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${comic.name}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  )
                ]);
          else if (snapshot.hasError)
            return Center(
              child: Text(
                '${snapshot.error}',
              ),
            );
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Future<List<dynamic>> getComic(DatabaseReference comicRef) {
    return comicRef.once().then((snapshot) => snapshot.value);
  }

  Future<List<String>> getBanners(DatabaseReference bannerRef) {
    return bannerRef
        .once()
        .then((snapshot) => snapshot.value.cast<String>().toList());
  }
}
