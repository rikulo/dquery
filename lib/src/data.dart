part of dquery;

class _Storage {
  
  static int uid = 1;
  
  final Map<String, Map> _cache = new HashMap<String, Map>();
  final String dataExpando;
  
  _Storage() : dataExpando = "dquery-data-expando-${_randInt()}";
  Map<Document, String> _docUnlock = new HashMap<Document, String>();
  
  // TODO: shall it be created on demand? keep this way for now to avoid side effect
  String _key(Node owner) {
    String unlock = null;
    if (owner is Element)
      unlock = (owner as Element).attributes.putIfAbsent(dataExpando, () => "${uid++}");
    else if (owner is Document)
      unlock = _docUnlock.putIfAbsent(owner as Document, () => "${uid++}");
    else
      throw new ArgumentError("Data owner must be Element of Document: $owner");
    _cache.putIfAbsent(unlock, () => new HashMap());
    return unlock;
  }
  
  void set(Node owner, String key, value) {
    // does not accept (owner, props) format!
    _cache[_key(owner)][key] = value;
  }
  
  void setAll(Node owner, Map<String, dynamic> props) {
    final Map space = _cache[_key(owner)];
    props.forEach((String key, value) => space[key] = value);
  }
  
  get(Node owner, String key) => _cache[_key(owner)][key];
  
  Map getSpace(Node owner) => _cache[_key(owner)];
  
  // do not provide access(owner, key, value) to keep type strong!
  
  void remove(Node owner, {key, List keys}) {
    // TODO: check what jquery really does here
  }
  
  bool hasData(Node owner) => !_cache[_key(owner)].isEmpty;
  
  void discard(Node owner) {
    _cache.remove(_key(owner));
  }
  
}

final _Storage _dataUser = new _Storage();
final _Storage _dataPriv = new _Storage();



abstract class DataMixin {
  
  DQuery get _this;
  
  // TODO: should this just be a Map?
  Data get data => _fallback(_data, () => (_data = new Data._(_this)));
  Data _data;
  
  removeData(String key) {
    _this._forEachNode((Node n) => _dataUser.remove(n, key: key));
  }
  
}

class Data {
  
  final DQuery _dq;
  
  Data._(this._dq);
  
  Node get _first => _dq.isEmpty ? null : _dq.first;
  
  Map space() => _first == null ? null : _dataUser.getSpace(_first);
  
  get(String key) => _dq.isEmpty ? null : space()[key];
  
  void set(String key, value) {
    _dq.forEach((Node n) => _dataUser.set(n, key, value));
  }
  
  void setAll(Map<String, dynamic> props) {
    _dq.forEach((Node n) => _dataUser.setAll(n, props));
  }
  
}

/*
bool hasData(Element elem) => _dataUser.hasData(elem) || _dataPriv.hasData(elem);

getData(Element elem, String name) => _dataUser.get(elem, name);

getDataSpace(Element elem) => _dataUser.getSpace(elem);

setData(Element elem, String name, value) => _dataUser.set(elem, name, value);

removeData(Element elem, String name) => _dataUser.remove(elem, key: name);
*/

_dataAttr(Element elem, String key, data) {
  
  // TODO: it's a function that offers some fix to the key and data to leverege HTML 5 
  // data- attributes, should be important to plug-in environment
  
  return data;
  
}

