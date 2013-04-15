part of dquery;

class _Storage {
  
  static int uid = 1;
  
  final Map<String, Map> _cache = new HashMap<String, Map>();
  final String dataExpando;
  
  _Storage() : dataExpando = "data-expando-${u.randInt()}";
  
  // TODO: shall it be created on demand? keep this way for now to avoid side effect
  String _key(Element owner) {
    final String unlock = owner.attributes.putIfAbsent(dataExpando, () => "${uid++}");
    _cache.putIfAbsent(unlock, () => new HashMap());
    return unlock;
  }
  
  void set(Element owner, String key, value) {
    // does not accept (owner, props) format!
    _cache[_key(owner)][key] = value;
  }
  
  void setAll(Element owner, Map<String, dynamic> props) {
    final Map space = _cache[_key(owner)];
    props.forEach((String key, value) => space[key] = value);
  }
  
  get(Element owner, String key) => _cache[_key(owner)][key];
  
  Map getSpace(Element owner) => _cache[_key(owner)];
  
  // do not provide access(owner, key, value) to keep type strong!
  
  void remove(Element owner, {key, List keys}) {
    // TODO: check what jquery really does here
  }
  
  bool hasData(Element owner) => !_cache[_key(owner)].isEmpty;
  
  void discard(Element owner) {
    _cache.remove(_key(owner));
  }
  
}

class _JointStorage implements _Storage {
  
  final Map<String, Map> _cache = null;
  final _Storage _user, _priv;
  
  _JointStorage(this._user, this._priv);
  
  get(Element owner, String key) =>
      //new u.Ref(_user.get(owner, key))
      //.fallback(() => _priv.get(owner, key)).value;
      u.fallback(_user.get(owner, key), () => _priv.get(owner, key));
  
  bool hasData(Element owner) => 
      _user.hasData(owner) || _priv.hasData(owner);
  
  void discard(Element owner) {
    _user.discard(owner);
    _priv.discard(owner);
  }
  
  // unsupported //
  String get dataExpando { u.unsupported(); }
  String _key(Element owner) { u.unsupported(); }
  Map getSpace(Element owner) { u.unsupported(); }
  void set(Element owner, String key, value) { u.unsupported(); }
  void setAll(Element owner, Map<String, dynamic> props) { u.unsupported(); }
  void remove(Element owner, {key, List keys}) { u.unsupported(); }
  
}

final _Storage _dataUser = new _Storage();
final _Storage _dataPriv = new _Storage();
final _Storage _dataJoint = new _JointStorage(_dataUser, _dataPriv);



abstract class DataMixin {
  
  DQuery get _this;
  
  data([String key, value]) {
    
  }
  
  /*
  Map getDataSpace() {
    
  }
  */
  
  removeData(String key) {
    _this.forEach((Element elem) => _dataUser.remove(elem, key: key));
  }
  
}

// SKIPPED: deprecated in jQuery
// src: acceptData()

bool hasData(Element elem) => _dataJoint.hasData(elem);

getData(Element elem, String name) => _dataUser.get(elem, name);

getDataSpace(Element elem) => _dataUser.getSpace(elem);

setData(Element elem, String name, value) => _dataUser.set(elem, name, value);

removeData(Element elem, String name) => _dataUser.remove(elem, key: name);

_dataAttr(Element elem, String key, data) {
  
  // TODO: it's a function that offers some fix to the key and data to leverege HTML 5 
  // data- attributes, should be important to plug-in environment
  
  return data;
  
}

