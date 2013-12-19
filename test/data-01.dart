
import 'package:dquery/dquery.dart';

void main() {
  $('#addBtn').on('click', (DQueryEvent e) {
    $('#e').data.set('time', new DateTime.now());
  });
  $('#rmBtn').on('click', (DQueryEvent e) {
    $('#e').data.remove('time');
  });
  
  $('#showBtn').on('click', (DQueryEvent e) {
    Data d = $('#e').data;
    $('#msg').append('<div>time: ${d.get("time")}<br/></div>');
  });
  
}