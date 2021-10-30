///
/// Check if `data` is a URL
///
/// * [protocols] sets the list of allowed protocols
/// * [requireTld] sets if TLD is required
/// * [requireProtocol] is a `bool` that sets if protocol is required for validation
/// * [allowUnderscore] sets if underscores are allowed
/// * [hostWhitelist] sets the list of allowed hosts
/// * [hostBlacklist] sets the list of disallowed hosts
// ignore_for_file: prefer_typing_uninitialized_variables

bool isURL(data,
    {List<String?> protocols = const ['http', 'https', 'ftp'],
    bool requireTld = true,
    bool requireProtocol = false,
    bool allowUnderscore = false,
    List<String> hostWhitelist = const [],
    List<String> hostBlacklist = const []}) {
  if (data == null ||
      data is! String ||
      data.isEmpty ||
      data.length > 2083 ||
      data.startsWith('mailto:')) {
    return false;
  }

  var protocol,
      user,
      auth,
      host,
      hostname,
      port,
      portstr,
      path,
      query,
      hash,
      split;

  // check protocol
  split = data.split('://');
  if (split.length > 1) {
    protocol = shift(split);
    if (!protocols.contains(protocol)) {
      return false;
    }
  } else if (requireProtocol == true) {
    return false;
  }

  data = split.join('://');

  // check hash
  split = data.split('#');
  data = shift(split);
  hash = split.join('#');
  if (hash != null && hash != "" && RegExp(r'\s').hasMatch(hash)) {
    return false;
  }

  // check query params
  split = data.split('?');
  data = shift(split);
  query = split.join('?');
  if (query != null && query != "" && RegExp(r'\s').hasMatch(query)) {
    return false;
  }

  // check path
  split = data.split('/');
  data = shift(split);
  path = split.join('/');
  if (path != null && path != "" && RegExp(r'\s').hasMatch(path)) {
    return false;
  }

  // check auth type urls
  split = data.split('@');
  if (split.length > 1) {
    auth = shift(split);
    if (auth.indexOf(':') >= 0) {
      auth = auth.split(':');
      user = shift(auth);
      if (!RegExp(r'^\S+$').hasMatch(user)) {
        return false;
      }
      if (!RegExp(r'^\S*$').hasMatch(user)) {
        return false;
      }
    }
  }

  // check hostname
  hostname = split.join('@');
  split = hostname.split(':');
  host = shift(split);
  if (split.length > 0) {
    portstr = split.join(':');
    try {
      port = int.parse(portstr, radix: 10);
    } catch (e) {
      return false;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(portstr) || port <= 0 || port > 65535) {
      return false;
    }
  }

  if (!isIP(host) &&
      !isFQDN(host,
          requireTld: requireTld, allowUnderscores: allowUnderscore) &&
      host != 'localhost') {
    return false;
  }

  if (hostWhitelist.isNotEmpty && !hostWhitelist.contains(host)) {
    return false;
  }

  if (hostBlacklist.isNotEmpty && hostBlacklist.contains(host)) {
    return false;
  }

  return true;
}

/// check if `data` is IP [version] 4 or 6
///
/// * [version] is a String or an `int`.
bool isIP(data, [version]) {
  var ip4 = RegExp(r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$');
  var ip6 = RegExp(r'^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$');

  data = data.toString();
  version = int.tryParse(version.toString());

  if (version == null || version == 'null') {
    return isIP(data, 4) || isIP(data, 6);
  } else if (version == 4) {
    if (!ip4.hasMatch(data)) {
      return false;
    }
    var parts = data.split('.');
    parts.sort((a, b) => int.parse(a) - int.parse(b));
    return int.parse(parts[3]) <= 255;
  } else if (version == 6) {
    return ip6.hasMatch(data);
  }

  return false;
}

/// check if the string [str] is a fully qualified domain name (e.g. domain.com).
///
/// * [requireTld] sets if TLD is required
/// * [allowUnderscore] sets if underscores are allowed
bool isFQDN(
  data, {
  bool requireTld = true,
  bool allowUnderscores = false,
}) {
  if (data is! String) {
    return false;
  }

  var parts = data.split('.');

  if (requireTld) {
    var tld = parts.removeLast();
    if (parts.isEmpty || !RegExp(r'^[a-z]{2,}$').hasMatch(tld)) {
      return false;
    }
  }

  for (var part in parts) {
    if (allowUnderscores) {
      if (part.contains('__')) {
        return false;
      }
    }
    if (!RegExp(r'^[a-z\\u00a1-\\uffff0-9-]+$').hasMatch(part)) {
      return false;
    }
    if (part[0] == '-' ||
        part[part.length - 1] == '-' ||
        part.contains('---')) {
      return false;
    }
  }

  return true;
}

shift(List l) {
  if (l.isNotEmpty) {
    var first = l.first;
    l.removeAt(0);
    return first;
  }
  return null;
}
