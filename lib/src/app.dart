import 'dart:async';
import 'dart:io';

import 'package:lucifer/lucifer.dart';
import 'package:queue/queue.dart';

import 'controller/controller.dart';
import 'handlers/handlers.dart';
import 'parsers/form_parser.dart';
import 'route/route.dart';
import 'route/route_matcher.dart';
import 'route/router.dart';
import 'exceptions.dart';
import 'local.dart';
import 'method.dart';
import 'request.dart';
import 'response.dart';
import 'socket.dart';
import 'typedef.dart';

///
/// Lucifer Core App
///
class App {
  App({
    this.idleTimeout,
    this.parallel = 50,
    this.shared = true,
    String? sslCertificate,
    String? privateKey,
    String? password,
  }) {
    // initialize
    _environment = env('ENV') ?? 'development';
    _requestQueue = Queue(parallel: parallel);
    _localData = LocalData();

    if (sslCertificate != null && privateKey != null && password != null) {
      String chain = Platform.script.resolve(sslCertificate).toFilePath();
      String key = Platform.script.resolve(privateKey).toFilePath();

      _securityContext = SecurityContext();
      _securityContext?.useCertificateChain(chain);
      _securityContext?.usePrivateKey(key, password: password);
    }
  }

  /// Gets or sets the timeout used for idle keep-alive connections.
  /// If no further request is seen within [idleTimeout] after the previous
  /// request was completed, the connection is dropped.
  ///
  /// Default is 120 seconds.
  ///
  /// Note that it may take up to 2 * idleTimeout before idle connection is aborted.
  /// To disable, set [idleTimeout] to null.
  final Duration? idleTimeout;

  /// The number of requests that can be processed at one time.
  ///
  /// Defaults to 50.
  ///
  final int parallel;

  /// If shared is true and more HttpServers from this isolate or other
  /// isolates are bound to the port, then the incoming connections will be
  /// distributed among all the bound HttpServers.
  ///
  /// Connections can be distributed over multiple isolates this way.
  ///
  /// Default shared is true.
  final bool shared;

  ///
  /// Environment status: development, testing or production
  ///
  late String _environment;

  String get environment => _environment;

  bool get isDevelopment => _environment == 'development';
  bool get isProduction => _environment == 'production';
  bool get isTesting => _environment == 'testing';

  ///
  /// Http Server
  ///
  late HttpServer _server;

  ///
  /// Local Data for this app
  ///
  late LocalData _localData;

  ///
  /// Requests queue
  ///
  late Queue _requestQueue;

  ///
  /// List of HTTP Route assigned for each [get,post,put,patch,delete] methods.
  ///
  List<Route> get routes => _routes;
  List<Route> _routes = [];

  void Function()? _onReady;

  ///
  /// To handle custom http errors
  ///
  final Map<int, Callback> _httpErrors = {};

  ///
  /// Security context for https
  ///
  SecurityContext? _securityContext;
  bool get _useSecure => _securityContext != null;

  ///
  /// the port used by this app
  ///
  int get port => _server.port;

  ///
  /// the host used by this app
  ///
  String get host => _server.address.host;

  ///
  /// Expose FormParser to be used in a route handler
  ///
  FormParser form() => FormParser();

  ///
  /// Create a socket server
  ///
  SocketServer socket(Req req, Res res) => SocketServer(req, res);

  /// Returns local data associated with the specified key
  ///
  /// If value is set, it will write to local data.
  ///
  T? local<T>(String key, [value]) {
    if (value == null) {
      return _localData.tryGet<T>(key);
    }

    _localData.set(key, value);
    return value;
  }

  ///
  /// Remove local data associated with the specified key
  ///
  T? removeLocal<T>(String key) {
    return _localData.remove(key);
  }

  ///
  /// Bind a custom error handler
  ///
  void on(int errorCode, Callback callback) {
    _httpErrors[errorCode] = callback;
  }

  ///
  /// Register route for all HTTP method
  ///
  App all(
    String path,
    dynamic middleware, [
    Callback? callback,
  ]) =>
      _addRoute(
        Method.all,
        path,
        middleware,
        callback,
      );

  ///
  /// Register a HEAD route
  ///
  App head(
    String path,
    dynamic middleware, [
    Callback? callback,
  ]) =>
      _addRoute(
        Method.head,
        path,
        middleware,
        callback,
      );

  ///
  /// Register a GET route
  ///
  App get(
    String path,
    dynamic middleware, [
    Callback? callback,
  ]) =>
      _addRoute(
        Method.get,
        path,
        middleware,
        callback,
      );

  ///
  /// Register a POST route
  ///
  App post(
    String path,
    dynamic middleware, [
    Callback? callback,
  ]) =>
      _addRoute(
        Method.post,
        path,
        middleware,
        callback,
      );

  ///
  /// Register a PUT route
  ///
  App put(
    String path,
    dynamic middleware, [
    Callback? callback,
  ]) =>
      _addRoute(
        Method.put,
        path,
        middleware,
        callback,
      );

  ///
  /// Register a DELETE route
  ///
  App delete(
    String path,
    dynamic middleware, [
    Callback? callback,
  ]) =>
      _addRoute(
        Method.delete,
        path,
        middleware,
        callback,
      );

  ///
  /// Register a PATCH route
  ///
  App patch(
    String path,
    dynamic middleware, [
    Callback? callback,
  ]) =>
      _addRoute(
        Method.patch,
        path,
        middleware,
        callback,
      );

  ///
  /// Register an OPTIONS route
  ///
  App options(
    String path,
    dynamic middleware, [
    Callback? callback,
  ]) =>
      _addRoute(
        Method.options,
        path,
        middleware,
        callback,
      );

  ///
  /// Register middleware(s) or apply a router
  ///
  /// We can use it like this.
  ///
  /// ```dart
  /// app.use(middleware); // single
  ///
  /// app.use([ middleware1, middleware2 ]); // multiple
  /// ```
  ///
  /// or with a specified path like this.
  ///
  /// ```dart
  /// app.use('/login', authMiddleware);
  ///
  /// app.use('/login', [ middleware1, middleware2 ]);
  /// ```
  ///
  /// To use it to apply a router.
  ///
  /// ```dart
  /// app.use(router); // apply the router for root
  /// ```
  ///
  /// or
  ///
  /// ```dart
  /// app.use('/api', router); // apply the router for /api
  /// ```
  ///
  App use(path, [middleware]) {
    bool isRouter = false;
    bool isMiddleware = false;

    // if only use 1 parameter (path)
    if (middleware == null) {
      // use for router, such as
      // app.use(router);
      if (path is Router) {
        isRouter = true;
      }

      // single middleware, such as
      // app.use(middleware);
      else if (path is Callback) {
        isMiddleware = true;
      }

      // multiple middlewares, such as
      // app.use([ middleware1, middleware2 ]);
      else if (path is List && path.isNotEmpty) {
        if (path.first is Callback) {
          isMiddleware = true;
        }
      }
    }

    // if use both parameter with correct path (string)
    if (path is String) {
      // use for router, such as
      // app.use('/api', router);
      if (middleware is Router) {
        isRouter = true;
      }

      // single middleware, such as
      // app.use('/api', middleware);
      else if (middleware is Callback) {
        isMiddleware = true;
      }

      // multiple middlewares, such as
      // app.use('/api', [ middleware1, middleware2 ]);
      else if (middleware is List && middleware.isNotEmpty) {
        if (middleware.first is Callback) {
          isMiddleware = true;
        }
      }
    }

    if (isRouter) {
      return _useRouter(path, middleware);
    }

    if (isMiddleware) {
      return _useMiddleware(path, middleware);
    }

    return this;
  }

  ///
  /// Register middleware(s).
  ///
  /// Use it like this.
  ///
  /// ```dart
  /// app.use(middleware);
  ///
  /// or
  ///
  /// app.use([ middleware1, middleware2 ]);
  /// ```
  ///
  /// or with a specified path like this.
  ///
  /// ```dart
  /// app.use('/login', authMiddleware);
  ///
  /// or
  ///
  /// app.use('/login', [ middleware1, middleware2 ]);
  /// ```
  ///
  App _useMiddleware(path, [middleware]) {
    List<Callback> middlewares = [];

    //
    // If only use 1 parameter (path), such as
    //
    // app.use(middleware);
    // app.use([ middleware1, middleware2 ]);
    //
    if (middleware == null) {
      // single middleware
      if (path is Callback) {
        middlewares = [path];
        path = '*';
      }

      // mutliple middlewares
      if (path is List && path.isNotEmpty) {
        if (path.first is Callback) {
          middlewares = [...path];
          path = '*';
        }
      }
    }

    // If both parameters are used, such as
    //
    // app.use('/api', middleware);
    // app.use('/api', [ middleware1, middleware2 ]);
    //
    if (path is String) {
      // single middleware
      if (middleware is Callback) {
        middlewares = [middleware];
      }

      // mutliple middlewares
      if (middleware is List && middleware.isNotEmpty) {
        if (middleware.first is Callback) {
          middlewares = [...middleware];
        }
      }
    }

    if (middlewares.isNotEmpty) {
      addRoute(Route(
        method: Method.all,
        path: path,
        middleware: middlewares,
      ));
    }

    return this;
  }

  ///
  /// Create Router to be used later with app.use()
  ///
  /// ```dart
  /// final router = app.router();
  ///
  /// router.get('/login', (req, res) {});
  /// router.get('/logout', (req, res) {});
  ///
  /// app.use('/auth', router);
  /// ```
  ///
  Router router([middleware]) {
    return Router(
      this,
      middleware: middleware,
      useRouteLater: true,
    );
  }

  ///
  /// Use router directly in a chained way.
  ///
  /// ```dart
  /// app.route('auth')
  ///   .get('/login', (req, res) {})
  ///   .get('/logout', (req, res) {});
  /// ```
  ///
  Router route(String path, [Controller? controller]) {
    Router router = Router(
      this,
      path: path,
      useRouteLater: false,
    );

    if (controller is Controller) {
      router.get('/', controller.index);
      router.post('/', controller.create);
      router.delete('/', controller.deleteAll);
      router.get('/:id', controller.view);
      router.put('/:id', controller.edit);
      router.delete('/:id', controller.delete);
    }

    return router;
  }

  ///
  /// Apply a defined router to this app.
  ///
  /// Use it like this.
  ///
  /// ```dart
  /// app.use(router); // apply the router for root /
  /// ```
  ///
  /// or
  ///
  /// ```dart
  /// app.use('/api', router); // apply the router for /api
  /// ```
  ///
  App _useRouter(path, [Router? router]) {
    // router without path
    // will apply to the root path
    if (path is Router && router == null) {
      path.apply(this);
    }

    // router to be applied to the specified path
    else if (path is String && router is Router) {
      router.apply(path);
    }

    return this;
  }

  ///
  /// Add and register a route.
  ///
  App _addRoute(
    Method method,
    String path,
    middleware, [
    Callback? callback,
  ]) {
    var or = middleware;
    var middlewares = <Callback>[];

    // route with a handler and middleware(s)
    if (callback != null) {
      // single middleware
      // such as: app.get('/', middleware, (req, res) {});
      if (or is Callback) {
        middlewares = [or];
      }

      // multiple middlewares
      // such as: app.get('/', [ middleware1, middleware2 ], (req, res) {});
      if (or is List && or.isNotEmpty) {
        if (or.first is Callback) {
          middlewares = [...or];
        }
      }
    }

    // route with a handler (and no middleware)
    // such as: app.get('/', (req, res) {});
    if (or is Callback && callback == null) {
      callback = or;
    }

    if (callback != null || middlewares.isNotEmpty) {
      addRoute(Route(
        path: path,
        method: method,
        middleware: middlewares,
        callback: callback,
      ));
    }

    return this;
  }

  ///
  /// Create a new route and add it to the routes list
  ///
  App addRoute(Route route) {
    _routes = [..._routes, route];
    return this;
  }

  App insertRoute(int index, Route route) {
    _routes.insert(index, route);
    return this;
  }

  ///
  /// Process incoming request
  ///
  Future<void> _processRequest(HttpRequest request) async {
    /// Initialize local data for this req res
    List initLocal = generateLocal();

    // Extract local data
    String localKey = initLocal[0];
    LocalData local = initLocal[1];

    local.set('___app___', this);

    Req req = Req(localKey, request);
    Res res = Res(localKey, request.response);

    res.local('___req___', req);

    // generate matched routes for this request
    final routes = RouteMatcher.match(
      method: req.httpMethod,
      path: req.path,
      routes: _routes,
    );

    try {
      // return 404 not found if no matched routes
      if (routes.isEmpty) {
        throw NotFoundException();
      }

      // to check if matched route contains callback with an empty function:
      //
      // app.get('/bloodyhell', (req, res) { });
      //
      // should return empty response, not return not found error.
      //
      bool hasCallback = false;

      // iterate through each matched routes
      for (final route in routes) {
        // parse params from its uri if the route has a handler
        // route can have null handler if it's a global middleware
        // registered in app.use
        req.params = RouteMatcher.params(route.path, req.uriString);

        if (route.hasCallback) {
          hasCallback = true;
          req.logs();
        }

        // iterate through each callback in the current route stack.
        for (final callback in route.stack) {
          // save result to be accessible in the next middleware or callback
          res.result = await callback(req, res);
          // res.log('${res.result}');

          // check return value, if false, close connection.
          if (res.result == false) {
            return await res.close();
          }
        }

        // only process result from route callback, not middleware.
        //
        // have to check hasCallback first, since route created from app.use()
        // can contains only middleware and null callback.
        if (route.hasCallback) {
          // if the returned data from callback saved at `res.result` is
          // not null and not boolean (true/false),
          // and res is still open
          if (res.open && res.hasValidResult) {
            await _handleResponse(req, res, res.result);
          }
        }
      }

      // if matched route has callback with an empty function,
      // it needs to return an empty response to the client.
      //
      // app.get('/bloodyhell', (req, res) { });
      //
      if (res.open && hasCallback) {
        return await res.end();
      }

      // return 404, if somehow still not closed
      // in the end of the process
      if (res.open) {
        throw NotFoundException();
      }
    } on HttpServerException catch (e) {
      if (e.stackTrace != null) print(e.stackTrace);
      await _handleHttpException(req, res, e.status, e.message);
    } catch (e, stackTrace) {
      print(stackTrace);
      String message = isProduction ? getStatusMessage(500) : e.toString();
      await _handleHttpException(req, res, 500, message);
    } finally {
      removeLocal(localKey);
      res.close();
    }
  }

  ///
  /// Handles Http Exception
  ///
  FutureOr _handleHttpException(
    Req req,
    Res res,
    int status,
    String message,
  ) async {
    req.logs();

    if (_httpErrors.containsKey(status)) {
      final callback = _httpErrors[status];

      if (callback is Function) {
        final result = await callback?.call(req, res);

        if (res.open) {
          if (result == false) {
            return await res.close();
          }

          await _handleResponse(req, res, result);
        }
      }
    }

    if (res.open) {
      await res.status(status).send(message);
    }
  }

  ///
  /// Handles a response according to data type
  ///
  FutureOr _handleResponse(Req req, Res res, data) async {
    if (data != null && data is! bool) {
      for (DataHandler handler in handlers) {
        if (handler.canHandle(data)) {
          await handler.process(req, res, data);
          return await res.close();
        }
      }
    }
  }

  ///
  /// Start the server by listening to the specified `host` and `port`.
  ///
  /// Can be called in two ways.
  ///
  /// ```dart
  /// await app.listen(port, () { });
  ///
  /// await app.listen(port, host, () { });
  ///
  /// ```
  ///
  /// Default host is localhost and port is 3000.
  ///
  Future<void> listen(int port, [host, void Function()? onReady]) async {
    // default host and port
    String defaultHost = 'localhost';

    // app.listen(3000);
    if (host == null && onReady == null) {
      host = defaultHost;
    }
    // app.listen(3000, () { });
    else if (host is void Function() && onReady == null) {
      onReady = host;
      host = defaultHost;
    }

    assert(port is int && host is String, 'Invalid parameter');

    if (_useSecure) {
      // bind https server to specified port
      _server = await HttpServer.bindSecure(
        host,
        port,
        _securityContext!,
        shared: shared,
      );
    } else {
      // bind server to specified port
      _server = await HttpServer.bind(
        host,
        port,
        shared: shared,
      );
    }

    // set custom idleTimeout
    if (idleTimeout is Duration) {
      _server.idleTimeout = idleTimeout;
    }

    // start listening for incoming requests
    _server.listen((HttpRequest request) {
      // add each request to queue for processing
      _requestQueue.add(() async {
        await _processRequest(request);
      });
    });

    // save onReady for restart
    _onReady = onReady;

    // inform server is ready
    onReady?.call();
  }

  /// Close the server.
  ///
  /// Default `force` is false.
  ///
  Future<void> close({bool force = false}) async {
    await _server.close(force: force);
  }

  ///
  /// Restart the server
  ///
  Future<void> restart() async {
    final port = this.port;
    final host = this.host;
    final onReady = _onReady;

    await close(force: true);
    await listen(port, host, onReady);
  }

  ///
  /// Print out registered routes to the console.
  ///
  /// Helpful to inspect what's available.
  ///
  void checkRoutes() {
    print('');
    for (var route in _routes) {
      if (route.hasCallback) {
        print(route.toString());
      }
    }
    print('');
  }
}
