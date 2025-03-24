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

  _Query? _prevObject;
  
  // DQuery //
  List<Element> _queryAll(String selector);
  
  @override
  T? get firstIfAny => isEmpty ? null : first;
  
  @override
  String? get selector => null;
  
  @override
  ElementQuery find(String selector) {
    final String s = this.selector != null ? "${this.selector} $selector" : selector;
    // jQuery: Needed because $( selector, context ) becomes $( context ).find( selector )
    return (pushStack(_queryAll(selector)) as _ElementQuery).._selector = s;
  }
  
  @override
  ElementQuery pushStack(List<Element> elems) =>
      _ElementQuery(elems) // TODO: copy? no copy?
      .._prevObject = this
      .._context = _context;
  
  @override
  DQuery<T> end() => (_prevObject ?? ElementQuery([])) as DQuery<T>;
  
  // data //
  @override
  Data get data => _data ??= Data._(this);
  Data? _data;
  
  // event //
  @override
  void on(String types, QueryEventListener handler, {String? selector}) {
    _on(types, handler, selector, false);
  }
  
  @override
  void one(String types, QueryEventListener handler, {String? selector}) {
    _on(types, handler, selector, true);
  }
  
  void _on(String types, QueryEventListener? handler, String? selector, bool one) {
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
  void off(String types, {String? selector, QueryEventListener? handler}) =>
      forEach((EventTarget t) => _EventUtil.remove(t, types, handler, selector));
  
  // utility refactored from off() to make type clearer
  static void _offEvent(QueryEvent dqevent) {
    final handleObj = dqevent._handleObj,
      namespace = handleObj?.namespace,
      type = (namespace?.isNotEmpty ?? false) ?
        "${handleObj!.origType}.${namespace}" : handleObj!.origType;
    $(dqevent.delegateTarget).off(type!,
      handler: handleObj.handler,
      selector: handleObj.selector);
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
}

class _DocumentQuery extends _Query<Document> with ListMixin<Document>
    implements DocumentQuery {
  
  Document _doc;
  
  _DocumentQuery([Document? doc]) : this._doc = doc ?? document;
  
  // DQuery //
  @override
  Document operator [](int index) => _doc;
  
  @override
  void operator []=(int index, Document? value) {
    if (index != 0 || value == null)
      throw ArgumentError("$index: $value");
    _doc = value;
  }
  
  @override
  int get length => 1;
  
  @override
  void set length(int length) {
    if (length != 1)
      throw UnsupportedError("fixed length");
  }
  
  @override
  List<HTMLElement> _queryAll(String selector) 
    => JSImmutableListWrapper(_doc.querySelectorAll(selector));

  Window? get _win => _doc.defaultView;

 @override
  int? get scrollLeft => _win?.scrollX.toInt();
  
  @override
  int? get scrollTop => _win?.scrollY.toInt();
  
  @override
  void set scrollLeft(int? value) {
    if (value != null && scrollTop != null)
      _win?.scrollTo(value.toJS, scrollTop!);
  }
  
  @override
  void set scrollTop(int? value) {
    if (value != null && scrollLeft != null)
      _win?.scrollTo(scrollLeft!.toJS, value);
  }
      
  
  @override
  int? get width =>
    _max([_doc.body?.scrollWidth, _doc.documentElement?.scrollWidth,
          _doc.body?.offsetWidth,  (_doc.documentElement as HTMLElement?)?.offsetWidth,
          _doc.documentElement?.clientWidth]);
  
  @override
  int? get height =>
    _max([_doc.body?.scrollHeight, _doc.documentElement?.scrollHeight,
          _doc.body?.offsetHeight, (_doc.documentElement as HTMLElement?)?.offsetHeight,
          _doc.documentElement?.clientHeight]);

  @override
  String? cookie(String name, {String? value, Duration? expires, String? path, bool? secure}) {
    if (value != null) {
      _setCookie(_doc, name, value, expires, path, secure);
      return null;
    }
    return _getCookie(_doc, name);
  }
  @override
  Map<String, String> get cookies => _getCookie(_doc);
  @override
  void removeCookie(String name) {
    cookie(name, value: "", expires: const Duration(days: -1));
  }
}

class _WindowQuery extends _Query<Window> with ListMixin<Window>
    implements DQuery<Window> {
  
  Window _win;
  
  _WindowQuery([Window? win]) : this._win = win ?? window;
  
  // DQuery //
  @override
  Window operator [](int index) => _win;
  
  @override
  void operator []=(int index, Window? value) {
    if (index != 0 || value == null)
      throw ArgumentError("$index: $value");
    _win = value;
  }
  
  @override
  int get length => 1;
  
  @override
  void set length(int length) {
    if (length != 1)
      throw UnsupportedError("fixed length");
  }

  @override
  List<HTMLElement> _queryAll(String selector) => [];

  @override
  int get scrollLeft => _win.scrollX.toInt();
  
  @override
  int get scrollTop => _win.scrollY.toInt();
  
  @override
  void set scrollLeft(int? value) {
    if (value != null)
      _win.scrollTo(value.toJS, scrollTop);
  }

  @override
  void set scrollTop(int? value) {
    if (value != null)
      _win.scrollTo(scrollLeft.toJS, value);
  }

  // jQuery: As of 5/8/2012 this will yield incorrect results for Mobile Safari, but there
  //         isn't a whole lot we can do. See pull request at this URL for discussion:
  //         https://github.com/jquery/jquery/pull/764
  @override
  int? get width => _win.document.documentElement?.clientWidth;
  
  @override
  int? get height => _win.document.documentElement?.clientHeight;
  
}

class _ElementQuery extends _Query<HTMLElement> with ListMixin<HTMLElement>
    implements ElementQuery {
  
  final List<Element> _elements;
  
  _ElementQuery(this._elements);
  
  @override
  String? get selector => _selector;
  String? _selector;
  
  // List //
  @override
  HTMLElement operator [](int index) {
      return _elements[index] as HTMLElement;
  }
  
  @override
  int get length => _elements.length;
  
  @override
  void operator []=(int index, HTMLElement value) {
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
        return JSImmutableListWrapper(first.querySelectorAll(selector));
      default:
        final matched = <HTMLElement>[];
        for (final elem in _elements)
          matched.addAll(JSImmutableListWrapper(elem.querySelectorAll(selector)));
        return Query.unique(matched);
    }
  }
  
  // ElementQuery //
  @override
  ElementQuery closest(String selector) {
    final results = LinkedHashSet<HTMLElement>();
    HTMLElement? c;
    for (final e in _elements)
      if ((c = _closest(e, selector)) != null)
        results.add(c!);
    return pushStack(results.toList(growable: true));
  }
  
  @override
  ElementQuery parent([String? selector]) {
    final results = LinkedHashSet<Element>();
    Element? p;
    for (final e in _elements)
      if ((p = e.parentElement) != null && (selector == null || p!.matches(selector)))
        results.add(p!);
    return pushStack(results.toList(growable: true));
  }
  
  @override
  ElementQuery children([String? selector]) {
    final results = <Element>[];
    for (final e in _elements)
      for (final c in JSImmutableListWrapper(e.children).cast<HTMLElement>())
        if (selector == null || c.matches(selector))
          results.add(c);
    return pushStack(results);
  }
  
  @override
  void show() => _showHide(_elements, true);
  
  @override
  void hide() => _showHide(_elements, false);
  
  @override
  void toggle([bool? state]) {
    for (final elem in _elements)
      _showHide([elem], state ?? _isHidden(elem));
  }
  
  @override
  css(String name, [String? value]) =>
      value != null ? _elements.forEach((Element e) => _setCss(e, name, value)) :
          _elements.isEmpty ? null : _getCss(_elements.first, name);
  
  @override
  bool hasClass(String name) =>
      _elements.any((final e) => e.classList.contains(name));
  
  @override
  void addClass(String name) {
    for (final elem in _elements)
      elem.classList.add(name);
  }

  @override
  void removeClass(String name) {
    for (final elem in _elements)
      elem.classList.remove(name);
  }
  
  @override
  void toggleClass(String name) {
    for (final elem in _elements)
      elem.classList.toggle(name);
  }

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
  ElementQuery clone([bool? withDataAndEvents, bool? deepWithDataAndEvents]) =>
      pushStack(_elements.map((e) => _clone(e)).toList());
  
  @override
  void detach({String? selector, bool data = true}) =>
      (selector != null && !(selector = selector.trim()).isEmpty ? 
          _filter(selector, _elements) : List<Element>.from(_elements))
          .forEach((Element e) => _detach(e, data));
  
  @override
  void empty() => _elements.forEach((Element e) => _empty(e));
  
  @override
  String get text =>
      (StringBuffer()..writeAll(_elements.map((elem) => elem.textContent)))
      .toString();
  
  @override
  void set text(String value) =>
      _elements.forEach((Element e) => _setText(e, value));
  
  @override
  String? get html =>
    ((_elements.firstOrNull as HTMLElement?)?.innerHTML as JSString?)?.toDart;
  
  @override
  void set html(String? value) {
    if (value == null) return;

    _elements.forEach((e) 
      => (e as HTMLElement).innerHTML = value.toJS);
  }
  
  @override
  Point? get offset => isEmpty ? null : _getOffset(_elements.first);
  
  @override
  void set offset(Point? value) =>
      _elements.forEach((Element e) => _setOffset(e, left: value?.x, top: value?.y));
  
  @override
  void set offsetLeft(int left) =>
      _elements.forEach((Element e) => _setOffset(e, left: left));
  
  @override
  void set offsetTop(int top) =>
      _elements.forEach((Element e) => _setOffset(e, top: top));
  
  @override
  Point? get position => isEmpty ? null : _getPosition(_elements.first);
  
  @override
  ElementQuery get offsetParent {
    final results = LinkedHashSet<Element>();
    for (final elem in _elements) {
      final parent = _getOffsetParent(elem);
      if (parent != null)
        results.add(parent);
    }

    return pushStack(results.toList(growable: true));
  }
  
  @override
  int? get scrollLeft => _elements.firstOrNull?.scrollLeft.toInt();
  
  @override
  int? get scrollTop => _elements.firstOrNull?.scrollTop.toInt();
  
  @override
  void set scrollLeft(int? value) {
    if (value == null)
      return;

    for (final elem in _elements)
      elem.scrollLeft = value;
  }

  @override
  void set scrollTop(int? value) {
    if (value == null)
      return;

    for (final elem in _elements)
      elem.scrollTop = value;
  }

  @override
  int? get width => _elements.isEmpty ? null : _getElementWidth(_elements.first);
  
  @override
  int? get height => _elements.isEmpty ? null : _getElementHeight(_elements.first);
  
  @override
  void reflow() {
    _elements.forEach(_reflow);
  }
  @override
  void click([QueryEventListener? handler]){
    if (handler != null)
      on('click', handler);
    else
      trigger('click');
  }
  @override
  void change([QueryEventListener? handler]){
    if (handler != null)
      on('change', handler);
    else
      trigger('change');
  }
}

void _reflow(Element? e) {
  //TODO: If Issue 17366 fixed, we don't need it.
  if ((e as HTMLElement?)?.offsetWidth != null) //avoid being optimized
    _reflow(null);
}

class _ShadowRootQuery extends _Query<ShadowRoot> with ListMixin<ShadowRoot> {
  
  ShadowRoot _shadowRoot;
  
  _ShadowRootQuery(ShadowRoot this._shadowRoot);
  
  // DQuery //
  @override
  ShadowRoot operator [](int index) => _shadowRoot;
  
  @override
  void operator []=(int index, ShadowRoot? value) {
    if (index != 0 || value == null)
      throw ArgumentError("$index: $value");
    _shadowRoot = value;
  }
  
  @override
  int get length => 1;
  
  @override
  void set length(int length) {
    if (length != 1)
      throw UnsupportedError("fixed length");
  }
  
  @override
  List<Element> _queryAll(String selector) 
    => JSImmutableListWrapper(_shadowRoot.querySelectorAll(selector));
}

// All DQuery objects should point back to these
final DQuery _rootDQuery = $document();

bool _nodeName(elem, String name) =>
    elem is Element && elem.tagName.toLowerCase() == name.toLowerCase();

/*
List _grep(List list, bool test(obj, index), [bool invert = false]) {
  // USE Dart's implementation
  int i = 0;
  return new List.from(list.where((obj) => invert != test(obj, i++)));
}
*/

String _trim(String? text) => text == null ? '' : text.trim();

