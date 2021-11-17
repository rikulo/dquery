
import 'package:dquery/dquery.dart';

void main() {
  $('#addBtn').on('click', (QueryEvent e) {
    $('#e').data.set('time', DateTime.now());
  });
  $('#rmBtn').on('click', (QueryEvent e) {
    $('#e').data.remove('time');
  });
  
  $('#showBtn').on('click', (QueryEvent e) {
    Data d = $('#e').data;
    $('#msg').append('<div>time: ${d.get("time")}<br/></div>');
  });
  
}