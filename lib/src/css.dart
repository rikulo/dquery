part of dquery;

final Map<String, String> _elemDisplay = {
  'body': 'block'
};

bool _isHidden(Element elem) =>
    (elem as HTMLElement).style.display == 'none' || 
    window.getComputedStyle(elem).display == 'none' ||
        elem.ownerDocument?.contains(elem) != true; // TODO: do experiment

void _showHide(List<Element> elements, bool show) {
  
  final values = <Element, String>{};
  
  for (final elem in elements.cast<HTMLElement>()) {
    final oldDisplay = _dataPriv.get(elem, 'olddisplay');
    if (oldDisplay != null)
      values[elem] = oldDisplay;
    final display = elem.style.display;
    
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
      final hidden = _isHidden(elem);
      if (display.isNotEmpty && display != 'none' || !hidden)
        _dataPriv.set(elem, 'olddisplay', hidden ? display : elem.style.display);
      
    }
    
  }
  
  // Set the display of most of the elements in a second loop
  // to avoid the constant reflow
  for (final elem in elements.cast<HTMLElement>()) {
    final String display = elem.style.display;
    if (!show || display == 'none' || display == '')
      elem.style.display = show ? (values[elem] ?? '') : 'none';
  }
  
}

// Try to determine the default display value of an element
String _cssDefaultDisplay(String nodeName) {
  var display = _elemDisplay[nodeName];
  if (display == null) {
    display = _actualDisplay(nodeName, document);
    
    // TODO: later (handle iframe)
    /*
    // If the simple way fails, read from inside an iframe
    if ( display == "none" || !display ) {
      // Use the already-created iframe if possible
      iframe = ( iframe ||
        jQuery("<iframe frameborder='0' width='0' height='0'/>")
        .css( "cssText", "display:block !important" )
      ).appendTo( document.documentElement );
      
      // Always write a new HTML skeleton so Webkit and Firefox don't choke on reuse
      HtmlDocument doc = ( iframe[0].contentWindow || iframe[0].contentDocument ).document;
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
String _actualDisplay(String name, Document doc) {
  final e = document.createElement(name);
  doc.body?.append(e);
  final display = window.getComputedStyle(e).display;
  e.remove();
  return display;
}

String? _getCurCss(Element elem, String name, CSSStyleDeclaration? computed) {
  computed = computed ?? window.getComputedStyle(elem);
  
  // Support: IE9
  // getPropertyValue is only needed for .css('filter') in IE9, see #12537
  // TODO: skipped, trust Dart handling for now but need to test against it
  // ret = computed ? computed.getPropertyValue( name ) || computed[ name ] : undefined,
  final value = computed.getPropertyValue(name);
  if (value.isNotEmpty)
    return value;

  //already handle by getPropertyValue
  //return computed.getPropertyValue("${Device.cssPrefix}${name}");
  return computed.getPropertyValue(name);
  
  //if ( computed ) {
    /*
    if ( ret === "" && !jQuery.contains( elem.ownerDocument, elem ) ) {
      ret = jQuery.style( elem, name );
    }
    */
    // skipped
    /* 
    // jQuery: Support: Safari 5.1
    //         A tribute to the "awesome hack by Dean Edwards"
    //         Safari 5.1.7 (at least) returns percentage for a larger set of values, but width seems to be reliably pixels
    //         this is against the CSSOM draft spec: http://dev.w3.org/csswg/cssom/#resolved-values
    // ...
    */
  //}
}

String? _getCss(Element elem, String name, [CSSStyleDeclaration? computed]) {
  // jQuery: Make sure that we're working with the right name
  // skipped, for there is no easy way to check property name in Dart
  // name = jQuery.cssProps[ origName ] || ( jQuery.cssProps[ origName ] = vendorPropName( elem.style, origName ) );
  
  // skip css hooks for now
  /*
  // jQuery: gets hook for the prefixed version
  //         followed by the unprefixed version
  hooks = jQuery.cssHooks[ name ] || jQuery.cssHooks[ origName ];
  
  // jQuery: If a hook was provided get the computed value from there
  if ( hooks && "get" in hooks ) {
    val = hooks.get( elem, true, extra );
  }
  */
  
  // jQuery: Otherwise, if a way to get the computed value exists, use that
  var value = _getCurCss(elem, name, computed);
  
  // normalization 1: skipped for now
  /*
  // jQuery: convert "normal" to computed value
  if ( value === "normal" && name in cssNormalTransform ) {
    value = cssNormalTransform[ name ];
  }
  */
  
  // normalization 2: skipped for now
  /*
  // jQuery: Return, converting to number if forced or a qualifier was provided and val looks numeric
  if ( extra === "" || extra ) {
    num = parseFloat( val );
    return extra === true || jQuery.isNumeric( num ) ? num || 0 : val;
  }
  */
  
  return value;
}

void _setCss(Element elem, String name, String value) {
  
  // jQuery: convert relative number strings (+= or -=) to relative numbers. #7345
  /*
  if ( type === "string" && (ret = rrelNum.exec( value )) ) {
    value = ( ret[1] + 1 ) * ret[2] + parseFloat( jQuery.css( elem, name ) );
    // jQuery: Fixes bug #9237
    type = "number";
  }
  */
  
  // jQuery: Make sure that NaN and null values aren't set. See: #7116
  /*
  if ( value == null || type === "number" && isNaN( value ) ) {
    return;
  }
  */
  
  // jQuery: If a number was passed in, add 'px' to the (except for certain CSS properties)
  // TODO: later
  /*
  if ( type === "number" && !jQuery.cssNumber[ origName ] ) {
    value += "px";
  }
  */
  
  // jQuery: Fixes #8908, it can be done more correctly by specifying setters in cssHooks,
  //         but it would mean to define eight (for every problematic property) identical functions
  // TODO: check
  /*
  if ( !jQuery.support.clearCloneStyle && value === "" && name.indexOf("background") === 0 ) {
    style[ name ] = "inherit";
  }
  */
  
  // jQuery: If a hook was provided, use that value, otherwise just set the specified value
  // skipped hooks for now
  /*
  if ( !hooks || !("set" in hooks) || (value = hooks.set( elem, value, extra )) !== undefined ) {
    style[ name ] = value;
  }
  */
  
  (elem as HTMLElement).style.setProperty(name, value);
  //already handle by setProperty
  //elem.style.setProperty("${Device.cssPrefix}$name", value);
}
