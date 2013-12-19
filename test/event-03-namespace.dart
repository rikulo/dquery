
import 'package:dquery/dquery.dart';

void main() {
  $('#e').on('show',(DQueryEvent e) {
    $('#msg').append('<div>show<br/></div>');
  });
  
  $('#e').on('show.a',(DQueryEvent e) {
    $('#msg').append('<div>show.a<br/></div>');
  });
  
  $('#e').on('show.b',(DQueryEvent e) {
    $('#msg').append('<div>show.b<br/></div>');
  });
  
  $('#e').on('show.a.c',(DQueryEvent e) {
    $('#msg').append('<div>show.a.c<br/></div>');
  });
  $('#e').on('show.a.d',(DQueryEvent e) {
    $('#msg').append('<div>show.a.d<br/></div>');
  });
  
  
  
  $('#btn1').on('click', (DQueryEvent e) {
    $('#e').trigger('show');
  });
  $('#btn2').on('click', (DQueryEvent e) {
    $('#e').trigger('show.a');
  });
  
  $('#btn3').on('click', (DQueryEvent e) {
    $('#e').trigger('show.a.c');
  });
  
}