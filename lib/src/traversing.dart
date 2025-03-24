part of dquery;

/*
var rneedsContext = jQuery.expr.match.needsContext,
// methods guaranteed to produce a unique set when starting from a unique set
guaranteedUnique = {
  children: true,
  contents: true,
  next: true,
  prev: true
};
*/

/**
 * 
 */
//abstract class TraversingMixin {
  
//  DQuery get _this;
  
  /**
   * 
   */
  //bool has(String target) {
    // TODO
    /* src:
    var targets = jQuery( target, this ),
        l = targets.length;

    return this.filter(function() {
      var i = 0;
      for ( ; i < l; i++ ) {
        if ( jQuery.contains( this, targets[i] ) ) {
          return true;
        }
      }
    });
    */
  //}
  
  /**
   * 
   */
  /*
  DQuery not({String selector, bool test(Element elem, int index), 
    Element element, DQuery dquery}) {
    
    return _this.pushStack(_winnow(_this, selector, test, element, dquery, true));
  }
  */
  
  /**
   * 
   */
  /*
  DQuery filter({String selector, bool test(Element elem, int index), 
    Element element, DQuery dquery}) {
    
    return _this.pushStack(_winnow(_this, selector, test, element, dquery, false));
  }
  */
  
  /*
  is: function( selector ) {
    return !!selector && (
      typeof selector === "string" ?
      // If this is a positional/relative selector, check membership in the returned set
      // so $("p:first").is("p:last") won't return true for a doc with two "p".
      rneedsContext.test( selector ) ?
        jQuery( selector, this.context ).index( this[ 0 ] ) >= 0 :
        jQuery.filter( selector, this ).length > 0 :
      this.filter( selector ).length > 0 );
  },
  
  closest: function( selectors, context ) {
    var cur,
      i = 0,
      l = this.length,
      matched = [],
      pos = ( rneedsContext.test( selectors ) || typeof selectors !== "string" ) ?
      jQuery( selectors, context || this.context ) :
      0;
  
    for ( ; i < l; i++ ) {
      for ( cur = this[i]; cur && cur !== context; cur = cur.parentNode ) {
        // Always skip document fragments
        if ( cur.nodeType < 11 && (pos ?
          pos.index(cur) > -1 :
  
          // Don't pass non-elements to Sizzle
          cur.nodeType === 1 &&
          jQuery.find.matchesSelector(cur, selectors)) ) {
  
          cur = matched.push( cur );
          break;
        }
      }
    }
  
    return this.pushStack( matched.length > 1 ? jQuery.unique( matched ) : matched );
  },
  
  // Determine the position of an element within
  // the matched set of elements
  index: function( elem ) {
  
    // No argument, return index in parent
    if ( !elem ) {
      return ( this[ 0 ] && this[ 0 ].parentNode ) ? this.first().prevAll().length : -1;
    }
  
    // index in selector
    if ( typeof elem === "string" ) {
      return core_indexOf.call( jQuery( elem ), this[ 0 ] );
    }
  
    // Locate the position of the desired element
    return core_indexOf.call( this,
  
      // If it receives a jQuery object, the first element is used
      elem.jquery ? elem[ 0 ] : elem
    );
  },
  
  add: function( selector, context ) {
    var set = typeof selector === "string" ?
      jQuery( selector, context ) :
      jQuery.makeArray( selector && selector.nodeType ? [ selector ] : selector ),
      all = jQuery.merge( this.get(), set );
  
    return this.pushStack( jQuery.unique(all) );
  },
  
  addBack: function( selector ) {
    return this.add( selector == null ?
      this.prevObject : this.prevObject.filter(selector)
    );
  }
  */
//}

/*
function sibling( cur, dir ) {
  while ( (cur = cur[dir]) && cur.nodeType !== 1 ) {}
  return cur;
}
*/

/*
jQuery.each({
  parent: function( elem ) {
    var parent = elem.parentNode;
    return parent && parent.nodeType !== 11 ? parent : null;
  },
  parents: function( elem ) {
    return jQuery.dir( elem, "parentNode" );
  },
  parentsUntil: function( elem, i, until ) {
    return jQuery.dir( elem, "parentNode", until );
  },
  next: function( elem ) {
    return sibling( elem, "nextSibling" );
  },
  prev: function( elem ) {
    return sibling( elem, "previousSibling" );
  },
  nextAll: function( elem ) {
    return jQuery.dir( elem, "nextSibling" );
  },
  prevAll: function( elem ) {
    return jQuery.dir( elem, "previousSibling" );
  },
  nextUntil: function( elem, i, until ) {
    return jQuery.dir( elem, "nextSibling", until );
  },
  prevUntil: function( elem, i, until ) {
    return jQuery.dir( elem, "previousSibling", until );
  },
  siblings: function( elem ) {
    return jQuery.sibling( ( elem.parentNode || {} ).firstChild, elem );
  },
  children: function( elem ) {
    return jQuery.sibling( elem.firstChild );
  },
  contents: function( elem ) {
    return jQuery.nodeName( elem, "iframe" ) ?
      elem.contentDocument || elem.contentWindow.document :
      jQuery.merge( [], elem.childNodes );
  }
}, function( name, fn ) {
  jQuery.fn[ name ] = function( until, selector ) {
    var matched = jQuery.map( this, fn, until );
  
    if ( name.slice( -5 ) !== "Until" ) {
      selector = until;
    }
  
    if ( selector && typeof selector === "string" ) {
      matched = jQuery.filter( selector, matched );
    }
  
    if ( this.length > 1 ) {
      // Remove duplicates
      if ( !guaranteedUnique[ name ] ) {
        jQuery.unique( matched );
      }
  
      // Reverse order for parents* and prev*
      if ( name[ 0 ] === "p" ) {
        matched.reverse();
      }
    }
  
    return this.pushStack( matched );
  };
});
*/

HTMLElement? _closest(Element? elem, String selector) =>
    _closestWhere(elem, (e) => e.matches(selector));

HTMLElement? _closestWhere(Element? elem, bool test(Element e)) {
  while (elem != null && !test(elem))
    elem = elem.parentElement;
  return elem as HTMLElement?;
}

/*
jQuery.extend({
*/

List<Element> _filter(String expr, List<Element> elements, [bool not = false]) {
  if (not)
    expr = ":not($expr)";
  return elements.where((Element elem) => elem.matches(expr)).toList(growable: true);
}



  /*
  dir: function( elem, dir, until ) {
    var matched = [],
      truncate = until !== undefined;

    while ( (elem = elem[ dir ]) && elem.nodeType !== 9 ) {
      if ( elem.nodeType === 1 ) {
        if ( truncate && jQuery( elem ).is( until ) ) {
          break;
        }
        matched.push( elem );
      }
    }
    return matched;
  },

  sibling: function( n, elem ) {
    var matched = [];

    for ( ; n; n = n.nextSibling ) {
      if ( n.nodeType === 1 && n !== elem ) {
        matched.push( n );
      }
    }

    return matched;
  }
  */
/*
});
*/

// Implement the identical functionality for filter and not
/*
List<Element> _winnow(List<Element> elements, String selector,
    bool test(Element elem, int index), Element element, DQuery dquery, bool not) {
  
  if (test != null) {
    // TODO
    /* src:
    return jQuery.grep( elements, function( elem, i ) {
      // jshint -W018
      return !!qualifier.call( elem, i, elem ) !== not;
    });
    */
  } else if (element != null) {
    return _grep(elements, (elem, index) => (elem == element) != not);
    
  } else if (selector != null) {
    if (_isSimple.hasMatch(selector))
      return _filter(selector, elements, not);
    dquery = _filter(selector, elements);
  }
  
  // TODO: may simplify
  return _grep(elements, (elem, index) => elements.contains(elem) != not);
}
*/
