library dquery;

import 'dart:math';
import 'dart:html';
import 'dart:async';
import 'dart:collection';
import 'package:meta/meta.dart';

part 'src/util/util.dart';
part 'src/dquery_api.dart';
part 'src/dquery_impl.dart';
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
DocumentQuery $document([Document document]) => new DocumentQuery(document);

/**
 * 
 */
WindowQuery $window([Window window]) => new WindowQuery(window);

