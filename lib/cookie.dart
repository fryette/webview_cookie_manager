import 'dart:io';

class Cookie {
  final String name;
  final String value;

  String path;
  String domain;
  bool secure;
  bool httpOnly;

  DateTime expires;
  int maxAge;

  Cookie(this.name, this.value);

  String toString() {
    StringBuffer sb = new StringBuffer();
    sb..write(name)..write("=")..write(value);
    var expires = this.expires;
    if (expires != null) {
      sb..write("; Expires=")..write(HttpDate.format(expires));
    }
    if (maxAge != null) {
      sb..write("; Max-Age=")..write(maxAge);
    }
    if (domain != null) {
      sb..write("; Domain=")..write(domain);
    }
    if (path != null) {
      sb..write("; Path=")..write(path);
    }

    if (secure != null) sb.write("; Secure");
    if (httpOnly != null) sb.write("; HttpOnly");

    return sb.toString();
  }

  Cookie.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        value = json['value'],
        expires = json['expires'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['expires'])
            : null,
        maxAge = json['maxAge'] != null ? json['maxAge'] : null,
        path = json['path'] != null ? json['path'] : null,
        domain = json['domain'] != null ? json['domain'] : null,
        secure = json['secure'] != null ? json['secure'] : null,
        httpOnly = json['httpOnly'] != null ? json['httpOnly'] : null;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': name,
      'value': value,
    };

    if (expires != null) map['expires'] = expires.millisecondsSinceEpoch;
    if (maxAge != null) map['maxAge'] = maxAge;
    if (path != null) map['path'] = path;
    if (domain != null) map['domain'] = domain;
    if (secure != null) map['secure'] = secure;
    if (httpOnly != null) map['httpOnly'] = httpOnly;

    return map;
  }
}