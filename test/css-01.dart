import 'package:dquery/dquery.dart';

void main() {
  
  $('#show').on('click', (DQueryEvent e) {
    $(':checked + .target').show();
  });
  
  $('#hide').on('click', (DQueryEvent e) {
    $(':checked + .target').hide();
  });
  
  $('#toggle').on('click', (DQueryEvent e) {
    $(':checked + .target').toggle();
  });
  
}