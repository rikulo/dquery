import 'dart:js_interop';

import 'package:web/web.dart';
import 'package:dquery/dquery.dart';

void main() {
  
  final offset = $('#target').offset!;
  
  final info = document.querySelector('#info')!;
  info.innerHTML = "${info.innerHTML} (${offset.x}, ${offset.y})".toJS;
  
  $('span').offset = offset;
  
}