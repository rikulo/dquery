# CHANGES

**1.0.0**
* Dart 2 required

**0.8.6**
* Fixed QueryEvent missing overrides

**0.8.5**

* QueryEvent.shiftKey introduced.

**0.8.4**

* Deprecate QueryEvent.type since Dart 1.16 doesn't support MouseEvent.which, and it is not non-standard.
* Deprecate keyLocation. Use location instead.

**0.8.3**

* Remove QueryEvent's isDefaultPrevented and isPropagationStopped. Please use defaultPrevented and propagationStopped instead.

**0.8.2**

* Remove QueryEvent's which and clipboardData to be compatible with Dart 1.16

**0.8.1**

* Close #11: QueryEvent implements Event
# Fixed client error when access pageX (Firefox)

**0.8.0

* Refector: DQuery doesn't depend on Event.target/type for basic event handling

**0.7.1**

* Focus/blur event bubbling ready.
* Fix mouseenter/mouseleave delegate event.
* Fix delegate target not found error.
* Removed deprecated event API.
* Fine tune QueryEvent constructor.

**0.7.0**

* #6: DocumentQuery supported cookie API.
* #2: QueryEvent supported keystroke API.

**0.6.1**

* Fix event memory issue.

**0.6.0**

* Query was added for query any object including shadow roots.
* DocumentQuery and WindowQuery were removed, and replaced with DQuery.
* DQueryEvent was renamed to QueryEvent.
* Data.space() became a getter: Date.space

**0.5.4**

* Fix event name space.
* Fix data remove.
* Fine tune JavaScript compatibility.

**0.5.2**

* Add getter/setter of offset, getter of offsetLeft, offsetTop
* Add getter of offsetParent
* Add getter/setter of html, text
* Add .clone()
* Add .append(), .prepend(), .after(), .before()
* Add .appendTo(), .prependTo()
* Minor bug fixes

**0.5.1**

* Add $(html) support.
* Add getter, setter of scrollLeft, scrollTop
* Add .css()
* Add getter of width, height
