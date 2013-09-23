import 'package:dquery/dquery.dart';

void main() {
  
  $document().on('click', (DQueryEvent event) {
    print("${event.target}, data:${event.data}");
    
  }, selector: 'div.button');
  
  $('#trigger').on('click', (DQueryEvent event) {
    print('trigger');
    $('div.button').trigger('click', data: 88);
  });
  
}
