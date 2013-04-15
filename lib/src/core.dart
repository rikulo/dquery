part of dquery;

part of dquery;

/*
// The deferred used on DOM ready
readyList,
*/

// jQuery: Support: IE9
//         For `typeof xmlNode.method` instead of `xmlNode.method !== undefined`
// SKIPPED: js only
// src: core_strundefined = typeof undefined,

/*
// Use the correct document accordingly with window argument (sandbox)
location = window.location,
document = window.document,
docElem = document.documentElement,
*/

// jQuery: Map over jQuery in case of overwrite
// SKIPPED: no noConflict
// src: _jQuery = window.jQuery,

// jQuery: Map over the $ in case of overwrite
// SKIPPED: no noConflict
// src: _$ = window.$,

/*
// List of deleted data cache ids, so we can reuse them
core_deletedIds = [],
*/
const String _CORE_VERSION = 'dquery-0.1.0';
/*
// Save a reference to some core methods
core_concat = core_deletedIds.concat,
core_push = core_deletedIds.push,
core_slice = core_deletedIds.slice,
core_indexOf = core_deletedIds.indexOf,
core_toString = class2type.toString,
core_hasOwn = class2type.hasOwnProperty,
core_trim = core_version.trim,
  // Used for matching numbers
core_pnum = /[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|)/.source,

// Used for splitting on whitespace
core_rnotwhite = /\S+/g,

// A simple way to check for HTML strings
// Prioritize #id over <tag> to avoid XSS via location.hash (#9521)
// Strict HTML recognition (#11290: must start with <)
rquickExpr = /^(?:(<[\w\W]+>)[^>]*|#([\w-]*))$/,

// Match a standalone tag
rsingleTag = /^<(\w+)\s*\/?>(?:<\/\1>|)$/,

// Matches dashed string for camelizing
rmsPrefix = /^-ms-/,
rdashAlpha = /-([\da-z])/gi,

// Used by jQuery.camelCase as callback to replace()
fcamelCase = function( all, letter ) {
  return letter.toUpperCase();
},

// The ready event handler and self cleanup method
completed = function() {
  document.removeEventListener( "DOMContentLoaded", completed, false );
  window.removeEventListener( "load", completed, false );
  jQuery.ready();
};
*/

// TODO: use direct implemetation, not proxy list, for reducing overhead
abstract class DQueryBase extends ProxyReadOnlyList<Element> {
  
  // TODO: resume when the stupid Dart mixin bug is fixed
  //_DQueryBase._(List<Element> elements) : super(elements);
  
  // a hook for mixin
  DQuery get _this => this; // TODO: need to be public for 3rd party plugin?
  
  //String get selector => _selector; // TODO: check: not in API!
  String _selector;
  
  // http://api.jquery.com/context/
  /** The DOM node context originally passed to jQuery(); if none was passed 
   * then context will likely be the document.
   */
  get context => _context;
  var _context;
  
  // http://api.jquery.com/jquery-2/
  /** A string containing the jQuery version number.
   */
  get dquery => _CORE_VERSION;
  
  //DQuery get prevObject => _prevObject; // TODO: not in API?
  DQuery _prevObject;
  
  // http://api.jquery.com/pushStack/
  /** Add a collection of DOM elements onto the DQuery stack.
   */
  DQuery pushStack(List<Element> elems) => 
      new DQuery._([], context)
      .._inner.addAll(elems)
      .._prevObject = this;
  
  /*
  first: function() {
    return this.eq( 0 );
  },
  last: function() {
    return this.eq( -1 );
  },
  eq: function( i ) {
    var len = this.length,
    j = +i + ( i < 0 ? len : 0 );
    return this.pushStack( j >= 0 && j < len ? [ this[j] ] : [] );
  },
  map: function( callback ) {
    return this.pushStack( jQuery.map(this, function( elem, i ) {
      return callback.call( elem, i, elem );
    }));
  },  
  end: function() {
    return this.prevObject || this.constructor(null);
  },
  */
  
}

/// A unique string for each copy of dquery // TODO: we probably don't need this? + not API
String get expando => 
    _expando != null ? _expando : (_expando = "dquery-${CORE_VERSION}-${u.randInt()}");
String _expando;

// SKIPPED: no noConflict
// src: noConflict: function( deep ) {

/*
// Is the DOM ready to be used? Set to true once it occurs.
isReady: false,

// A counter to track how many items to wait for before
// the ready event fires. See #6781
readyWait: 1,

// Hold (or release) the ready event
holdReady: function( hold ) {
  if ( hold ) {
    jQuery.readyWait++;
  } else {
    jQuery.ready( true );
  }
},

// Handle when the DOM is ready
ready: function( wait ) {

  // Abort if there are pending holds or we're already ready
  if ( wait === true ? --jQuery.readyWait : jQuery.isReady ) {
    return;
  }

  // Remember that the DOM is ready
  jQuery.isReady = true;

  // If a normal DOM Ready event fired, decrement, and wait if need be
  if ( wait !== true && --jQuery.readyWait > 0 ) {
    return;
  }

  // If there are functions bound, to execute
    readyList.resolveWith( document, [ jQuery ] );

  // Trigger any bound ready events
  if ( jQuery.fn.trigger ) {
    jQuery( document ).trigger("ready").off("ready");
  }
},
*/

// jQuery: See test/unit/core.js for details concerning isFunction.
//         Since version 1.3, DOM methods and functions like alert
//         aren't supported. They return false on IE (#2968).
// SKIPPED: js only
// src: isFunction: function( obj ) {

// SKIPPED: js only
// src: isArray: Array.isArray,

bool _isWindow(obj) => obj != null && obj is Window;

/*
isNumeric: function( obj ) {
  return !isNaN( parseFloat(obj) ) && isFinite( obj );
},

type: function( obj ) {
  if ( obj == null ) {
    return String( obj );
  }
  // Support: Safari <= 5.1 (functionish RegExp)
  return typeof obj === "object" || typeof obj === "function" ?
    class2type[ core_toString.call(obj) ] || "object" :
    typeof obj;
},

isPlainObject: function( obj ) {
  // Not plain objects:
  // - Any object or value whose internal [[Class]] property is not "[object Object]"
  // - DOM nodes
  // - window
  if ( jQuery.type( obj ) !== "object" || obj.nodeType || jQuery.isWindow( obj ) ) {
    return false;
  }
  
  // Support: Firefox <20
  // The try/catch suppresses exceptions thrown when attempting to access
  // the "constructor" property of certain host objects, ie. |window.location|
  // https://bugzilla.mozilla.org/show_bug.cgi?id=814622
  try {
    if ( obj.constructor &&
    !core_hasOwn.call( obj.constructor.prototype, "isPrototypeOf" ) ) {
      return false;
    }
  } catch ( e ) {
    return false;
  }
  
  // If the function hasn't returned already, we're confident that
  // |obj| is a plain object, created by {} or constructed with new Object
  return true;
},
*/

// SKIPPED: js only
// src: isEmptyObject: function( obj ) {

/*
error: function( msg ) {
  throw new Error( msg );
},

// data: string of html
// context (optional): If specified, the fragment will be created in this context, defaults to document
// keepScripts (optional): If true, will include scripts passed in the html string
parseHTML: function( data, context, keepScripts ) {
  if ( !data || typeof data !== "string" ) {
    return null;
  }
  if ( typeof context === "boolean" ) {
    keepScripts = context;
    context = false;
  }
  context = context || document;

  var parsed = rsingleTag.exec( data ),
  scripts = !keepScripts && [];

  // Single tag
  if ( parsed ) {
    return [ context.createElement( parsed[1] ) ];
  }

  parsed = jQuery.buildFragment( [ data ], context, scripts );

  if ( scripts ) {
    jQuery( scripts ).remove();
  }

  return jQuery.merge( [], parsed.childNodes );
},

parseJSON: JSON.parse,

// Cross-browser xml parsing
parseXML: function( data ) {
  var xml, tmp;
  if ( !data || typeof data !== "string" ) {
    return null;
  }

  // Support: IE9
  try {
    tmp = new DOMParser();
    xml = tmp.parseFromString( data , "text/xml" );
  } catch ( e ) {
    xml = undefined;
  }

  if ( !xml || xml.getElementsByTagName( "parsererror" ).length ) {
    jQuery.error( "Invalid XML: " + data );
  }
  return xml;
},
*/
void _noop() {}
/*
// Evaluates a script in a global context
globalEval: function( code ) {
  var script,
  indirect = eval;

  code = jQuery.trim( code );

  if ( code ) {
    // If the code includes a valid, prologue position
    // strict mode pragma, execute code by injecting a
    // script tag into the document.
    if ( code.indexOf("use strict") === 1 ) {
      script = document.createElement("script");
      script.text = code;
      document.head.appendChild( script ).parentNode.removeChild( script );
    } else {
      // Otherwise, avoid the DOM node creation, insertion
      // and removal by using an indirect global eval
      indirect( code );
    }
  }
},

// Convert dashed to camelCase; used by the css and data modules
// Microsoft forgot to hump their vendor prefix (#9572)
camelCase: function( string ) {
  return string.replace( rmsPrefix, "ms-" ).replace( rdashAlpha, fcamelCase );
},
*/
bool _nodeName(elem, String name) =>
    elem is Element && (elem as Element).tagName.toLowerCase() == name.toLowerCase();

/*
// args is for internal usage only
each: function( obj, callback, args ) {
  var value,
    i = 0,
    length = obj.length,
    isArray = isArraylike( obj );

  if ( args ) {
    if ( isArray ) {
      for ( ; i < length; i++ ) {
        value = callback.apply( obj[ i ], args );

        if ( value === false ) {
          break;
        }
      }
    } else {
      for ( i in obj ) {
        value = callback.apply( obj[ i ], args );

        if ( value === false ) {
          break;
        }
      }
    }

    // A special, fast, case for the most common use of each
  } else {
    if ( isArray ) {
      for ( ; i < length; i++ ) {
        value = callback.call( obj[ i ], i, obj[ i ] );

        if ( value === false ) {
          break;
        }
      }
    } else {
      for ( i in obj ) {
        value = callback.call( obj[ i ], i, obj[ i ] );

        if ( value === false ) {
          break;
        }
      }
    }
  }

  return obj;
},
*/
String trim(String text) => text == null ? '' : text.trim();

/*
// results is for internal usage only
makeArray: function( arr, results ) {
  var ret = results || [];

  if ( arr != null ) {
    if ( isArraylike( Object(arr) ) ) {
      jQuery.merge( ret,
        typeof arr === "string" ?
        [ arr ] : arr
      );
    } else {
      core_push.call( ret, arr );
    }
  }

  return ret;
},

inArray: function( elem, arr, i ) {
  return arr == null ? -1 : core_indexOf.call( arr, elem, i );
},

merge: function( first, second ) {
  var l = second.length,
  i = first.length,
  j = 0;

  if ( typeof l === "number" ) {
    for ( ; j < l; j++ ) {
      first[ i++ ] = second[ j ];
    }
  } else {
    while ( second[j] !== undefined ) {
      first[ i++ ] = second[ j++ ];
    }
  }

  first.length = i;

  return first;
},
*/

/**
 * 
 */
List grep(List list, bool test(obj, index), [bool invert = false]) {
  // USE Dart's implementation
  int i = 0;
  return new List.from(list.where((obj) => invert != test(obj, i++)));
}

/*
// arg is for internal usage only
map: function( elems, callback, arg ) {
  var value,
    i = 0,
    length = elems.length,
    isArray = isArraylike( elems ),
    ret = [];

  // Go through the array, translating each of the items to their
  if ( isArray ) {
    for ( ; i < length; i++ ) {
      value = callback( elems[ i ], i, arg );

      if ( value != null ) {
        ret[ ret.length ] = value;
      }
    }

  // Go through every key on the object,
  } else {
    for ( i in elems ) {
      value = callback( elems[ i ], i, arg );

      if ( value != null ) {
        ret[ ret.length ] = value;
      }
    }
  }

  // Flatten any nested arrays
  return core_concat.apply( [], ret );
},
*/

// jQuery: A global GUID counter for objects
int _guid = 1;

/*
// Bind a function to a context, optionally partially applying any
// arguments.
proxy: function( fn, context ) {
  var tmp, args, proxy;

  if ( typeof context === "string" ) {
    tmp = fn[ context ];
    context = fn;
    fn = tmp;
  }

  // Quick check to determine if target is callable, in the spec
  // this throws a TypeError, but we will just return undefined.
  if ( !jQuery.isFunction( fn ) ) {
    return undefined;
  }

  // Simulated bind
  args = core_slice.call( arguments, 2 );
  proxy = function() {
    return fn.apply( context || this, args.concat( core_slice.call( arguments ) ) );
  };

  // Set the guid of unique handler to the same of original handler, so it can be removed
  proxy.guid = fn.guid = fn.guid || jQuery.guid++;

  return proxy;
},

// Multifunctional method to get and set values of a collection
// The value/s can optionally be executed if it's a function
access: function( elems, fn, key, value, chainable, emptyGet, raw ) {
  var i = 0,
    length = elems.length,
    bulk = key == null;

  // Sets many values
  if ( jQuery.type( key ) === "object" ) {
    chainable = true;
    for ( i in key ) {
      jQuery.access( elems, fn, i, key[i], true, emptyGet, raw );
    }

  // Sets one value
  } else if ( value !== undefined ) {
    chainable = true;

    if ( !jQuery.isFunction( value ) ) {
      raw = true;
    }

    if ( bulk ) {
      // Bulk operations run against the entire set
      if ( raw ) {
        fn.call( elems, value );
        fn = null;

        // ...except when executing function values
      } else {
        bulk = fn;
        fn = function( elem, key, value ) {
          return bulk.call( jQuery( elem ), value );
        };
      }
    }

    if ( fn ) {
      for ( ; i < length; i++ ) {
        fn( elems[i], key, raw ? value : value.call( elems[i], i, fn( elems[i], key ) ) );
      }
    }
  }

  return chainable ?
    elems :

    // Gets
    bulk ?
      fn.call( elems ) :
      length ? fn( elems[0], key ) : emptyGet;
},

now: Date.now,

// A method for quickly swapping in/out CSS properties to get correct calculations.
// Note: this method belongs to the css module but it's needed here for the support module.
// If support gets modularized, this method should be moved back to the css module.
swap: function( elem, options, callback, args ) {
  var ret, name,
    old = {};

  // Remember the old values, and insert the new ones
  for ( name in options ) {
    old[ name ] = elem.style[ name ];
    elem.style[ name ] = options[ name ];
  }

  ret = callback.apply( elem, args || [] );

  // Revert the old values
  for ( name in options ) {
    elem.style[ name ] = old[ name ];
  }

  return ret;
},
*/

/*
// [[Class]] -> type pairs
class2type = {},

// Populate the class2type map
jQuery.each("Boolean Number String Function Array Date RegExp Object Error".split(" "), function(i, name) {
  class2type[ "[object " + name + "]" ] = name.toLowerCase();
});
*/

/*
function isArraylike( obj ) {
  var length = obj.length,
    type = jQuery.type( obj );

  if ( jQuery.isWindow( obj ) ) {
    return false;
  }

  if ( obj.nodeType === 1 && length ) {
    return true;
  }

  return type === "array" || type !== "function" &&
     ( length === 0 ||
      typeof length === "number" && length > 0 && ( length - 1 ) in obj );
}
*/

// All jQuery objects should point back to these
DQuery _rootDQuery = new DQuery(null, document);
