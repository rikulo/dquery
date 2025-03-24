import 'package:web/web.dart';
import 'package:dquery/dquery.dart';

void main() {
  
  final on = document.querySelector('#on') as HTMLButtonElement;
  final off = document.querySelector('#off') as HTMLButtonElement;
  
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
