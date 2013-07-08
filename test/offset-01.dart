import 'dart:html';
import 'dart:collection';

import 'package:dquery/dquery.dart';

void main() {
  
  final Point offset = $('#target').offset;
  
  final Element info = query('#info');
  info.innerHtml = "${info.innerHtml} (${offset.x}, ${offset.y})";
  
  $('span').offset = offset;
  
}