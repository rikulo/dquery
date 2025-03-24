import 'dart:js_interop';

import 'package:web/web.dart';
import 'package:dquery/dquery.dart';

void main() {
  
  $('#btn').on('click', render);
  
}

void render(QueryEvent event) {
  final root = HTMLUListElement();
  final container = document.querySelector('#list')!;
  Element item;

  container.children.item(0)?.remove();
  final t = DateTime.now().millisecondsSinceEpoch;
  for (var i = 0; i < 1000; i++) {
    item = HTMLLIElement()..innerHTML = '$i'.toJS;
    $(item).on('click', (QueryEvent e) {
      window.alert("$i");
    });
    root.append(item);
  }
  print(DateTime.now().millisecondsSinceEpoch - t);
  container.append(root);
}
