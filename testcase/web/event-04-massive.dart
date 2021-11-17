import 'dart:html';
import 'package:dquery/dquery.dart';

void main() {
  
  $('#btn').on('click', render);
  
}

void render(QueryEvent event) {
  final root = UListElement();
  final container = document.querySelector('#list')!;
  Element item;

  container.children.first.remove();
  final t = DateTime.now().millisecondsSinceEpoch;
  for (var i = 0; i < 1000; i++) {
    item = LIElement()..innerHtml = '$i';
    $(item).on('click', (QueryEvent e) {
      window.alert("$i");
    });
    root.append(item);
  }
  print(DateTime.now().millisecondsSinceEpoch - t);
  container.append(root);
}
