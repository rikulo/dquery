import 'dart:html';
import 'package:dquery/dquery.dart';

void main() {
  
  final InputElement input = query('#input');
  final ElementQuery $target = $('#target');
  
  $('#append').on('click', (DQueryEvent event) => $target.append(input.value));
  $('#prepend').on('click', (DQueryEvent event) => $target.prepend(input.value));
  $('#after').on('click', (DQueryEvent event) => $target.after(input.value));
  $('#before').on('click', (DQueryEvent event) => $target.before(input.value));
  
  $('#appendTo').on('click', (DQueryEvent event) => $(input.value).appendTo('#target'));
  $('#prependTo').on('click', (DQueryEvent event) => $(input.value).prependTo('#target'));
  
}