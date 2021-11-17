import 'dart:html';
import 'package:dquery/dquery.dart';

void main() {
  
  final offset = $('#target').offset!;
  
  final info = querySelector('#info')!;
  info.innerHtml = "${info.innerHtml} (${offset.x}, ${offset.y})";
  
  $('span').offset = offset;
  
}