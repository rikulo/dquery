part of dquery;

// things to fix:
// 1. perform default action
// 2. namespace, multiple types
// 4. replace guid with Expando
// 5. off()

// static helper class
class _EventUtil {

  //static Set<String> _global = new HashSet<String>();

  static void add(EventTarget eventTarget, String types, QueryEventListener handler, String selector) {

    final bool hasSelector = selector != null && !selector.isEmpty;

    // jQuery: Don't attach events to noData or text/comment nodes (but allow plain objects)
    if (eventTarget is CharacterData)
      return;

    final Map space = _dataPriv.getSpace(eventTarget);
    // if (elemData == null) return;

    // jQuery: Init the element's event structure and main handler, if this is the first
    final Map<String, _HandleObjectContext> events =
        space.putIfAbsent('events', () => {});
    // the joint proxy handler
    final Map<String, EventListener> eventHandles =
        space.putIfAbsent('handles', () => {});

    // jQuery: Handle multiple events separated by a space
    for (String type in _splitTypes(types)) {

      // calculate namespaces
      List<String> namespaces = [];
      if (type.indexOf('.') >= 0) {
        namespaces = type.split('.');
        type = namespaces.removeAt(0);
        namespaces.sort();
      }
      final String origType = type;

      // jQuery: There *must* be a type, no attaching namespace-only handlers
      if (type.isEmpty)
        continue;

      // jQuery: If event changes its type, use the special event handlers for the changed type
      _SpecialEventHandling special = _getSpecial(type);
      // jQuery: If selector defined, determine special event api type, otherwise given type
      type = _fallback(hasSelector ? special.delegateType : special.bindType, () => type);
      // jQuery: Update special based on newly reset type
      special = _getSpecial(type);

      // jQuery: handleObj is passed to all event handlers
      final bool needsContext = hasSelector && _EventUtil._NEEDS_CONTEXT.hasMatch(selector);
      _HandleObject handleObj = new _HandleObject(selector, type, origType,
          namespaces.join('.'), needsContext, handler);

    final EventListener eventHandle = eventHandles.putIfAbsent(type, 
      () => (e) {
        // jQuery: Discard the second event of a jQuery.event.trigger() and
        //         when an event is called after a page has unloaded
        if (e == null || _EventUtil._triggered != type)
          dispatch(eventTarget, new QueryEvent.from(e), type: type);
      });

      // jQuery: Init the event handler queue if we're the first
      _HandleObjectContext handleObjCtx = events.putIfAbsent(type, () {
        // jQuery: Only use addEventListener/attachEvent if the special events handler returns false
        if (special.setup == null || !special.setup(eventTarget))
          eventTarget.addEventListener(type, eventHandle, false);
        return new _HandleObjectContext();
      });

      // special add: skipped for now
      (hasSelector ? handleObjCtx.delegates : handleObjCtx.handlers).add(handleObj);

      // jQuery: Keep track of which events have ever been used, for event optimization
      //_global.add(type); // TODO: check use

    }

  }

  // jQuery: Detach an event or set of events from an element
  static void remove(EventTarget elem, String types, QueryEventListener handler,
                     String selector, [bool mappedTypes = false]) {

    final Map<String, _HandleObjectContext> events = _dataPriv.get(elem, 'events');
    if (events == null)
      return;

    // jQuery: Once for each type.namespace in types; type may be omitted
    for (String type in _splitTypes(types)) {

      // caculate namespaces
      List<String> namespaces = [];
      if (type.indexOf('.') >= 0) {
        namespaces = type.split('.');
        type = namespaces.removeAt(0);
        namespaces.sort();
      }
      final String origType = type;

      // jQuery: Unbind all events (on this namespace, if provided) for the element
      if (type.isEmpty) {
        final String ns = namespaces.join('.');
        for (String t in events.keys.toList())
          remove(elem, "$t.$ns", handler, selector, true);
        continue;
      }

      _SpecialEventHandling special = _getSpecial(type);
      type = _fallback(selector != null ? special.delegateType : special.bindType, () => type);

      _HandleObjectContext handleObjCtx = _fallback(events[type], () => _HandleObjectContext.EMPTY);
      List<_HandleObject> delegates = handleObjCtx.delegates;
      List<_HandleObject> handlers = handleObjCtx.handlers;

      // jQuery: Remove matching events
      Function filter = (_HandleObject handleObj) {
        bool matchNamespaces() {
          for (final ns in handleObj.namespace.split('.')) {
            if (namespaces.contains(ns))
              return true;
          }
          return false;
        }
        final bool res =
            (mappedTypes || origType == handleObj.origType) &&
            (handler == null || handler == handleObj.handler) &&
            (namespaces.isEmpty || matchNamespaces()) &&
            (selector == null || selector == handleObj.selector || (selector == '**' && handleObj.selector != null));

        // special remove: skipped for now

        return res;
      };

      delegates.removeWhere(filter);
      handlers.removeWhere(filter);

      // jQuery: Remove generic event handler if we removed something and no more handlers exist
      //         (avoids potential for endless recursion during removal of special event handlers)
      if (delegates.isEmpty && handlers.isEmpty) {
        if (special.teardown == null || !special.teardown(elem)) {
          final Map<String, EventListener> eventHandles =
              _dataPriv.get(elem, 'handles');
          if (eventHandles != null) {
            final eventHandle = eventHandles[type];
            if (eventHandle != null)
              elem.removeEventListener(type, eventHandle);
          }
        }

        events.remove(type);
      }

    }

    // jQuery: Remove the expando if it's no longer used
    if (events.isEmpty) {
      _dataPriv.remove(elem, 'handles');

       // jQuery: removeData also checks for emptiness and clears the expando if empty
       //         so use it instead of delete
      _dataPriv.remove(elem, 'events');
    }

  }

  static final RegExp _NEEDS_CONTEXT = new RegExp(r'^[\x20\t\r\n\f]*[>+~]');

  static bool _subsetOf(List<String> a, List<String> b) {
    // assume a and b are sorted
    Iterator<String> ia = a.iterator;
    for (String sb in b) {
      String sa = ia.current;
      if (sa == null)
        return true;
      int c = sa.compareTo(sb);
      if (c < 0)
        return false;
      if (c == 0)
        ia.moveNext();
    }
    return true;
  }

  static final RegExp _SPACES = new RegExp(r'\s+');

  static List<String> _splitTypes(String types) {
    return types == null ? [] : types.split(_SPACES);
  }

  static bool _focusMorphMatch(String type1, String type2) =>
      (type1 == 'focusin' && type2 == 'focus') || (type1 == 'focusout' && type2 == 'blur');

  static String _triggered;

  static void trigger(String type, data, EventTarget elem, [bool onlyHandlers = false]) {
    _EventUtil.triggerEvent(new QueryEvent(type, target: elem, data: data), onlyHandlers);
  }

  static void triggerEvent(QueryEvent event, [bool onlyHandlers = false]) {
    EventTarget elem = _fallback(event.target, () => document);

    String type = event.type;
    List<String> namespaces = [];
    if (type.indexOf('.') >= 0) {
      namespaces = type.split('.');
      type = namespaces.removeAt(0);
      namespaces.sort();
    }

    final String ontype = type.indexOf(':') < 0 ? "on$type" : null; // TODO: check use

    final List<Node> eventPath = [elem];

    // jQuery: Don't do events on text and comment nodes
    if (elem is CharacterData)
      return;

    // jQuery: focus/blur morphs to focusin/out; ensure we're not firing them right now
    if (_focusMorphMatch(type, _EventUtil._triggered))
      return;

    // jQuery: Trigger bitmask: & 1 for native handlers; & 2 for jQuery (always true)
    //event._isTrigger = onlyHandlers ? 2 : 3;
    if (!namespaces.isEmpty)
      event._namespace = namespaces.join('.');
    event._reNamespace = event.namespace != null ?
        new RegExp( '(^|\\.)${namespaces.join("\\.(?:.*\\.|)")}(\\.|\$)') : null;

    // jQuery: Determine event propagation path in advance, per W3C events spec (#9951)
    //         Bubble up to document, then to window; watch for a global ownerDocument var (#9724)
    String bubbleType = null;
    _SpecialEventHandling special = _getSpecial(type);
    if (!onlyHandlers && !special.noBubble && elem is Node) {
      Node n = elem;
      bubbleType = _fallback(special.delegateType, () => type);
      final bool focusMorph = _focusMorphMatch(bubbleType, type);

      for (Node cur = focusMorph ? n : n.parentNode; cur != null; cur = cur.parentNode) {
        eventPath.add(cur);
      }

      // jQuery: Only add window if we got to document (e.g., not plain obj or detached DOM)
      // TODO
      /*
      if (tmp == _fallback(elem.ownerDocument, () => document))
        eventPathWindow = _fallback((tmp as Document).window, () => window);
      */

    }

    // jQuery: Fire handlers on the event path
    bool first = true;
    for (Node n in eventPath) {
      if (event.propagationStopped)
        break;
      event._type = !first ? bubbleType : _fallback(special.bindType, () => type);

      // jQuery: jQuery handler
      if (_getEvents(n).containsKey(event.type)) {
        // here we've refactored the implementation apart from jQuery
        _EventUtil.dispatch(n, event); //use event.type
      }

      // native handler is skipped, no way to do it in Dart

      first = false;
    }
    /*
    if (eventPathWindow != null) {
      // TODO
    }
    */
    event._type = type;

    // jQuery: If nobody prevented the default action, do it now
    if (!onlyHandlers && !event.defaultPrevented) {
      if (!(type == "click" && _nodeName(elem, "a"))) {
        // jQuery: Call a native DOM method on the target with the same name name as the event.
        // jQuery: Don't do default actions on window, that's where global variables be (#6170)

        if (ontype != null && _hasAction(elem, type)) {
          // jQuery: Prevent re-triggering of the same event, since we already bubbled it above
          _EventUtil._triggered = type;
          _performAction(elem, type);
          _EventUtil._triggered = null;
        }
      }
    }
  }

  static void dispatch(EventTarget elem, QueryEvent dqevent, {String type}) {
    if (type == null) type = dqevent.type;
    final _HandleObjectContext handleObjCtx = _getHandleObjCtx(elem, type);

    dqevent._delegateTarget = elem;

    // jQuery: Determine handlers
    final List<_HandlerQueueEntry> handlerQueue = _EventUtil.handlers(elem, dqevent, handleObjCtx);

    for (_HandlerQueueEntry matched in handlerQueue) {
      if (dqevent.propagationStopped) break;
      dqevent._currentTarget = matched.elem;
      // copy to avoid concurrent modification
      for (_HandleObject handleObj in new List<_HandleObject>.from(matched.handlers)) {
        if (dqevent.immediatePropagationStopped) break;
        // jQuery: Triggered event must either 1) have no namespace, or
        //         2) have namespace(s) a subset or equal to those in the bound event (both can have no namespace).
        if (dqevent._reNamespace == null || dqevent._reNamespace.hasMatch(handleObj.namespace)) {
          final List<String> eventns = dqevent.namespace == null ? [] : dqevent.namespace.split('.');
          final List<String> hobjns = handleObj.namespace == null ? [] : handleObj.namespace.split('.');
          if (_subsetOf(eventns, hobjns)) {
            dqevent._handleObj = handleObj;

            _SpecialEventHandling special = _getSpecial(handleObj.origType);

            (special != null && special.handle != null ? special.handle: handleObj.handler)(dqevent);

            bool ret = dqevent.ret;
            if ( ret != null ) {
              if ((dqevent.result = ret) == false) {
                dqevent.preventDefault();
                dqevent.stopPropagation();
              }
            }
          }
        }
      }
    }

  }

  static List<_HandlerQueueEntry> handlers(EventTarget elem, QueryEvent dqevent,
      _HandleObjectContext handleObjCtx) {

    final List<_HandlerQueueEntry> handlerQueue = new List<_HandlerQueueEntry>();
    final List<_HandleObject> delegates = handleObjCtx.delegates;
    final List<_HandleObject> handlers = handleObjCtx.handlers;

    // jQuery: Find delegate handlers
    //         Black-hole SVG <use> instance trees (#13180)
    //         Avoid non-left-click bubbling in Firefox (#3861)
    // src: if ( delegateCount && cur.nodeType && (!event.button || event.type !== "click") ) {
    if (delegates.isNotEmpty) {
      EventTarget cur = dqevent.target;
      if (cur is Node) {
        for (; cur != elem; cur = _fallback(parentNode(cur), () => elem)) {

          // jQuery: Don't process clicks on disabled elements (#6911, #8165, #11382, #11764)
          // TODO: uncomment later
          /*
          if (dqevent.type == "click" && h.isDisabled(cur))
            continue;
          */

          final Map<String, bool> matches = {};
          final List<_HandleObject> matched = new List<_HandleObject>();
          for (_HandleObject handleObj in delegates) {
            final String sel = "${_trim(handleObj.selector)} ";
            if (matches.putIfAbsent(sel, () => (cur is Element) &&
                (handleObj.needsContext ? $(sel, elem).contains(cur) :
                cur.matches(sel)))) {
              matched.add(handleObj);
            }
          }

          if (!matched.isEmpty) {
            handlerQueue.add(new _HandlerQueueEntry(cur, matched));
          }
        }
      }
    }

    // jQuery: Add the remaining (directly-bound) handlers
    if (!handlers.isEmpty) {
      handlerQueue.add(new _HandlerQueueEntry(elem, handlers));
    }

    return handlerQueue;
  }

  static EventTarget parentNode(EventTarget target) =>
      target is Node ? target.parentNode : null;

  static Map<String, _HandleObjectContext> _getEvents(EventTarget elem) =>
      _fallback(_dataPriv.get(elem, 'events'), () => {});

  static _HandleObjectContext _getHandleObjCtx(EventTarget elem, String type) =>
      _fallback(_getEvents(elem)[type], () => _HandleObjectContext.EMPTY);

  static void simulate(String type, EventTarget elem, event, bool bubble) {
    // jQuery: Piggyback on a donor event to simulate a different one.
    //         Fake originalEvent to avoid donor's stopPropagation, but if the
    //         simulated event prevents default then we do the same on the donor.

    QueryEvent e = new QueryEvent(type).._simulated = true;

    if (bubble)
      _EventUtil.triggerEvent(e.._target = elem);
    else
      _EventUtil.dispatch(elem, e, type: type);

    if (e.defaultPrevented)
      event.preventDefault();
  }
}

Element _activeElement() {
  try {
    return document.activeElement;
  } catch (_) {
  }
}

class _HandleObjectContext {

  final List<_HandleObject> delegates = new List<_HandleObject>();
  final List<_HandleObject> handlers = new List<_HandleObject>();

  static final _HandleObjectContext EMPTY = new _HandleObjectContext();

}

class _HandlerQueueEntry {

  final EventTarget elem;
  final List<_HandleObject> handlers;

  _HandlerQueueEntry(this.elem, this.handlers);

}

class _HandleObject {

  _HandleObject(this.selector, this.type, this.origType, this.namespace,
      this.needsContext, this.handler);

  final String selector, type, origType, namespace;
  final bool needsContext;
  final QueryEventListener handler;

}

typedef bool SetupSupplier<bool>(EventTarget eventTarget);
typedef bool TeardownSupplier<bool>(EventTarget eventTarget);

class _SpecialEventHandling {

  _SpecialEventHandling({bool noBubble: false, String delegateType,
    String bindType, bool trigger(EventTarget t, data),
    SetupSupplier setup, TeardownSupplier teardown,
    QueryEventListener handle}) :
  this.noBubble = noBubble,
  this.delegateType = delegateType,
  this.bindType = bindType,
  this.trigger = trigger,
  this.setup = setup,
  this.teardown = teardown,
  this.handle = handle;

  final bool noBubble;
  //Function setup, add, remove, teardown; // void f(Element elem, _HandleObject handleObj)

  final SetupSupplier setup;
  final TeardownSupplier teardown;

  final Function trigger; // bool f(Element elem, data)
  //Function _default; // bool f(Document document, data)
  final String delegateType, bindType;
  //QueryEventListener postDispatch, handle;

  QueryEventListener handle;

  static final _SpecialEventHandling EMPTY = new _SpecialEventHandling();

}
_SpecialEventHandling _getSpecial(String type) =>
  _fallback(_SPECIAL_HANDLINGS[type], () => _SpecialEventHandling.EMPTY);

final Map<String, _SpecialEventHandling> _SPECIAL_HANDLINGS = {
  // jQuery: Prevent triggered image.load events from bubbling to window.load
  'load': new _SpecialEventHandling(noBubble: true),

  'click': new _SpecialEventHandling(trigger: (EventTarget elem, data) {
    // jQuery: For checkbox, fire native event so checked state will be right
    if (elem is CheckboxInputElement) {
      elem.click();
      return false;
    }
    return true;
  }),

  'focus': new _SpecialEventHandling(trigger: (EventTarget elem, data) {
    // jQuery: Fire native event if possible so blur/focus sequence is correct
    if (elem != _activeElement() && elem is Element) {
      elem.focus();
      return false;
    }
    return true;
  }, delegateType: 'focusin'),

  'blur': new _SpecialEventHandling(trigger: (EventTarget elem, data) {
    if (elem == _activeElement()) {
      (elem as Element).blur();
      return false;
    }
    return true;
  }, delegateType: 'focusout'),

  'focusin': _fallback(_focusinHandling, () => _focusinHandling = _initNotSupportFocusinBubbles('focus', 'focusin')),
  'focusout': _fallback(_focusoutHandling, () => _focusoutHandling = _initNotSupportFocusinBubbles('blur', 'focusout')),

  'mouseenter': _fallback(_mouseenterHandling, () => _mouseenterHandling = _initMouseenterleave('mouseenter', 'mouseover')),
  'mouseleave': _fallback(_mouseleaveHandling, () => _mouseleaveHandling = _initMouseenterleave('mouseleave', 'mouseout')),
};

// jQuery: Create mouseenter/leave events using mouseover/out and event-time checks
_SpecialEventHandling _mouseenterHandling, _mouseleaveHandling;
_SpecialEventHandling _initMouseenterleave(String orig, String fix) {
  return new _SpecialEventHandling(handle: (QueryEvent event) {
    Node target = event._currentTarget as Node,
         related = event.relatedTarget as Node;
    _HandleObject handleObj = event._handleObj;

    // For mousenter/leave call the handler if related is outside the target.
    // NB: No relatedTarget if the mouse left/entered the browser window
    if (related == null || (related != target && !target.contains(related))) {
      event._type = handleObj.origType;
      handleObj.handler(event);
      event._type = fix;
    }
    return event.ret;
  }, delegateType: fix, bindType: fix);
}

// jQuery: Create "bubbling" focus and blur events
// Support: Firefox, Chrome, Safari
//if ( !jQuery.support.focusinBubbles ) {

_SpecialEventHandling _focusinHandling, _focusoutHandling;
_SpecialEventHandling _initNotSupportFocusinBubbles(String orig, String fix) {

  // Attach a single capturing handler while someone wants focusin/focusout
  var attaches = 0,
      handler = (event) =>
        _EventUtil.simulate(fix, event.target, new QueryEvent.from(event), true);

  return new _SpecialEventHandling(
    setup: (_) {
      if (attaches++ == 0)
        document.addEventListener(orig, handler, true);
     return true;
    },

    teardown: (_) {
      if (--attaches == 0)
        document.removeEventListener(orig, handler, true);
      return true;
    });
}

/** The handler type for [QueryEvent], which is the DQuery analogy of
 * [EventListener].
 */
typedef void QueryEventListener(QueryEvent event);

/** A wrapping of browser [Event], to attach more information such as custom
 * event data and name space, etc.
 */
class QueryEvent implements Event {

  /** The original event, if any. If this [QueryEvent] was triggered by browser,
   * it will contain an original event; if triggered by API, this property will
   * be null.
   */
  final Event originalEvent;

  /** The type of event. If the event is constructed from a native DOM [Event],
   * it uses the type of that event.
   */
  @override
  String get type => _type ?? originalEvent?.type;
  String _type;

  /** Custom event data. If user calls trigger method with data, it will show
   * up here.
   */
  var data;

  /** The last value returned by an event handler that was triggered by this event, unless the value was null.
   *
   */
  var result;

  /**
   * The return value of QueryEventListener
   */
  var ret;

  /** The delegate target of this event. i.e. The event target on which the
   * handler is registered.
   */
  EventTarget get delegateTarget => _delegateTarget;
  EventTarget _delegateTarget;

  /** The current target of this event when bubbling up.
   */
  EventTarget get currentTarget => _currentTarget;
  EventTarget _currentTarget;

  /** The original target of this event. i.e. The real event target where the
   * event occurs.
   */
  @override
  EventTarget get target {
    if (_target == null && originalEvent != null) {
      _target = originalEvent.target;

    // jQuery: Support: Chrome 23+, Safari?
    //         Target should not be a text node (#504, #13143)
      if (_target is Text)
        _target = (_target as Text).parentNode;
    }
    return _target;
  }
  EventTarget _target;

  /** The other DOM element involved in the event, if any.
   */
  EventTarget get relatedTarget => _safeOriginal((e) => e.relatedTarget);

  /** The namespace of this event. For example, if the event is triggered by
   * API with name `click.a.b.c`, it will have type `click` with namespace `a.b.c`
   */
  String get namespace => _namespace;
  String _namespace; // TODO: maybe should be List<String> ?

  /** The mouse position relative to the left edge of the document.
   */
  int get pageX {
    _initPageXY();
    return _pageX;
  }
  int _pageX;

  /** The mouse position relative to the top edge of the document.
   */
  int get pageY {
    _initPageXY();
    return _pageY;
  }
  int _pageY;

  void _initPageXY() {
    if (_pageX != null || originalEvent is! MouseEvent)
      return;

    // jQuery: Calculate pageX/Y if missing and clientX/Y available
    final MouseEvent original = originalEvent;
    final Point client = original.client;
    if (client.x != null ) {
      final Document eventDoc = target is Element ? (target as Element).ownerDocument:
        target is Document ? target as Document: document;
      final Element doc = eventDoc.documentElement,
              body = document.body;

      _pageX = client.x + _left(doc, body);
      _pageY = client.y + _top(doc, body);
    }
  }

  static int _left(Element doc, Element body)
  => doc != null ? doc.scrollLeft - doc.clientLeft:
     body != null ? body.scrollLeft - body.clientLeft: 0;

  static int _top(Element doc, Element body)
  => doc != null ? doc.scrollTop - doc.clientTop:
     body != null ? body.scrollTop - body.clientTop: 0;

  /** For key or mouse events, this property indicates the specific key
   * or button that was pressed.
   * 
   * For key events, it normalizes event.keyCode and event.charCode.
   * It is recommended to watch event.which for keyboard key input.
   *
   * For mouse events, it normalizes button presses (mousedown and mouseupevents),
   * reporting 1 for left button, 2 for middle, and 3 for right.
   * Use event.which instead of event.button.
   */
  @deprecated
  int get which {
    if (_which == null) {
      final event = originalEvent;
      if (event is KeyboardEvent) { //including KeyEvent
    //jQuery: Add which for key events
        _which = event.charCode ?? event.keyCode;

      } else if (event is MouseEvent) {
    // jQuery: Add which for click: 1 === left; 2 === middle; 3 === right
    // jQuery: Note: button is not normalized, so don't use it
        final buttons = event.buttons;
        _which = 
            buttons == null ? event.button + 1: //Safari: no buttons
            (buttons & 1) != 0 ? 1:
            (buttons & 2) != 0 ? 3: (buttons & 4) != 0 ? 2 : 0;
      } else if (event is QueryEvent) {
        _which = event.which;
      }
    }
    return _which;
  }
  int _which;

  ///Returns the key code if it is a keyboard event, or null if not.
  int get keyCode => _safeOriginal((e) => e.keyCode);
  ///Returns the key location if it is a keyboard event, or null if not.
  int get location => _safeOriginal((e) => e.location);
  @deprecated
  int get keyLocation => location;
  ///Returns the character code if it is a keyboard event, or null if not.
  int get charCode => _safeOriginal((e) => e.charCode);

  ///Returns whether the alt key is pressed.
  bool get altKey => _safeOriginal((e) => e.altKey, false);
  ///Returns whether the alt-graph key is pressed.
  bool get altGraphKey => _safeOriginal((e) => e.altGraphKey, false);
  ///Returns whether the ctrl key is pressed.
  bool get ctrlKey => _safeOriginal((e) => e.ctrlKey, false);
  ///Returns whether the meta key is pressed.
  bool get metaKey => _safeOriginal((e) => e.metaKey, false);

  ///Returns the button being clicked if it is a mouse event,
  ///or null if not.
  int get button => _safeOriginal((e) => e.button);

  @override
  bool get bubbles => _safeOriginal((e) => e.bubbles, false);
  @override
  bool get cancelable => _safeOriginal((e) => e.cancelable, false);
  @override
  int get eventPhase => _safeOriginal((e) => e.eventPhase, 0);
  @override
  Element get matchingTarget {
    if (originalEvent != null) return originalEvent.matchingTarget;
    throw new UnsupportedError(''); //follow SDK spec
  }
  @override
  List<Node> get path => _safeOriginal((e) => e.path);
  @override
  int get timeStamp => _safeOriginal((e) => e.timeStamp, 0);

  _safeOriginal(f(event), [defaultValue]) {
    if (originalEvent != null)
      try {
        return f(originalEvent);
      } catch (_) {
      }
    return defaultValue;
  }

  RegExp _reNamespace;

  _HandleObject _handleObj;

  //int _isTrigger; // TODO: check usage

  //final Map attributes = {};

  /** Construct a QueryEvent from a native DOM [event].
   */
  QueryEvent.from(Event this.originalEvent, {String type}) :
  _type = type;

  /** Construct a QueryEvent with given [type].
   */
  QueryEvent(String type, {EventTarget target, this.data}) :
  _type = type, _target = target, originalEvent = null;

  /// Return true if [preventDefault] was ever called in this event.
  @override
  bool get defaultPrevented
  => _defaultPrevented ?? _safeOriginal((e) => e.defaultPrevented, false);
  bool _defaultPrevented;

  /// Return true if [stopPropagation] was ever called in this event.
  bool get propagationStopped => _propagationStopped;
  bool _propagationStopped = false;

  /// Return true if [stopImmediatePropagation] was ever called in this event.
  bool get immediatePropagationStopped => _immediatePropagationStopped;
  bool _immediatePropagationStopped = false;

/// Return true if the event is simulated
  bool get simulated => _simulated;
  bool _simulated = false;

  /** Prevent the default action of the event being triggered.
   */
  @override
  void preventDefault() {
    _defaultPrevented = true;
    originalEvent?.preventDefault();
  }

  /** Prevent the event from bubbling up, and prevent any handlers on parent
   * elements from being called.
   */
  @override
  void stopPropagation() {
    _propagationStopped = true;
    originalEvent?.stopPropagation();
  }

  /** Prevent the event from bubbling up, and prevent any succeeding handlers
   * from being called.
   */
  @override
  void stopImmediatePropagation() {
    _immediatePropagationStopped = _propagationStopped = true;
    originalEvent?.stopImmediatePropagation();
  }
}
