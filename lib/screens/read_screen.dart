import 'package:carousel_slider/carousel_slider.dart';
import 'package:comic_reader/state/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/all.dart';

class ReadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      var comic = watch(comicSelected).state;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFF44A3E),
          title: Center(
            child: Text(
              '${comic.name.toUpperCase()}',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: Center(
          child: (context.read(chapterSelected).state.links == null ||
                  context.read(chapterSelected).state.links.length == 0)
              ? Center(
                  child: Text(
                      'This chapter is being translated. \nPlease Try again later.'),
                )
              : CarouselSlider(
                  items: context
                      .read(chapterSelected)
                      .state
                      .links
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
                      autoPlay: false,
                      height: MediaQuery.of(context).size.height,
                      enlargeCenterPage: false,
                      viewportFraction: 1,
                      initialPage: 0),
                ),
        ),
      );
    });
  }
}
