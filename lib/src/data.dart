part of dquery;

class _Storage {
  
  final Expando<Map<String, dynamic>> _cache;
  
  _Storage(String name) :
  _cache = new Expando<Map<String, dynamic>>(name);
  
  void set(owner, String key, value) {
    getSpace(owner)[key] = value;
  }
  
  void setAll(Node owner, Map<String, dynamic> props) {
    final space = getSpace(owner);
    props.forEach((String key, value) => space[key] = value);
  }
  
  get(owner, String key) {
    final space = _cache[owner];
    return space == null ? null : space[key];
  }
  
  Map<String, dynamic> getSpace(owner, [bool autoCreate = true]) {
    var space = _cache[owner];
    if (autoCreate && space == null)
      space = _cache[owner] = <String, dynamic>{};
    return space;
  }
  
  void remove(Node owner, String key) {
    final space = _cache[owner];
    if (space != null) {
      space.remove(key);
      if (space.isEmpty)
        _cache[owner] = null;
    }
  }
  
  bool hasData(owner) {
    final space = _cache[owner];
    return space != null && !space.isEmpty;
  }
  
  void discard(owner) {
    _cache[owner] = null;
  }
  
}

final _Storage _dataUser = new _Storage('dquery-data-user');
final _Storage _dataPriv = new _Storage('dquery-data-priv');

/** The interface for accessing element data.
 */
class Data {
  
  final _Query _dq;
  
  Data._(this._dq);
  
  /** Retrieve the entire space of element data.
   */
  Map<String, dynamic> get space => _dq.isEmpty ? null : _dataUser.getSpace(_dq.first);
  
  /** Retrieve the data of the given [key].
   */
  get(String key) => _dq.isEmpty ? null : space[key];
  
  /** Set the data of the given [key].
   */
  void set(String key, value) => 
      _dq.forEach((t) => _dataUser.set(t, key, value));
  
  /** Delete the data of the given [key].
   */
  void remove(String key) =>
      _dq.forEach((t) => _dataUser.remove(t, key));
  
}

/*
_dataAttr(Element elem, String key, data) {
  // TODO: it's a function that offers some fix to the key and data to leverege HTML 5 
  // data- attributes, should be important to plug-in environment
  
  return data;
}
*/
