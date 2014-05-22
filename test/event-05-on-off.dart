import 'dart:html';
import 'package:dquery/dquery.dart';

void main() {
  
  final ButtonElement on = querySelector('#on');
  final ButtonElement off = querySelector('#off');
  
  $(on).on('click', (_) {
    $('#btn').on('click', f);
    off.disabled = false;
    on.disabled = true;
  });
  
  $(off).on('click', (_) {
    $('#btn').off('click', handler: f);
    off.disabled = true;
    on.disabled = false;
  });
  
}

void f(QueryEvent event) {
  window.alert('hit!');
}
