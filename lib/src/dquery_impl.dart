//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
part of dquery;

// TODO: may simplify _first and _forEachEventTarget()

///Skeltal implementation of [Query]
abstract class _Query<T extends EventTarget> implements Query<T> {
  
  // skipped unless necessary
  // void _dquery(DQuery dquery) {}
  // void _function() {}
  // void _object() {}
  // void _html() {}
  
  @override
  get context => _context;
  var _context;

  _Query _prevObject;
  
  // DQuery //
  List<Element> _queryAll(String selector);
  
  @override
  T get firstIfAny => isEmpty ? null : first;
  
  @override
  String get selector => null;
  
  @override
  ElementQuery find(String selector) {
    final String s = this.selector != null ? "${this.selector} $selector" : selector;
    // jQuery: Needed because $( selector, context ) becomes $( context ).find( selector )
    return (pushStack(_queryAll(selector)) as _ElementQuery).._selector = s;
  }
  
  @override
  ElementQuery pushStack(List<Element> elems) => 
      new _ElementQuery(elems) // TODO: copy? no copy?
      .._prevObject = this
      .._context = _context;
  
  @override
  DQuery end() => _fallback(_prevObject, () => new ElementQuery([]));
  
  // data //
  @override
  Data get data => _fallback(_data, () => (_data = new Data._(this)));
  Data _data;
  
  // event //
  @override
  void on(String types, QueryEventListener handler, {String selector}) {
    _on(types, handler, selector, false);
  }
  
  @override
  void one(String types, QueryEventListener handler, {String selector}) {
    _on(types, handler, selector, true);
  }
  
  void _on(String types, QueryEventListener handler, String selector, bool one) {
    if (handler == null)
      return;
    
    // TODO: handle guid for removal
    QueryEventListener h = !one ? handler : (QueryEvent dqevent) {
      // jQuery: Can use an empty set, since event contains the info
      _offEvent(dqevent);
      handler(dqevent);
    };
    
    forEach((EventTarget t) => _EventUtil.add(t, types, h, selector));
  }
  
  @override
  void off(String types, {String selector, QueryEventListener handler}) =>
      forEach((EventTarget t) => _EventUtil.remove(t, types, handler, selector));
  
  // utility refactored from off() to make type clearer
  static void _offEvent(QueryEvent dqevent) {
    final _HandleObject handleObj = dqevent._handleObj;
    final String namespace = handleObj.namespace;
    final String type = namespace != null && !namespace.isEmpty ? 
        "${handleObj.origType}.${namespace}" : handleObj.origType;
    $(dqevent.delegateTarget).off(type, handler: handleObj.handler, selector: handleObj.selector);
  }
  
  @override
  void trigger(String type, {data}) =>
      forEach((EventTarget t) => _EventUtil.trigger(type, data, t));
  
  @override
  void triggerEvent(QueryEvent event) =>
      forEach((EventTarget t) => _EventUtil.triggerEvent(event.._target = t));
  
  @override
  void triggerHandler(String type, {data}) {
    if (!isEmpty)
      _EventUtil.trigger(type, data, first, true);
  }
  
  // traversing //
  
}

class _DocumentQuery extends _Query<HtmlDocument> with ListMixin<HtmlDocument>
    implements DQuery<HtmlDocument> {
  
  HtmlDocument _doc;
  
  _DocumentQuery([HtmlDocument doc]) : this._doc = _fallback(doc, () => document);
  
  // DQuery //
  @override
  HtmlDocument operator [](int index) => _doc;
  
  @override
  void operator []=(int index, HtmlDocument value) {
    if (index != 0 || value == null)
      throw new ArgumentError("$index: $value");
    _doc = value;
  }
  
  @override
  int get length => 1;
  
  @override
  void set length(int length) {
    if (length != 1)
      throw new UnsupportedError("fixed length");
  }
  
  @override
  List<Element> _queryAll(String selector) => _doc.querySelectorAll(selector);
  
  Window get _win => _doc.window;

 @override
  int get scrollLeft => _win.pageXOffset;
  
  @override
  int get scrollTop => _win.pageYOffset;
  
  @override
  void set scrollLeft(int value) => 
      _win.scrollTo(value, _win.pageYOffset);
  
  @override
  void set scrollTop(int value) => 
      _win.scrollTo(_win.pageXOffset, value);
  
  @override
  int get width =>
      _max([_doc.body.scrollWidth, _doc.documentElement.scrollWidth,
            _doc.body.offsetWidth, _doc.documentElement.offsetWidth,
            _doc.documentElement.clientWidth]);
  
  @override
  int get height =>
      _max([_doc.body.scrollHeight, _doc.documentElement.scrollHeight,
            _doc.body.offsetHeight, _doc.documentElement.offsetHeight,
            _doc.documentElement.clientHeight]);
}

class _WindowQuery extends _Query<Window> with ListMixin<Window>
    implements DQuery<Window> {
  
  Window _win;
  
  _WindowQuery([Window win]) : this._win = _fallback(win, () => window);
  
  // DQuery //
  @override
  Window operator [](int index) => _win;
  
  @override
  void operator []=(int index, Window value) {
    if (index != 0 || value == null)
      throw new ArgumentError("$index: $value");
    _win = value;
  }
  
  @override
  int get length => 1;
  
  @override
  void set length(int length) {
    if (length != 1)
      throw new UnsupportedError("fixed length");
  }

  @override
  List<Element> _queryAll(String selector) => [];

  @override
  int get scrollLeft => _win.pageXOffset;
  
  @override
  int get scrollTop => _win.pageYOffset;
  
  @override
  void set scrollLeft(int value) => 
      _win.scrollTo(value, _win.pageYOffset);
  
  @override
  void set scrollTop(int value) => 
      _win.scrollTo(_win.pageXOffset, value);
  
  // jQuery: As of 5/8/2012 this will yield incorrect results for Mobile Safari, but there
  //         isn't a whole lot we can do. See pull request at this URL for discussion:
  //         https://github.com/jquery/jquery/pull/764
  @override
  int get width => _win.document.documentElement.clientWidth;
  
  @override
  int get height => _win.document.documentElement.clientHeight;
  
}

class _ElementQuery extends _Query<Element> with ListMixin<Element>
    implements ElementQuery {
  
  final List<Element> _elements;
  
  _ElementQuery(this._elements);
  
  @override
  String get selector => _selector;
  String _selector;
  
  // List //
  @override
  Element operator [](int index) {
      return _elements[index];
  }
  
  @override
  int get length => _elements.length;
  
  @override
  void operator []=(int index, Element value) {
    _elements[index] = value;
  }
  
  @override
  void set length(int length) {
    _elements.length = length;
  }
  
  // DQuery //
  @override
  List<Element> _queryAll(String selector) {
    switch (length) {
      case 0:
        return [];
      case 1:
        return first.querySelectorAll(selector);
      default:
        final List<Element> matched = new List<Element>();
        for (Element elem in _elements)
          matched.addAll(elem.querySelectorAll(selector));
        return Query.unique(matched);
    }
  }
  
  // ElementQuery //
  @override
  ElementQuery closest(String selector) {
    final Set<Element> results = new LinkedHashSet<Element>();
    Element c;
    for (Element e in _elements)
      if ((c = _closest(e, selector)) != null)
        results.add(c);
    return pushStack(results.toList(growable: true));
  }
  
  @override
  ElementQuery parent([String selector]) {
    final Set<Element> results = new LinkedHashSet<Element>();
    Element p;
    for (Element e in _elements)
      if ((p = e.parent) != null && (selector == null || p.matches(selector)))
        results.add(p);
    return pushStack(results.toList(growable: true));
  }
  
  @override
  ElementQuery children([String selector]) {
    final List<Element> results = new List<Element>();
    for (Element e in _elements)
      for (Element c in e.children)
        if (selector == null || c.matches(selector))
          results.add(c);
    return pushStack(results);
  }
  
  @override
  void show() => _showHide(_elements, true);
  
  @override
  void hide() => _showHide(_elements, false);
  
  @override
  void toggle([bool state]) {
    for (Element elem in _elements)
      _showHide([elem], _fallback(state, () => _isHidden(elem)));
  }
  
  @override
  css(String name, [String value]) =>
      value != null ? _elements.forEach((Element e) => _setCss(e, name, value)) :
          _elements.isEmpty ? null : _getCss(_elements.first, name);
  
  @override
  bool hasClass(String name) =>
      _elements.any((Element e) => e.classes.contains(name));
  
  @override
  void addClass(String name) =>
      _elements.forEach((Element e) => e.classes.add(name));
  
  @override
  void removeClass(String name) =>
      _elements.forEach((Element e) => e.classes.remove(name));
  
  @override
  void toggleClass(String name) =>
      _elements.forEach((Element e) => e.classes.toggle(name));
  
  @override
  void appendTo(target) =>
      _domManip(_resolveManipTarget(target), this, _appendFunc);
  
  @override
  void prependTo(target) =>
      _domManip(_resolveManipTarget(target), this, _prependFunc);
  
  @override
  void append(content) => _domManip(this, content, _appendFunc);
  
  @override
  void prepend(content) => _domManip(this, content, _prependFunc);
  
  @override
  void before(content) => _domManip(this, content, _beforeFunc);
  
  @override
  void after(content) => _domManip(this, content, _afterFunc);
  
  @override
  ElementQuery clone([bool withDataAndEvents, bool deepWithDataAndEvents]) =>
      pushStack(_elements.map((Element e) => _clone(e)));
  
  @override
  void detach({String selector, bool data: true}) => 
      (selector != null && !(selector = selector.trim()).isEmpty ? 
          _filter(selector, _elements) : new List<Element>.from(_elements))
          .forEach((Element e) => _detach(e, data));
  
  @override
  void empty() => _elements.forEach((Element e) => _empty(e));
  
  @override
  String get text =>
      (new StringBuffer()..writeAll(_elements.map((Element elem) => elem.text)))
      .toString();
  
  @override
  void set text(String value) =>
      _elements.forEach((Element e) => _setText(e, value));
  
  @override
  String get html =>
      isEmpty ? null : _elements.first.innerHtml;
  
  @override
  void set html(String value) =>
      _elements.forEach((Element e) => e.innerHtml = value);
  
  @override
  Point get offset => isEmpty ? null : _getOffset(_elements.first);
  
  @override
  void set offset(Point value) =>
      _elements.forEach((Element e) => _setOffset(e, left: value.x, top: value.y));
  
  @override
  void set offsetLeft(int left) =>
      _elements.forEach((Element e) => _setOffset(e, left: left));
  
  @override
  void set offsetTop(int top) =>
      _elements.forEach((Element e) => _setOffset(e, top: top));
  
  @override
  Point get position => isEmpty ? null : _getPosition(_elements.first);
  
  @override
  ElementQuery get offsetParent {
    final Set<Element> results = new LinkedHashSet<Element>();
    for (Element e in _elements)
      results.add(_getOffsetParent(e));
    return pushStack(results.toList(growable: true));
  }
  
  @override
  int get scrollLeft => isEmpty ? null : _elements.first.scrollLeft;
  
  @override
  int get scrollTop => isEmpty ? null : _elements.first.scrollTop;
  
  @override
  void set scrollLeft(int value) =>
      _elements.forEach((Element e) => e.scrollLeft = value);
  
  @override
  void set scrollTop(int value) =>
      _elements.forEach((Element e) => e.scrollTop = value);
  
  @override
  int get width => _elements.isEmpty ? null : _getElementWidth(_elements.first);
  
  @override
  int get height => _elements.isEmpty ? null : _getElementHeight(_elements.first);
  
  @override
  void reflow() {
    _elements.forEach(_reflow);
  }
}

void _reflow(Element e) {
  //TODO: If Issue 17366 fixed, we don't need it.
  if (e != null && e.offsetWidth == null) //avoid being optimized
    _reflow(null);
}

class _ShadowRootQuery extends _Query<ShadowRoot> with ListMixin<ShadowRoot> {
  
  ShadowRoot _shadowRoot;
  
  _ShadowRootQuery(ShadowRoot this._shadowRoot);
  
  // DQuery //
  @override
  ShadowRoot operator [](int index) => _shadowRoot;
  
  @override
  void operator []=(int index, ShadowRoot value) {
    if (index != 0 || value == null)
      throw new ArgumentError("$index: $value");
    _shadowRoot = value;
  }
  
  @override
  int get length => 1;
  
  @override
  void set length(int length) {
    if (length != 1)
      throw new UnsupportedError("fixed length");
  }
  
  @override
  List<Element> _queryAll(String selector) => _shadowRoot.querySelectorAll(selector);
}

// All DQuery objects should point back to these
final DQuery _rootDQuery = $document();

bool _nodeName(elem, String name) =>
    elem is Element && (elem as Element).tagName.toLowerCase() == name.toLowerCase();

List _grep(List list, bool test(obj, index), [bool invert = false]) {
  // USE Dart's implementation
  int i = 0;
  return new List.from(list.where((obj) => invert != test(obj, i++)));
}

String _trim(String text) => text == null ? '' : text.trim();

// jQuery: A global GUID counter for objects
int _guid = 1;
