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

/*
List<Node> _resolveTarget(target) =>
    target is DocumentQuery || target is ElementQuery ? target :
    target is Document || target is Element ? [target] :
    target is String ? $(target) : [];
*/
void _domManip(x, void f(Element elem)) {
  
}

void _setText(Element elem, String value) {
  elem.children.clear();
  elem.append(new Text(value));
}

// in strong type system, no way to get to text node or document fragment
/*
String _getText(Node node) =>
    node is Element ? (node as Element).text :
    node is Document ? (node as Document).text :
    node is DocumentFragment ? (node as DocumentFragment).text :
    node is Text ? node.nodeValue : '';
*/