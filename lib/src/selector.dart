part of dquery;

// TODO: unique requires sorting
/* src:
selector_sortOrder = function( a, b ) {
  // Flag for duplicate removal
  if ( a === b ) {
    selector_hasDuplicate = true;
    return 0;
  }

  var compare = b.compareDocumentPosition && a.compareDocumentPosition && a.compareDocumentPosition( b );

  if ( compare ) {
    // Disconnected nodes
    if ( compare & 1 ) {

      // Choose the first element that is related to our document
      if ( a === document || jQuery.contains(document, a) ) {
        return -1;
      }
      if ( b === document || jQuery.contains(document, b) ) {
        return 1;
      }
  
      // Maintain original order
      return 0;
    }
  
    return compare & 4 ? -1 : 1;
  }

  // Not directly comparable, sort on existence of method
  return a.compareDocumentPosition ? -1 : 1;
};
*/

// NOT in jQuery API
// TODO: check seed usage
// TODO: double check behavior
List<Element> _find(String selector, [context, List<Element> results, seed]) {
  
  // USE our own implementation
  List<Element> matched = 
      context == null ? document.queryAll(selector) :
      context is Document ? context.queryAll(selector) :
      context is Element ? context.queryAll(selector) : 
      context is DQueryBase ? (context.isEmpty ? document.queryAll(selector) : context[0].queryAll(selector)) : 
      document.queryAll(selector);
  
  print(results == null);
  return results == null ? matched : (results..addAll(matched));
}

/**
 * 
 */
List<Element> unique(List<Element> elems) {
  // USE our own implementation
  // TODO: need it to be sorted
  return elems.toSet().toList(growable: true);
}

// NOT in jQuery API
String _text(elem) {
  
}

/**
 * 
 */
bool contains(a, b) {
  
}

/**
 * 
 */
bool isXmlDoc(elem) {
  
}

// TODO: check what this is
/* src:
  expr: {
    match: {
      needsContext: /^[\x20\t\r\n\f]*[>+~]/
    }
  }
*/
