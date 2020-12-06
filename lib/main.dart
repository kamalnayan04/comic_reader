import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';

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
  DatabaseReference _bannerRef;

  @override
  void initState() {
    super.initState();

    final FirebaseDatabase _database = new FirebaseDatabase(app: widget.app);
    _bannerRef = _database.reference().child('Banners');
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

  Future<List<String>> getBanners(DatabaseReference bannerRef) {
    return bannerRef
        .once()
        .then((snapshot) => snapshot.value.cast<String>().toList());
  }
}
