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
DQuery $(selector, [context]) {
  
  if (selector == null || selector is String)
    return new DQuery(selector, context);
  
  if (selector is Element)
    return new DQuery.elem(selector as Element);
  
  if (selector is List<Element>)
    return new DQuery.elems(selector as List<Element>);
  
  if (selector is Document)
    return new DQuery.doc(selector as Document);
  
  throw new ArgumentError("Unsupported DQuery argument: $selector, $context");  
}

/**
 * 
 */
class DQuery extends DQueryBase with TraversingMixin, DataMixin, EventMixin {
  
  /** 
   * 
   */
  factory DQuery([String selector, context]) {
    return DQueryBase._query(selector, context);
  }
  
  // TODO: when 9339 is fixed, call super(selector, context) directly
  //       Blocked by http://www.dartbug.com/9339
  /** 
   * 
   */
  DQuery.doc(Document doc) {
    super._doc(doc);
  }
  
  /** 
   * 
   */
  DQuery.elem(Element element) {
    super._elem(element);
  }
  
  /** 
   * 
   */
  DQuery.elems(List<Element> elements) {
    super._elems(elements, true);
  }
  
}
