import 'package:dquery/dquery.dart';
import 'dart:html';
void main() {
  
  $document().on('click', (QueryEvent event) {
    print("${event.target}, data:${event.data}");
    
  }, selector: 'div.button');
  
  $('#trigger').on('click', (QueryEvent event) {
    print('trigger');
    $('div.button').trigger('click', data: 88);
  });
  $('#trigger').click((QueryEvent event) { print(event.type);});
  $('#input1').change((QueryEvent event) {
    var value=(event.target as InputElement).value;
    print("${event.target}, value:${value}");
  });
}
