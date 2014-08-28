import 'dart:html';

import 'package:dquery/dquery.dart';

void main() {
  
  //blur
  final Element blurSec = querySelector('.blur');
  
  $document().on('blur', (QueryEvent e) {
    printDoc(blurSec);
  }, selector: '.blur input');
    
  $('.blur input').on('blur', (QueryEvent e) {
    printElem(blurSec);
  });
  
  
  //focus
  final Element focusSec = querySelector('.focus');
  
  $document().on('focus', (QueryEvent e) {
    printDoc(focusSec);
  }, selector: '.focus input');
    
  $('.focus input').on('focus', (QueryEvent e) {
    printElem(focusSec);
  });
  
  //click
  final Element clickSec = querySelector('.click');
  
  $document().on('click', (QueryEvent e) {
    printDoc(clickSec);
  }, selector: '.click button');
    
  $('.click button').on('click', (QueryEvent e) {
    printElem(clickSec);
  });
  
  //click
  final Element enterSec = querySelector('.mouseenter');
  
  $document().on('mouseenter', (QueryEvent e) {
    printDoc(enterSec);
  }, selector: '.mouseenter .test-area');
    
  $('.mouseenter .test-area').on('mouseenter', (QueryEvent e) {
    printElem(enterSec);
  });
}

String NUM_DOC = 'num_doc';
String NUM_ELEM = 'num_elem';

void printDoc(Element sec) {
  int n = $(sec).data.get(NUM_DOC);
  if (n == null)
    n = 0;
  
  $(sec).data.set(NUM_DOC, ++n);
  sec.querySelector('.doc-result').text = 'doc: $n';
}

void printElem(Element sec) {
  int n = $(sec).data.get(NUM_ELEM);
  if (n == null)
    n = 0;
  
  $(sec).data.set(NUM_ELEM, ++n);
  sec.querySelector('.elem-result').text = 'elem: $n';
}