//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
part of dquery;

// TODO: fix selector/context getter
// TODO: check every incoming List<Element> of ElementQuery
// TODO: need to solve data conflict with add() at API level
// TODO: on() handler/selector argument position issue

/**
 * 
 */
abstract class DQuery<T> implements List<T> {
  
  // static methods //
  /**
   * 
   */
  static List<Element> unique(List<Element> elements) => _unique(elements);
  
  // http://api.jquery.com/context/
  /** The DOM node context originally passed to DQuery; if none was passed 
   * then context will likely be the document.
   */
  get context;
  
  String get selector;
  
  /**
   * 
   */
  T get firstIfAny;
  
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
  
  /**
   * 
   */
  DQuery end();
  
  // data //
  /**
   * 
   */
  Data get data;

  // event //
  /** Register a [handler] for events of given [types] on selected elements.
   * + If [selector] is provided, only the descendant elements matched by the
   * selector will trigger the event. If omitted or null, the event will always
   * be triggered.
   * + If [data] is provided, you can retrieve it in [event.data] in the handler.
   */
  void on(String types, DQueryEventListener handler, {String selector, data});
  
  /** Register a one-time [handler] for events of given [types]. Once called, 
   * the handler will be unregistered.
   * + If [selector] is provided, only the descendant elements matched by the
   * selector will trigger the event. If omitted or null, the event will always
   * be triggered.
   * + If [data] is provided, you can retrieve it in [event.data] in the handler.
   */
  void one(String types, DQueryEventListener handler, {String selector, data});

  /** Unregister a [handler] for events of given types.
   * // TODO
   */
  void off(String types, {String selector, DQueryEventListener handler});
  
  /** Trigger an event of given [type] on all matched elements, with given 
   * [data] if provided.
   */
  void trigger(String type, {data});
  
  /** Trigger the given [event] on all matched elements, with given [data] if
   * provided.
   */
  void triggerEvent(DQueryEvent event, {data});
  
  /** 
   * 
   */
  void triggerHandler(String type, {data});

  // traversing //
}

/**
 * 
 */
abstract class DocumentQuery extends DQuery<HtmlDocument> {
  factory DocumentQuery([HtmlDocument document]) => new _DocQuery(document);
}

/**
 * 
 */
abstract class WindowQuery extends DQuery<Window> {
  factory WindowQuery([Window window]) => new _WinQuery(window);
}

/**
 * 
 */
abstract class ElementQuery extends DQuery<Element> {
  factory ElementQuery(List<Element> elements) => new _ElementQuery(elements);
  
  /**
   * 
   */
  ElementQuery closest(String selector);
  
  /**
   * 
   */
  void show();
  
  /**
   * 
   */
  void hide();
  
  /**
   * 
   */
  void toggle([bool state]);
  
}
