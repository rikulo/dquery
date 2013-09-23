import 'dart:html';
import 'package:dquery/dquery.dart';

void main() {
  
  final InputElement input = query('#input');
  final ElementQuery $html = $('#html');
  final ElementQuery $text = $('#text');
  
  $('#go').on('click', (DQueryEvent event) {
    $html.html = input.value;
    $text.text = input.value;
  });
  
}