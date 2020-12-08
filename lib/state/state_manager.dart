import 'package:comic_reader/Model/chapters.dart';
import 'package:comic_reader/Model/comic.dart';
import 'package:flutter_riverpod/all.dart';

final comicSelected = StateProvider((ref) => Comic());
final chapterSelected = StateProvider((ref) => Chapters());
