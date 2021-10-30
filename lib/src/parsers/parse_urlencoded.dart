import 'parse_value.dart';

/// Parse urlencoded request body into map
///
Map<String, dynamic> parseUrlEncoded(String body) {
  RegExp pattern = RegExp(r'^(.+)\[\]$');
  Map<String, dynamic> data = {};

  for (String query in body.split('&')) {
    if (query.trim().isNotEmpty) {
      if (query.contains('=')) {
        int middle = query.indexOf('=');

        String qkey = query.substring(0, middle);
        String qvalue = query.substring(middle + 1);

        String? key = Uri.decodeQueryComponent(qkey);
        String? value = Uri.decodeQueryComponent(qvalue);

        if (pattern.hasMatch(key)) {
          Match? match = pattern.firstMatch(key);
          key = match?.group(1);

          if (key != null && key.isNotEmpty) {
            if (data[key] is! List) {
              data[key] = [];
            }

            data[key] = [...data[key], parseValue(value)];
          }
        } else if (key.contains('.')) {
          // handle this kind of key
          // key1.key2.key3 = value ===> { key1: { key2: { key3: value }}}
          List<String> keys = key.split('.');

          String firstKey = keys.first;
          String lastKey = keys.last;

          // build chained map from the last key
          // start the map with { key3: value }
          Map map = { lastKey: parseValue(value) };

          // remove the last key and then iterate from last (reversed)
          // to chain the map
          keys.removeLast();

          for (String key in keys.reversed) {
            map = { key: map };
          }

          // after chained, the map will be like
          // { key1: { key2: { key3: value } } }

          // print('Chained map: $map');

          // check existing firstKey in data
          if (data.containsKey(firstKey)) {
            // check existing value of data[firstKey]
            if (data[firstKey] != null) {
              // combine map[firstKey] with existing value of data[firstKey]
              map[firstKey].addAll(data[firstKey] as Map);
            }
          }

          data[firstKey] = map[firstKey];
        } else {
          data[key] = parseValue(value);
        }
      } else {
        // for query without value like `enabled` in 
        // http://luciferdeckerstar.com/search?q=detective&enabled
        //
        // set it into data['enabled'] = true
        // 
        String key = Uri.decodeQueryComponent(query);
        data[key] = true;
      }
    }
  }

  return data;
}
