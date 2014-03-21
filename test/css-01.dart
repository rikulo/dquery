import 'package:dquery/dquery.dart';

void main() {
  
  $('#show').on('click', (QueryEvent e) {
    $(':checked + .target').show();
  });
  
  $('#hide').on('click', (QueryEvent e) {
    $(':checked + .target').hide();
  });
  
  $('#toggle').on('click', (QueryEvent e) {
    $(':checked + .target').toggle();
  });
  
}