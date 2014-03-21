
import 'package:dquery/dquery.dart';

void main() {
  $('#e').on('show',(QueryEvent e) {
    $('#msg').append('<div>show<br/></div>');
  });
  
  $('#e').on('show.a',(QueryEvent e) {
    $('#msg').append('<div>show.a<br/></div>');
  });
  
  $('#e').on('show.b',(QueryEvent e) {
    $('#msg').append('<div>show.b<br/></div>');
  });
  
  $('#e').on('show.a.c',(QueryEvent e) {
    $('#msg').append('<div>show.a.c<br/></div>');
  });
  $('#e').on('show.a.d',(QueryEvent e) {
    $('#msg').append('<div>show.a.d<br/></div>');
  });
  
  
  
  $('#btn1').on('click', (QueryEvent e) {
    $('#e').trigger('show');
  });
  $('#btn2').on('click', (QueryEvent e) {
    $('#e').trigger('show.a');
  });
  
  $('#btn3').on('click', (QueryEvent e) {
    $('#e').trigger('show.a.c');
  });
  
}