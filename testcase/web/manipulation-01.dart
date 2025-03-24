import 'package:web/web.dart';
import 'package:dquery/dquery.dart';

void main() {
  
  final input = document.querySelector('#input') as HTMLInputElement;
  final $html = $('#html');
  final $text = $('#text');
  
  $('#go').on('click', (QueryEvent event) {
    $html.html = input.value;
    $text.text = input.value;
  });
  
}