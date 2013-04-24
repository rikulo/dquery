part of dquery;

Map<String, String> _elemDisplay = new HashMap<String, String>.from({
  'body': 'block'
});

bool _isHidden(Element elem) =>
    elem.style.display == 'none' || !elem.document.contains(elem); // TODO: do experiment

void _showHide(List<Element> elements, bool show) {
  
  final Map<Element, String> values = new HashMap<Element, String>();
  
  for (Element elem in elements) {
    /*
    if ( !elem.style ) {
      continue;
    }
    */
    String oldDisplay = _dataPriv.get(elem, 'olddisplay');
    values[elem] = oldDisplay;
    String display = elem.style.display;
    
    if (show) {
      // jQuery: Reset the inline display of this element to learn if it is
      //         being hidden by cascaded rules or not
      if (oldDisplay == null && display == "none")
        elem.style.display = '';
      
      // jQuery: Set elements which have been overridden with display: none
      //         in a stylesheet to whatever the default browser style is
      //         for such an element
      if (elem.style.display == '' && _isHidden(elem))
        _dataPriv.set(elem, 'olddisplay', values[elem] = _cssDefaultDisplay(elem.tagName));
      
    } else if (!values.containsKey(elem)) {
      final bool hidden = _isHidden(elem);
      if (display != null && !display.isEmpty && display != 'none' || !hidden)
        _dataPriv.set(elem, 'olddisplay', hidden ? display : elem.style.display);
      
    }
    
  }
  
  // Set the display of most of the elements in a second loop
  // to avoid the constant reflow
  for (Element elem in elements) {
    /*
    if ( !elem.style ) {
      continue;
    }
    */
    final String display = elem.style.display;
    if (!show || display == 'none' || display == '')
      elem.style.display = show ? _fallback(values[elem], () => '') : 'none';
    
  }
  
}

// Try to determine the default display value of an element
String _cssDefaultDisplay(String nodeName) {
  HtmlDocument doc = document;
  String display = _elemDisplay[nodeName];
  if (display == null) {
    display = _actualDisplay(nodeName, doc);
    
    // TODO: later
    /*
    // If the simple way fails, read from inside an iframe
    if ( display === "none" || !display ) {
      // Use the already-created iframe if possible
      iframe = ( iframe ||
        jQuery("<iframe frameborder='0' width='0' height='0'/>")
        .css( "cssText", "display:block !important" )
      ).appendTo( doc.documentElement );
      
      // Always write a new HTML skeleton so Webkit and Firefox don't choke on reuse
      doc = ( iframe[0].contentWindow || iframe[0].contentDocument ).document;
      doc.write("<!doctype html><html><body>");
      doc.close();
      
      display = actualDisplay( nodeName, doc );
      iframe.detach();
    }
    */
    
    // Store the correct default display
    _elemDisplay[nodeName] = display;
  }
  return display;
}

// jQuery: Called ONLY from within css_defaultDisplay
String _actualDisplay(String name, HtmlDocument doc) {
  Element e = new Element.tag(name);
  doc.body.append(e);
  String display = e.style.display;
  e.remove();
  return display;
}
