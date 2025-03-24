library dquery;

import 'dart:math';
import 'package:web/web.dart';

import 'dart:collection';

import 'dart:js_interop';
import "package:intl/intl.dart" show DateFormat;

part 'src/util/util.dart';
part 'src/dquery_api.dart';
part 'src/dquery_impl.dart';
part 'src/selector.dart';
part 'src/traversing.dart';
part 'src/dimension.dart';
part 'src/offset.dart';
part 'src/manipulation.dart';
part 'src/css.dart';
part 'src/data.dart';
part 'src/event.dart';
part 'src/cookie.dart';

/** Return an [ElementQuery] based on given [selector] and [context].
 */
ElementQuery $(selector, [context]) {
  if (selector is String)
    selector = selector.trim();
  
  if (selector == null || selector == '')
    return ElementQuery([]);
  
  if (selector is String) {
    // html
    if (selector.startsWith('<')) {
      final cnt = HTMLDivElement();
      cnt.innerHTML = selector.toJS;
      return ElementQuery(JSImmutableListWrapper(cnt.childNodes));
    }
    
    if (context == null) {
      return _rootDQuery.find(selector);
      
    } else if (context is DQuery) {
      return context.find(selector);
      
    } else if (context is Document && context.isA<Document>()) {
      return $document(context).find(selector);
      
    } else if (context is HTMLElement && context.isA<HTMLElement>()) {
      return ElementQuery([context]).find(selector);
    }
    
    throw ArgumentError("Context type should be Document, Element, or DQuery: $context");
  }
  
  if (selector is HTMLElement)
    return ElementQuery([selector]);
  
  if (selector is List<HTMLElement>)
    return ElementQuery(selector);
  
  throw ArgumentError("Selector type should be String, Element, or List<Element>: $selector");  
}

/** Return a [DocumentQuery] wrapping the given [document]. If [document] is 
 * omitted, the default document instance is assumed.
 */
DocumentQuery $document([Document? document]) => _DocumentQuery(document);

/** Return a [WindowQuery] wrapping the given [window]. If [window] is omitted,
 * the default window instance is used.
 */
DQuery $window([Window? window]) => _WindowQuery(window);

/** Return a [WindowQuery] wrapping the given [window]. If [window] is omitted,
 * the default window instance is used.
 */
Query $shadowRoot(ShadowRoot shadowRoot) => _ShadowRootQuery(shadowRoot);
