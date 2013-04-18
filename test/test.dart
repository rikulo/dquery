import 'dart:html';
import 'dart:collection';

import 'package:dquery/dquery.dart' as dq hide $, DQueryEvent;
import 'package:dquery/dquery.dart' show $, DQueryEvent;

class A extends ListBase<String> {
  
  String operator [](int index) => null;
  
  int get length => 0;
  
  void operator []=(int index, String value) {}
  
  void set length(int newLength) {}
  
}

void main() {
  
  $(document).on('click', (DQueryEvent event) {
    print("${event.target}, data:${event.data}");
    
  }, selector: 'div.button', data: 99);
  
}
