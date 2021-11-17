import 'dart:html';
import 'package:dquery/dquery.dart';

void main() {
  
  final input = querySelector('#input') as InputElement;
  final $html = $('#html');
  final $text = $('#text');
  
  $('#go').on('click', (QueryEvent event) {
    $html.html = input.value;
    $text.text = input.value!;
  });
  
}