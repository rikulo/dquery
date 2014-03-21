import 'package:dquery/dquery.dart';

void main() {
  
  $document().on('click', (QueryEvent event) {
    print("${event.target}, data:${event.data}");
    
  }, selector: 'div.button');
  
  $('#trigger').on('click', (QueryEvent event) {
    print('trigger');
    $('div.button').trigger('click', data: 88);
  });
  
}
