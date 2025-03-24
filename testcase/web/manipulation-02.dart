import 'package:web/web.dart';
import 'package:dquery/dquery.dart';

void main() {
  
  final input = document.querySelector('#input') as HTMLInputElement;
  final $target = $('#target');
  
  $('#append').on('click', (QueryEvent event) => $target.append(input.value));
  $('#prepend').on('click', (QueryEvent event) => $target.prepend(input.value));
  $('#after').on('click', (QueryEvent event) => $target.after(input.value));
  $('#before').on('click', (QueryEvent event) => $target.before(input.value));
  
  $('#appendTo').on('click', (QueryEvent event) => $(input.value).appendTo('#target'));
  $('#prependTo').on('click', (QueryEvent event) => $(input.value).prependTo('#target'));
  
}