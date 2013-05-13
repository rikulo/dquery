part of dquery;

void _cleanData(Element elem) {
  
  // TODO
  
}

void _detach(Element elem, bool data) {
  
  if (data) {
    _cleanData(elem);
  }
  
  // TODO
  
}

void _empty(Element elem) {
  _cleanData(elem);
  // TODO: nodes, not elements
  elem.children.clear();
}
