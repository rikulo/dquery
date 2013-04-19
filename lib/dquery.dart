library dquery;

import 'dart:math';
import 'dart:html';
import 'dart:async';
import 'dart:collection';

part 'src/util/util.dart';
part 'src/core.dart';
part 'src/selector.dart';
part 'src/traversing.dart';
part 'src/data.dart';
part 'src/event.dart';

/**
 * 
 */
ElementQuery $(selector, [context]) {
  
  if (selector == null || selector == '')
    return new ElementQuery([]);
  
  if (selector is String) {
    if (context == null) {
      return _rootDQuery.find(selector);
      
    } else if (context is DQuery) {
      return (context as DQuery).find(selector);
      
    } else if (context is Document) {
      return new DocumentQuery(context).find(selector);
      
    } else if (context is Element) {
      return new ElementQuery([context]).find(selector);
      
    }
    
    throw new ArgumentError("Context type should be Document, Element, or DQuery: $context");
  }
  
  if (selector is Element)
    return new ElementQuery([selector]);
  
  if (selector is List<Element>)
    return new ElementQuery(selector);
  
  throw new ArgumentError("Selector type should be String, Element, or List<Element>: $selector");  
}

/**
 * 
 */
DocumentQuery $d([Document doc]) => new DocumentQuery(doc);

/**
 * 
 */
WindowQuery $w([Window win]) => new WindowQuery(win);

/**
 * 
 */
class DocumentQuery extends DQuery {
  
  final Document _document;
  
  DocumentQuery([Document doc]) : this._document = _fallback(doc, () => document);
  
  // DQuery //
  List<Element> _queryAll(String selector) => 
      _document.queryAll(selector);
  
  void _forEachEventTarget(void f(EventTarget target)) => f(_document);
  
  EventTarget get _first => _document;
  
  int get length => 1;
  
}

/**
 * 
 */
class WindowQuery extends DQuery {
  
  final Window _window;
  
  WindowQuery([Window win]) : this._window = _fallback(win, () => window);
  
  // DQuery //
  List<Element> _queryAll(String selector) => [];
  
  void _forEachEventTarget(void f(EventTarget target)) => f(_window);
  
  EventTarget get _first => _window;
  
  int get length => 1;
  
}

/**
 * 
 */
class ElementQuery extends DQuery with ListMixin<Element> {
  
  final List<Element> _elements;
  
  ElementQuery(this._elements);
  
  String get selector => _selector;
  String _selector;
  
  // List //
  Element operator [](int index) {
      return _elements[index];
  }
  
  int get length => _elements.length;
  
  void operator []=(int index, Element value) {
    _elements[index] = value;
  }
  
  void set length(int newLength) {
    _elements.length = newLength;
  }
  
  // DQuery //
  List<Element> _queryAll(String selector) {
    switch (length) {
      case 0:
        return [];
      case 1:
        return first.queryAll(selector);
      default:
        final List<Element> matched = new List<Element>();
        for (Element elem in _elements)
          matched.addAll(elem.queryAll(selector));
        return unique(matched);
    }
  }
  
  void _forEachEventTarget(void f(EventTarget target)) => forEach(f);
  
  EventTarget get _first => isEmpty ? null : first;
  
}

/**
 * 
 */
typedef DQuery = DQueryCore with TraversingMixin, DataMixin, EventMixin;

// All DQuery objects should point back to these
DocumentQuery _rootDQuery = new DocumentQuery();


