//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
part of dquery;

/**
 * 
 */
abstract class DQuery {
  /**
   * 
   */
  static List<Element> unique(List<Element> elements) => _unique(elements);

  // http://api.jquery.com/context/
  /** The DOM node context originally passed to DQuery; if none was passed 
   * then context will likely be the document.
   */
  get context;

  // http://api.jquery.com/jquery-2/
  // A string containing the DQuery version number.
  //get dquery => _CORE_VERSION;

  String get selector;

  /// The number of selected element.
  int get length;
  /// Returns if there is any selected element.
  bool get isEmpty;
  // moved from traversing to eliminate cyclic dependency
  // http://api.jquery.com/find/
  /**
   * 
   */
  ElementQuery find(String selector);

  // skipped unless necessary
  //DQuery find(DQuery dquery); // requires filter()
  //DQuery find(Element element);
  
  // http://api.jquery.com/pushStack/
  /** Add a collection of DOM elements onto the DQuery stack.
   */
  ElementQuery pushStack(List<Element> elems);

  DQuery end();

  // data //
  /**
   * 
   */
  Data get data;

  // event //
  /**
   * 
   */
  void on(String types, DQueryEventListener handler, {String selector, data});
  
  /**
   * 
   */
  void one(String types, DQueryEventListener handler, {String selector, data});

  /**
   * 
   */
  void off(String types, DQueryEventListener handler, {String selector});

  /**
   * 
   */
  void trigger(String type, [data]);

  /**
   * 
   */
  void triggerHandler(String type, [data]);

  // traversing //
}

/**
 * 
 */
abstract class DocumentQuery extends DQuery {
  factory DocumentQuery([Document document]) => new _DocQuery(document);
}

/**
 * 
 */
abstract class WindowQuery extends DQuery {
  factory WindowQuery([Window window]) => new _WinQuery(window);
}

/**
 * 
 */
abstract class ElementQuery extends DQuery implements List {
  factory ElementQuery(List<Element> elements) => new _ElementQuery(elements);
}
