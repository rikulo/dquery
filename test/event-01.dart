import 'dart:html';
import 'dart:collection';

import 'package:dquery/dquery.dart' as dq hide $, DQueryEvent;
import 'package:dquery/dquery.dart' show $, DQueryEvent;

void main() {
  
  $(document).on('click', (DQueryEvent event) {
    print("${event.target}, data:${event.data}");
    
  }, selector: 'div.button', data: 99);
  
  $('#trigger').on('click', (DQueryEvent event) {
    print('trigger');
    $('div.button').trigger('click', 88);
  });
  
}
