part of dquery;

void _cleanData(Element element) {
  for (Element c in element.children) {
    if (!_dataPriv.hasData(c))
      continue;
    final Map space = _dataPriv.getSpace(c);
    // remove event handlers
    if (space.containsKey('events'))
      for (String type in (space['events'] as Map).keys)
        _EventUtil.remove(c, type, null, null);
    
    _dataPriv.discard(c);
    _cleanData(c);
  }
}

void _detach(Element elem, bool data) {
  if (data)
    _cleanData(elem);
  
  if (elem.parent != null) {
    /*
    if ( keepData && jQuery.contains( elem.ownerDocument, elem ) ) {
      setGlobalEval( getAll( elem, "script" ) );
    }
    */
    elem.remove();
  }
}

void _empty(Element elem) {
  for (Element c in elem.children)
    _cleanData(c);
  elem.nodes.clear();
}
