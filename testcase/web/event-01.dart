import 'package:dquery/dquery.dart';
import 'package:web/web.dart';
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
    var value=(event.target as HTMLInputElement).value;
    print("${event.target}, value:${value}");
  });
}
