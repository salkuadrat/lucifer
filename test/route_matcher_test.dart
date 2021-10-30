import 'dart:async';

import 'package:lucifer/lucifer.dart';
import 'package:lucifer/src/route/route_matcher.dart';
import 'package:test/test.dart';

List<String> match(String path, List<Route> routes) {
  return RouteMatcher.match(method: Method.get, path: path, routes: routes)
      .map((route) => route.path)
      .toList();
}

FutureOr Function(Req req, Res res) get _callback => (req, res) async {};

void main() {
  test('it should match routes correctly', () {
    final testRoutes = [
      Route(method: Method.get, path: '/a/:id/go', callback: _callback),
      Route(method: Method.get, path: '/a', callback: _callback),
      Route(
        method: Method.get,
        path: '/b/a/:input/another',
        callback: _callback,
      ),
      Route(method: Method.get, path: '/b/a/:input', callback: _callback),
      Route(method: Method.get, path: '/b/B/:input', callback: _callback),
      Route(method: Method.get, path: '/[a-z]/yep', callback: _callback),
    ];

    expect(match('/a', testRoutes), ['/a']);
    expect(match('/a?query=true', testRoutes), ['/a']);
    expect(match('/a/123/go', testRoutes), ['/a/:id/go']);
    expect(match('/a/123/go/a', testRoutes), <String>[]);
    expect(
      match('/b/a/adskfjasjklf/another', testRoutes),
      ['/b/a/:input/another'],
    );
    expect(match('/b/a/adskfjasj', testRoutes), ['/b/a/:input']);
    expect(match('/d/yep', testRoutes), ['/[a-z]/yep']);
    expect(match('/b/B/yep', testRoutes), ['/b/B/:input']);
  });

  test('it should match wildcards', () {
    final testRoutes = [
      Route(method: Method.get, path: '*', callback: _callback),
      Route(method: Method.get, path: '/a', callback: _callback),
      Route(method: Method.get, path: '/b', callback: _callback),
    ];

    expect(match('/a', testRoutes), ['*', '/a']);
  });

  test('it should generously match wildcards for sub-paths', () {
    final testRoutes = [
      Route(method: Method.get, path: 'path/*', callback: _callback),
    ];

    expect(match('/path/to', testRoutes), ['path/*']);
    expect(match('/path/', testRoutes), ['path/*']);
    expect(match('/path', testRoutes), ['path/*']);
  });

  test('it should respect the route method', () {
    final testRoutes = [
      Route(method: Method.post, path: '*', callback: _callback),
      Route(method: Method.get, path: '/a', callback: _callback),
      Route(method: Method.get, path: '/b', callback: _callback),
    ];

    expect(match('/a', testRoutes), ['/a']);
  });

  test('it should extract the route params correctly', () {
    expect(
      RouteMatcher.params(
        '/a/:value/:value2',
        '/a/input/Item%20inventory%20summary',
      ),
      {
        'value': 'input',
        'value2': 'Item inventory summary',
      },
    );
  });

  test('it should correctly match routes that have a partial match', () {
    final testRoutes = [
      Route(method: Method.get, path: '/image', callback: _callback),
      Route(method: Method.get, path: '/imageSource', callback: _callback),
    ];

    expect(
        RouteMatcher.match(
                method: Method.get, path: '/imagesource', routes: testRoutes)
            .map((e) => e.path)
            .toList(),
        ['/imageSource']);
  });

  test('it handles a dodgy getParams request', () {
    var params = RouteMatcher.params('/id/:id/abc', '/id/10');
    expect(params, {});
  });

  test('it should ignore a trailing slash', () {
    final testRoutes = [
      Route(method: Method.get, path: '/b/', callback: _callback),
    ];

    expect(match('/b?qs=true', testRoutes), ['/b/']);
  });

  test('it should ignore a trailing slash in reverse', () {
    final testRoutes = [
      Route(method: Method.get, path: '/b', callback: _callback),
    ];

    expect(match('/b/?qs=true', testRoutes), ['/b']);
  });

  test('it should hit a wildcard route halfway through the uri', () {
    final testRoutes = [
      Route(method: Method.get, path: '/route/*', callback: _callback),
      Route(method: Method.get, path: '/route/route2', callback: _callback),
    ];

    expect(match('/route/route2', testRoutes), ['/route/*', '/route/route2']);
  });

  test('it should hit a wildcard route halfway through the uri - sibling', () {
    final testRoutes = [
      Route(method: Method.get, path: '/route*', callback: _callback),
      Route(method: Method.get, path: '/route', callback: _callback),
      Route(method: Method.get, path: '/route/test', callback: _callback),
    ];

    expect(match('/route', testRoutes), ['/route*', '/route']);

    expect(match('/route/test', testRoutes), ['/route*', '/route/test']);
  });

  test('it should match wildcards in the middle', () {
    final testRoutes = [
      Route(method: Method.get, path: '/a/*/b', callback: _callback),
      Route(method: Method.get, path: '/a/*/*/b', callback: _callback),
    ];

    expect(match('/a', testRoutes), <String>[]);
    expect(match('/a/x/b', testRoutes), ['/a/*/b']);
    expect(match('/a/x/y/b', testRoutes), ['/a/*/b', '/a/*/*/b']);
  });

  test('it should match wildcards at the beginning', () {
    final testRoutes = [
      Route(method: Method.get, path: '*.jpg', callback: _callback),
    ];

    expect(match('xjpg', testRoutes), <String>[]);
    expect(match('.jpg', testRoutes), <String>['*.jpg']);
    expect(match('path/to/picture.jpg', testRoutes), <String>['*.jpg']);
  });

  test('it should match regex expressions within segments', () {
    final testRoutes = [
      Route(method: Method.get, path: '[a-z]+/[0-9]+', callback: _callback),
      Route(method: Method.get, path: '[a-z]{5}', callback: _callback),
      Route(method: Method.get, path: '(a|b)/c', callback: _callback),
    ];

    expect(match('a/b', testRoutes), <String>[]);
    expect(match('3/a', testRoutes), <String>[]);
    expect(match('x/323', testRoutes), <String>['[a-z]+/[0-9]+']);
    expect(match('answer/42', testRoutes), <String>['[a-z]+/[0-9]+']);
    expect(match('abc', testRoutes), <String>[]);
    expect(match('abc42', testRoutes), <String>[]);
    expect(match('abcde', testRoutes), <String>['[a-z]{5}']);
    expect(match('final', testRoutes), <String>['[a-z]{5}']);
    expect(match('a/c', testRoutes), <String>['(a|b)/c']);
    expect(match('b/c', testRoutes), <String>['(a|b)/c']);
  });
}
