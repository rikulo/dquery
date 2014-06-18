//Copyright (C) 2014 Potix Corporation. All Rights Reserved.
//History: Wed, Jun 18, 2014 12:07:42 PM
// Author: tomyeh
part of dquery;

//--The code is ported from Carhartl's jquery-cookie--//

String _encode(String s) => Uri.encodeComponent(s);
String _decode(String s) => Uri.decodeComponent(s);

_getCookie(Document doc, [String key]) {
  final Map<String, String> cookies = key != null ? null: {};
  String value = doc.cookie;
  if (value != null) {
    for (final String cookie in value.split('; ')) {
      final int i = cookie.indexOf('=');
      if (i < 0) continue; //just in case

      final String name = _decode(cookie.substring(0, i));
      value = _parseCookieValue(cookie.substring(i + 1));

      if (key == null) {
        if (value != null)
          cookies[name] = value;
      } else if (key == name) {
        return value;
      }
    }
  }
  return cookies;
}

String _parseCookieValue(String value) {
  if (value.startsWith('"')) {
    // This is a quoted cookie as according to RFC2068, unescape...
    value = value.substring(1, value.length - 1)
      .replaceAll(_reQuot, '"').replaceAll(_reBS, r'\');
  }

  try {
    // Replace server-side written pluses with spaces.
    return _decode(value.replaceAll(_rePlus, ' '));
  } catch(e) {
  }
}
final RegExp _reQuot = new RegExp(r'\\"'), _reBS = new RegExp(r'\\\\'),
  _rePlus = new RegExp(r'\+');


void _setCookie(Document doc, String name, String value, Duration expires,
    String path, bool secure) {
  final List<String> buf = [_encode(name), '=', _encode(value)];

  if (expires != null)
    buf..add("; expires=")
      ..add(_utcfmt.format(new DateTime.now().add(expires).toUtc()))
      ..add(" GMT");
  if (path != null)
    buf..add("; path=")..add(path);
  if (secure == true)
    buf.add("; secure");

  document.cookie = buf.join("");
}
final DateFormat _utcfmt = new DateFormat("E dd MMM yyyy kk:mm:ss", "en_US");
