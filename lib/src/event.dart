part of dquery;

// things to fix:
// 1. perform default action
// 2. namespace, multiple types
// 4. replace guid with Expando
// 5. off()

// static helper class
class _EventUtil {

  //static Set<String> _global = HashSet<String>();

  static void add(EventTarget eventTarget, String types,
      QueryEventListener handler, String? selector) {

    final hasSelector = selector != null && !selector.isEmpty;

    // jQuery: Don't attach events to noData or text/comment nodes (but allow plain objects)
    if (eventTarget.isA<CharacterData>())
      return;

    final space = _dataPriv.getSpace(eventTarget);
    // if (elemData == null) return;

    // jQuery: Init the element's event structure and main handler, if this is the first
    final events =
        space.putIfAbsent('events', Map<String, _HandleObjectContext>.new) as Map;
    // the joint proxy handler
    final eventHandles =
        space.putIfAbsent('handles', Map<String, JSFunction>.new) as Map;

    // jQuery: Handle multiple events separated by a space
    for (var type in _splitTypes(types)) {

      // calculate namespaces
      var namespaces = <String>[];
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
      var special = _getSpecial(type);
      // jQuery: If selector defined, determine special event api type, otherwise given type
      type = (hasSelector ? special.delegateType : special.bindType) ?? type;
      // jQuery: Update special based on newly reset type
      special = _getSpecial(type);

      // jQuery: handleObj is passed to all event handlers
      final needsContext = hasSelector && _EventUtil._needContext.hasMatch(selector);
      _HandleObject handleObj = _HandleObject(selector, type, origType,
          namespaces.join('.'), needsContext, handler);

    final eventHandle = eventHandles.putIfAbsent(type, 
      () => (Event e) {
        // jQuery: Discard the second event of a jQuery.event.trigger() and
        //         when an event is called after a page has unloaded
        if (_EventUtil._triggered != type)
          dispatch(eventTarget, QueryEvent.from(e), type: type);
      }.toJS);

      // jQuery: Init the event handler queue if we're the first
      _HandleObjectContext handleObjCtx = events.putIfAbsent(type, () {
        // jQuery: Only use addEventListener/attachEvent if the special events handler returns false
        if (special.setup == null || !special.setup!(eventTarget))
          eventTarget.addEventListener(type, eventHandle, false.toJS);
        return _HandleObjectContext();
      });

      // special add: skipped for now
      (hasSelector ? handleObjCtx.delegates : handleObjCtx.handlers).add(handleObj);

      // jQuery: Keep track of which events have ever been used, for event optimization
      //_global.add(type); // TODO: check use

    }
  }

  // jQuery: Detach an event or set of events from an element
  static void remove(EventTarget elem, String types, QueryEventListener? handler,
       String? selector, [bool mappedTypes = false]) {

    final events = _dataPriv.get(elem, 'events');
    if (events == null)
      return;

    // jQuery: Once for each type.namespace in types; type may be omitted
    for (var type in _splitTypes(types)) {

      // caculate namespaces
      var namespaces = <String>[];
      if (type.indexOf('.') >= 0) {
        namespaces = type.split('.');
        type = namespaces.removeAt(0);
        namespaces.sort();
      }
      final origType = type;

      // jQuery: Unbind all events (on this namespace, if provided) for the element
      if (type.isEmpty) {
        final ns = namespaces.join('.');
        for (final t in events.keys.toList())
          remove(elem, "$t.$ns", handler, selector, true);
        continue;
      }

      final special = _getSpecial(type);
      type = (selector != null ? special.delegateType : special.bindType) ?? type;

      final handleObjCtx = events[type] ?? _HandleObjectContext.EMPTY,
        delegates = handleObjCtx.delegates,
        handlers = handleObjCtx.handlers;

      // jQuery: Remove matching events
      final filter = (_HandleObject handleObj) {
        bool matchNamespaces() {
          for (final ns in handleObj.namespace!.split('.')) {
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
        if (special.teardown == null || !special.teardown!(elem)) {
          final eventHandles = _dataPriv.get(elem, 'handles');
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
      _dataPriv.remove(elem as Node, 'handles');

       // jQuery: removeData also checks for emptiness and clears the expando if empty
       //         so use it instead of delete
      _dataPriv.remove(elem, 'events');
    }

  }

  static final _needContext = RegExp(r'^[\x20\t\r\n\f]*[>+~]');

  static bool _subsetOf(List<String> a, List<String> b) {
    // assume a and b are sorted
    final ia = a.iterator;
    for (final sb in b) {
      if (!ia.moveNext())
        return true;
      final c = ia.current.compareTo(sb);
      if (c < 0)
        return false;
      if (c == 0)
        ia.moveNext();
    }
    return true;
  }

  static final _SPACES = RegExp(r'\s+');

  static List<String> _splitTypes(String? types) {
    return types == null ? [] : types.split(_SPACES);
  }

  static bool _focusMorphMatch(String? type1, String? type2) =>
      (type1 == 'focusin' && type2 == 'focus') || (type1 == 'focusout' && type2 == 'blur');

  static String? _triggered;

  static void trigger(String type, data, EventTarget? elem, [bool onlyHandlers = false]) {
    _EventUtil.triggerEvent(QueryEvent(type, target: elem, data: data), onlyHandlers);
  }

  static void triggerEvent(QueryEvent event, [bool onlyHandlers = false]) {
    final elem = event.target ?? document;
    var type = event.type,
      namespaces = <String>[];

    if (type.indexOf('.') >= 0) {
      namespaces = type.split('.');
      type = namespaces.removeAt(0);
      namespaces.sort();
    }

    final ontype = type.indexOf(':') < 0 ? "on$type" : null, // TODO: check use
      eventPath = <EventTarget>[elem];

    // jQuery: Don't do events on text and comment nodes
    if (elem.isA<CharacterData>())
      return;

    // jQuery: focus/blur morphs to focusin/out; ensure we're not firing them right now
    if (_focusMorphMatch(type, _EventUtil._triggered))
      return;

    // jQuery: Trigger bitmask: & 1 for native handlers; & 2 for jQuery (always true)
    //event._isTrigger = onlyHandlers ? 2 : 3;
    if (!namespaces.isEmpty)
      event._namespace = namespaces.join('.');
    event._reNamespace = event.namespace != null ?
        RegExp( '(^|\\.)${namespaces.join("\\.(?:.*\\.|)")}(\\.|\$)') : null;

    // jQuery: Determine event propagation path in advance, per W3C events spec (#9951)
    //         Bubble up to document, then to window; watch for a global ownerDocument var (#9724)
    String? bubbleType;
    final special = _getSpecial(type);
    if (!onlyHandlers && !special.noBubble && elem is Node) {
      final n = elem;
      bubbleType = special.delegateType ?? type;
      final focusMorph = _focusMorphMatch(bubbleType, type);

      for (var cur = focusMorph ? n : n.parentNode; cur != null; cur = cur.parentNode) {
        eventPath.add(cur);
      }

      // jQuery: Only add window if we got to document (e.g., not plain obj or detached DOM)
      // TODO
      /*
      if (tmp == (elem.ownerDocument ?? document))
        eventPathWindow = (tmp as Document).window ?? window;
      */
    }

    // jQuery: Fire handlers on the event path
    var first = true;
    for (final n in eventPath) {
      if (event.propagationStopped)
        break;
      event._type = !first ? bubbleType : (special.bindType ?? type);

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

  static void dispatch(EventTarget? elem, QueryEvent dqevent, {String? type}) {
    if (type == null) type = dqevent.type;
    final handleObjCtx = _getHandleObjCtx(elem, type);

    dqevent._delegateTarget = elem;

    // jQuery: Determine handlers
    final handlerQueue = _EventUtil.handlers(elem, dqevent, handleObjCtx);

    for (final matched in handlerQueue) {
      if (dqevent.propagationStopped) break;
      dqevent._currentTarget = matched.elem;
      // copy to avoid concurrent modification
      for (final handleObj in [...matched.handlers]) {
        if (dqevent.immediatePropagationStopped) break;
        // jQuery: Triggered event must either 1) have no namespace, or
        //         2) have namespace(s) a subset or equal to those in the bound event (both can have no namespace).
        if (dqevent._reNamespace?.hasMatch(handleObj.namespace!) ?? true) {
          final eventns = dqevent.namespace?.split('.') ?? <String>[],
            hobjns = handleObj.namespace?.split('.') ?? <String>[];
          if (_subsetOf(eventns, hobjns)) {
            dqevent._handleObj = handleObj;

            final special = _getSpecial(handleObj.origType),
              fn = special.handle ?? handleObj.handler;

            fn(dqevent);

            final ret = dqevent.ret;
            if (ret != null ) {
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

  static List<_HandlerQueueEntry> handlers(EventTarget? elem, QueryEvent dqevent,
      _HandleObjectContext handleObjCtx) {

    final handlerQueue = <_HandlerQueueEntry>[],
      delegates = handleObjCtx.delegates,
      handlers = handleObjCtx.handlers;

    // jQuery: Find delegate handlers
    //         Black-hole SVG <use> instance trees (#13180)
    //         Avoid non-left-click bubbling in Firefox (#3861)
    // src: if ( delegateCount && cur.nodeType && (!event.button || event.type !== "click") ) {
    if (delegates.isNotEmpty) {
      var cur = dqevent.target;
      if (cur is Node) {
        for (; cur != elem; cur = parentNode(cur) ?? elem) {

          // jQuery: Don't process clicks on disabled elements (#6911, #8165, #11382, #11764)
          // TODO: uncomment later
          /*
          if (dqevent.type == "click" && h.isDisabled(cur))
            continue;
          */

          final matches = <String, bool>{},
            matched = <_HandleObject>[];

          for (final handleObj in delegates) {
            final sel = "${_trim(handleObj.selector)} ";
            if (matches.putIfAbsent(sel, () => (cur is Element) &&
                (handleObj.needsContext ? $(sel, elem).contains(cur) :
                cur.matches(sel)))) {
              matched.add(handleObj);
            }
          }

          if (!matched.isEmpty) {
            handlerQueue.add(_HandlerQueueEntry(cur as Node, matched));
          }
        }
      }
    }

    // jQuery: Add the remaining (directly-bound) handlers
    if (handlers.isNotEmpty)
      handlerQueue.add(_HandlerQueueEntry(elem, handlers));

    return handlerQueue;
  }

  static EventTarget? parentNode(EventTarget? target) =>
      target is Node ? target.parentNode : null;

  static Map _getEvents(EventTarget? elem) =>
      _dataPriv.get(elem, 'events') ?? {};

  static _HandleObjectContext _getHandleObjCtx(EventTarget? elem, String type) =>
      _getEvents(elem)[type] ?? _HandleObjectContext.EMPTY;

  static void simulate(String type, EventTarget? elem, event, bool bubble) {
    // jQuery: Piggyback on a donor event to simulate a different one.
    //         Fake originalEvent to avoid donor's stopPropagation, but if the
    //         simulated event prevents default then we do the same on the donor.

    QueryEvent e = QueryEvent(type).._simulated = true;

    if (bubble)
      _EventUtil.triggerEvent(e.._target = elem);
    else
      _EventUtil.dispatch(elem, e, type: type);

    if (e.defaultPrevented)
      event.preventDefault();
  }
}

Element? _activeElement() {
  try {
    return document.activeElement;
  } catch (_) {
    return null;
  }
}

class _HandleObjectContext {

  final delegates = <_HandleObject>[];
  final handlers = <_HandleObject>[];

  static final EMPTY = _HandleObjectContext();

}

class _HandlerQueueEntry {

  final EventTarget? elem;
  final List<_HandleObject> handlers;

  _HandlerQueueEntry(this.elem, this.handlers);

}

class _HandleObject {

  _HandleObject(this.selector, this.type, this.origType, this.namespace,
      this.needsContext, this.handler);

  final String? selector, origType, namespace;
  final String type;
  final bool needsContext;
  final QueryEventListener handler;

}

typedef bool SetupSupplier(EventTarget? eventTarget);
typedef bool TeardownSupplier(EventTarget? eventTarget);

class _SpecialEventHandler {

  _SpecialEventHandler({bool noBubble = false, String? delegateType,
    String? bindType, bool trigger(EventTarget t, data)?,
    SetupSupplier? setup, TeardownSupplier? teardown,
    QueryEventListener? handle}) :
  this.noBubble = noBubble,
  this.delegateType = delegateType,
  this.bindType = bindType,
  this.trigger = trigger,
  this.setup = setup,
  this.teardown = teardown,
  this.handle = handle;

  final bool noBubble;
  //Function setup, add, remove, teardown; // void f(Element elem, _HandleObject handleObj)

  final SetupSupplier? setup;
  final TeardownSupplier? teardown;

  final Function? trigger; // bool f(Element elem, data)
  //Function _default; // bool f(Document document, data)
  final String? delegateType, bindType;
  //QueryEventListener postDispatch, handle;

  QueryEventListener? handle;

  static final EMPTY = _SpecialEventHandler();

}
_SpecialEventHandler _getSpecial(String? type) =>
  _SPECIAL_HANDLINGS[type] ?? _SpecialEventHandler.EMPTY;

final Map<String, _SpecialEventHandler> _SPECIAL_HANDLINGS = <String, _SpecialEventHandler> {
  // jQuery: Prevent triggered image.load events from bubbling to window.load
  'load': _SpecialEventHandler(noBubble: true),

  'click': _SpecialEventHandler(trigger: (EventTarget elem, data) {
    // jQuery: For checkbox, fire native event so checked state will be right
    if (elem.isA<HTMLInputElement>()) {
      (elem as HTMLInputElement).click();
      return false;
    }
    return true;
  }),

  'focus': _SpecialEventHandler(trigger: (EventTarget elem, data) {
    // jQuery: Fire native event if possible so blur/focus sequence is correct
    if (elem != _activeElement() && elem is HTMLElement) {
      elem.focus();
      return false;
    }
    return true;
  }, delegateType: 'focusin'),

  'blur': _SpecialEventHandler(trigger: (EventTarget elem, data) {
    if (elem == _activeElement()) {
      (elem as HTMLElement).blur();
      return false;
    }
    return true;
  }, delegateType: 'focusout'),

  'focusin': _focusinHandling ?? (_focusinHandling = _initNotSupportFocusinBubbles('focus', 'focusin')),
  'focusout': _focusoutHandling ?? (_focusoutHandling = _initNotSupportFocusinBubbles('blur', 'focusout')),

  'mouseenter': _mouseenterHandling ?? (_mouseenterHandling = _initMouseenterleave('mouseenter', 'mouseover')),
  'mouseleave': _mouseleaveHandling ?? (_mouseleaveHandling = _initMouseenterleave('mouseleave', 'mouseout')),
};

// jQuery: Create mouseenter/leave events using mouseover/out and event-time checks
_SpecialEventHandler? _mouseenterHandling, _mouseleaveHandling;
_SpecialEventHandler _initMouseenterleave(String orig, String fix) {
  return _SpecialEventHandler(handle: (QueryEvent event) {
    final target = event._currentTarget as Node,
      related = event.relatedTarget as Node?,
      handleObj = event._handleObj;

    // For mousenter/leave call the handler if related is outside the target.
    // NB: No relatedTarget if the mouse left/entered the browser window
    if (related != target && !target.contains(related)) {
      event._type = handleObj!.origType;
      handleObj.handler(event);
      event._type = fix;
    }
    return event.ret;
  }, delegateType: fix, bindType: fix);
}

// jQuery: Create "bubbling" focus and blur events
// Support: Firefox, Chrome, Safari
//if ( !jQuery.support.focusinBubbles ) {

_SpecialEventHandler? _focusinHandling, _focusoutHandling;
_SpecialEventHandler _initNotSupportFocusinBubbles(String orig, String fix) {

  // Attach a single capturing handler while someone wants focusin/focusout
  var attaches = 0,
      handler = (Event event) =>
        _EventUtil.simulate(fix, event.target, QueryEvent.from(event), true);

  return _SpecialEventHandler(
    setup: (_) {
      if (attaches++ == 0)
        document.addEventListener(orig, handler.toJS, true.toJS);
     return true;
    },

    teardown: (_) {
      if (--attaches == 0)
        document.removeEventListener(orig, handler.toJS, true.toJS);
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
class QueryEvent {

  /** The original event, if any. If this [QueryEvent] was triggered by browser,
   * it will contain an original event; if triggered by API, this property will
   * be null.
   */
  final Event? originalEvent;

  /** The type of event. If the event is constructed from a native DOM [Event],
   * it uses the type of that event.
   */
  String get type => _type ?? originalEvent!.type;
  String? _type;

  List<EventTarget> composedPath() {
    return originalEvent?.composedPath().toDart ?? const <EventTarget>[];
  }

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
  EventTarget? get delegateTarget => _delegateTarget;
  EventTarget? _delegateTarget;

  /** The current target of this event when bubbling up.
   */
  EventTarget? get currentTarget => _currentTarget;
  EventTarget? _currentTarget;

  /** The original target of this event. i.e. The real event target where the
   * event occurs.
   */
  EventTarget? get target {
    if (_target == null && originalEvent != null) {
      _target = originalEvent!.target;

    // jQuery: Support: Chrome 23+, Safari?
    //         Target should not be a text node (#504, #13143)
      if (_target.isA<Text>())
        _target = (_target as Text).parentNode;
    }
    return _target;
  }
  EventTarget? _target;

  /** The other DOM element involved in the event, if any.
   */
  EventTarget? get relatedTarget => _safeOriginal('relatedTarget');

  /** The namespace of this event. For example, if the event is triggered by
   * API with name `click.a.b.c`, it will have type `click` with namespace `a.b.c`
   */
  String? get namespace => _namespace;
  String? _namespace; // TODO: maybe should be List<String> ?

  /** The mouse position relative to the left edge of the document.
   */
  int get pageX {
    _initPageXY();
    return _pageX!;
  }
  int? _pageX;

  /** The mouse position relative to the top edge of the document.
   */
  int get pageY {
    _initPageXY();
    return _pageY!;
  }
  int? _pageY;

  void _initPageXY() {
    if (_pageX != null || !originalEvent.isA<MouseEvent>())
      return;

    // jQuery: Calculate pageX/Y if missing and clientX/Y available
    final original = originalEvent as MouseEvent;
    final eventDoc = target.isA<Element>() ? (target as Element).ownerDocument:
      target.isA<Document>() ? target as Document: document;
    final doc = eventDoc?.documentElement,
      body = document.body;

    _pageX = original.clientX + _left(doc, body);
    _pageY = original.clientY + _top(doc, body);
  }

  static int _left(Element? doc, Element? body)
  => doc != null ? (doc.scrollLeft - doc.clientLeft).toInt():
     body != null ? (body.scrollLeft - body.clientLeft).toInt(): 0;

  static int _top(Element? doc, Element? body)
  => doc != null ? (doc.scrollTop - doc.clientTop).toInt():
     body != null ? (body.scrollTop - body.clientTop).toInt(): 0;

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
  int? get which {
    if (_which == null) {
      final event = originalEvent;
      if (event.isA<KeyboardEvent>() && event is KeyboardEvent) { //including KeyEvent
    //jQuery: Add which for key events
        _which = event.charCode;

      } else if (event.isA<MouseEvent>() && event is MouseEvent) {
    // jQuery: Add which for click: 1 === left; 2 === middle; 3 === right
    // jQuery: Note: button is not normalized, so don't use it
        final buttons = event.buttons;
        _which = 
            (buttons & 1) != 0 ? 1:
            (buttons & 2) != 0 ? 3: (buttons & 4) != 0 ? 2 : 0;
      } else if (event is QueryEvent) {
        _which = (event as QueryEvent).which;
      }
    }
    return _which;
  }
  int? _which;

  //Returns the key if it is a keyboard event, or null if not.
  String get key => _safeOriginal('key')!;
  //Returns the code if it is a keyboard event, or null if not.
  String get code => _safeOriginal('code')!;
  ///Returns the key code if it is a keyboard event, or null if not.
  int get keyCode => _safeOriginal('keyCode');
  ///Returns the key location if it is a keyboard event, or null if not.
  int get location => _safeOriginal('location');
  @deprecated
  int get keyLocation => location;
  ///Returns the character code if it is a keyboard event, or null if not.
  int get charCode => _safeOriginal('charCode');

  ///Returns whether the alt key is pressed.
  bool get altKey => _safeOriginal('altKey', false)!;
  ///Returns whether the alt-graph key is pressed.
  bool get altGraphKey => _safeOriginal('altGraphKey', false)!;
  ///Returns whether the ctrl key is pressed.
  bool get ctrlKey => _safeOriginal('ctrlKey', false)!;
  ///Returns whether the meta key is pressed.
  bool get metaKey => _safeOriginal('metaKey', false)!;
  ///Returns whether the shift key is pressed.
  bool get shiftKey => _safeOriginal('shiftKey', false)!;

  ///Returns the button being clicked if it is a mouse event,
  ///or null if not.
  int get button => _safeOriginal('button');

  bool get bubbles => _safeOriginal('bubbles', false)!;
  
  bool get cancelable => _safeOriginal('cancelable', false)!;
  
  bool get isTrusted => _safeOriginal('isTrusted', false)!;
  
  bool get composed => _safeOriginal('composed', false)!;
  
  int get eventPhase => _safeOriginal('eventPhase', 0)!;
  // Element get matchingTarget {
  //   if (originalEvent != null) return originalEvent!.matchingTarget;
  //   throw UnsupportedError('Cannot call matchingTarget if this Event did'
  //     ' not arise as a result of event delegation.'); //follow SDK spec
  // }
  
  List<Node> get path => _safeOriginal('path', [])!;
  
  double get timeStamp => _safeOriginal('timeStamp', 0.0)!;

  T? _safeOriginal<T>(String name, [T? defaultValue]) {
    if (originalEvent != null)
      try {
        return reflectGet(originalEvent, name.toJS)?.dartify() as T? ?? defaultValue;
      } catch (_) {
      }
    return defaultValue;
  }

  RegExp? _reNamespace;

  _HandleObject? _handleObj;

  //int _isTrigger; // TODO: check usage

  //final Map attributes = {};

  /** Construct a QueryEvent from a native DOM [event].
   */
  QueryEvent.from(this.originalEvent, {String? type}) :
  _type = type;

  /** Construct a QueryEvent with given [type].
   */
  QueryEvent(String type, {EventTarget? target, this.data}) :
  _type = type, _target = target, originalEvent = null;

  /// Return true if [preventDefault] was ever called in this event.
  bool get defaultPrevented
  => _defaultPrevented ?? _safeOriginal('defaultPrevented', false)!;
  bool? _defaultPrevented;

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
  void preventDefault() {
    _defaultPrevented = true;
    originalEvent?.preventDefault();
  }

  /** Prevent the event from bubbling up, and prevent any handlers on parent
   * elements from being called.
   */
  void stopPropagation() {
    _propagationStopped = true;
    originalEvent?.stopPropagation();
  }

  /** Prevent the event from bubbling up, and prevent any succeeding handlers
   * from being called.
   */
  void stopImmediatePropagation() {
    _immediatePropagationStopped = _propagationStopped = true;
    originalEvent?.stopImmediatePropagation();
  }
}

@JS('Reflect.get')
external JSAny? reflectGet(JSObject? object, JSString name);