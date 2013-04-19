part of dquery;

class _Storage {
  
  final String _name;
  final Expando<Map> _cache;
  
  _Storage(String name) :
  _name = name,
  _cache = new Expando<Map>(name);
  
  void set(owner, String key, value) {
    getSpace(owner)[key] = value;
  }
  
  void setAll(Node owner, Map<String, dynamic> props) {
    final Map space = getSpace(owner);
    props.forEach((String key, value) => space[key] = value);
  }
  
  get(owner, String key) {
    Map space = _cache[owner];
    return space == null ? null : space[key];
  }
  
  Map getSpace(owner, [bool autoCreate = true]) {
    Map space = _cache[owner];
    if (autoCreate && space == null)
      space = _cache[owner] = new HashMap();
    return space;
  }
  
  void remove(Node owner, {key, List keys}) {
    // TODO: check what jquery really does here
  }
  
  bool hasData(owner) {
    Map space = _cache[owner];
    return space != null && !space.isEmpty;
  }
  
  void discard(owner) {
    _cache[owner] = null;
  }
  
}

final _Storage _dataUser = new _Storage('dquery-data-user');
final _Storage _dataPriv = new _Storage('dquery-data-priv');



abstract class DataMixin {
  
  DQuery get _this;
  
  // TODO: should this just be a Map?
  Data get data => _fallback(_data, () => (_data = new Data._(_this)));
  Data _data;
  
}

class Data {
  
  final DQuery _dq;
  
  Data._(this._dq);
  
  EventTarget get _first => _dq._first;
  
  /**
   * 
   */
  Map space() => _first == null ? null : _dataUser.getSpace(_first);
  
  /**
   * 
   */
  get(String key) => _dq.isEmpty ? null : space()[key];
  
  /**
   * 
   */
  void set(String key, value) => 
      _dq._forEachEventTarget((EventTarget t) => _dataUser.set(t, key, value));
  
  /**
   * 
   */
  void setAll(Map<String, dynamic> props) => 
      _dq._forEachEventTarget((EventTarget t) => _dataUser.setAll(t, props));
  
  /**
   * 
   */
  void remove(String key) =>
      _dq._forEachEventTarget((EventTarget t) => _dataUser.remove(t, key: key));
  
}

/*
_dataAttr(Element elem, String key, data) {
  // TODO: it's a function that offers some fix to the key and data to leverege HTML 5 
  // data- attributes, should be important to plug-in environment
  
  return data;
}
*/
