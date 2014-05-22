import 'dart:html';
import 'package:dquery/dquery.dart';

void main() {
  
  $('#btn').on('click', render);
  
}

void render(QueryEvent event) {
  final Element root = new UListElement();
  final Element container = document.querySelector('#list');
  Element item;
  
  container.children.first.remove();
  final int t = new DateTime.now().millisecondsSinceEpoch;
  for (int i = 0; i < 1000; i++) {
    item = new LIElement()..innerHtml = '$i';
    $(item).on('click', (QueryEvent e) {
      window.alert("$i");
    });
    root.append(item);
  }
  print(new DateTime.now().millisecondsSinceEpoch - t);
  container.append(root);
}
