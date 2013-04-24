import 'dart:html';
import 'dart:collection';

import 'package:dquery/dquery.dart';

void main() {
  
  $('#show').on('click', (DQueryEvent e) {
    $('#target').show();
  });
  
  $('#hide').on('click', (DQueryEvent e) {
    $('#target').hide();
  });
  
  $('#toggle').on('click', (DQueryEvent e) {
    $('#target').toggle();
  });
  
}