import '../utils/path.dart';
import '../app.dart';
import '../method.dart';
import '../typedef.dart';
import 'route.dart';

class Router {
  ///
  /// Reference to current App
  ///
  late App _app;

  ///
  /// Router base path
  ///
  String _basePath = '';

  /// Should `true` if used like this.
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
  /// It means the router only register the routes right now,
  /// and will add them later to the execution stack, when the router
  /// registered with app.use()
  ///
  /// and should `false` if used like this.
  ///
  /// It means it will register and add the routes directly
  /// to the current execution stack.
  ///
  /// ```dart
  /// app.route('auth')
  ///   .get('/login', (req, res) {})
  ///   .get('/logout', (req, res) {});
  /// ```
  ///
  bool _useRouteLater = true;

  ///
  /// List of registered routes for this Router.
  ///
  List<Route> _routes = [];

  Router(
    App app, {
    String path = '',
    dynamic middleware,
    bool useRouteLater = true,
  }) {
    _app = app;
    _basePath = path;
    _useRouteLater = useRouteLater;

    if (middleware != null) {
      _useMiddleware(middleware);
    }
  }

  ///
  /// Register route for all HTTP method
  ///
  Router all(
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
  Router head(
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
  Router get(
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
  Router post(
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
  Router put(
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
  Router delete(
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
  Router patch(
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
  Router options(
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

  /// To register middleware(s) in a router
  ///
  /// We can use it like this.
  ///
  /// ```dart
  /// router.use(middleware); // single
  ///
  /// router.use([ middleware1, middleware2 ]); // multiple
  /// ```
  ///
  /// or with a specified path like this.
  ///
  /// ```dart
  /// router.use('/login', authMiddleware);
  ///
  /// router.use('/login', [ middleware1, middleware2 ]);
  /// ```
  ///
  Router use(path, [middleware]) {
    return _useMiddleware(path, middleware);
  }

  Router _useMiddleware(path, [middleware]) {
    List<Callback> middlewares = [];

    // if only use 1 parameter (path), such as
    // app.use(middleware);
    // app.use([ middleware1, middleware2 ]);
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

    // if use both parameter with non-null path, such as
    // app.use('/api', middleware);
    // app.use('/api', [ middleware1, middleware2 ]);
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

    return addRoute(Route(
      path: path,
      method: Method.all,
      middleware: middlewares,
    ));
  }

  ///
  /// Build and register a route
  ///
  Router _addRoute(
    Method method,
    String path,
    dynamic callbackOrMiddleware, [
    Callback? callback,
  ]) {
    var or = callbackOrMiddleware;
    var middleware = <Callback>[];

    if (or is List && or.isNotEmpty) {
      if (or[0] is Callback) {
        middleware = [...or];
      }
    }

    if (or is Callback && callback != null) {
      middleware = [or];
    }

    if (or is Callback && callback == null) {
      callback = or;
    }

    return addRoute(Route(
      path: path,
      method: method,
      middleware: middleware,
      callback: callback,
    ));
  }

  ///
  /// Add a route either to this router routes list or
  /// to the current execution stack
  ///
  Router addRoute(Route route) {
    if (_useRouteLater) {
      // only add route to _routes when in later use.
      // it will be added to the current stack when apply() is called
      // from app.use(path, router);
      _routes = [..._routes, route];
    } else {
      String pathId = combinePath(_basePath, '/:id');
      bool standardPath = route.path == _basePath || route.path == '/:id';

      // find index of route GET '/:id' in this router
      int index = _app.routes
          .indexWhere((r) => r.method == Method.get && r.path == pathId);
      
      // This is related to the process of adding standard Controller routes
      // defined in app.route() method (app.dart lines 476 - 481).
      //
      // Insert the additional route to the index before route get '/:id'
      // so it won't be mistakenly recognised as route '/:id'
      // 
      // For example, when we want to add route GET /user/vip into /user
      // it can be mistakenly recognised by route /user/:id 
      // as a user with id = vip
      // 
      // That's why all route /:id should be put in the last.
      // 
      // If index == -1, it means there're no standard routes before,
      // so it's safe to use _app.addRoute()
      // 
      if (!standardPath && index != -1) {
        _app.insertRoute(
            index,
            Route(
                method: route.method,
                path: combinePath(_basePath, route.path),
                middleware: route.middleware,
                callback: route.callback));
      } else {
        _app.addRoute(Route(
          method: route.method,
          path: combinePath(_basePath, route.path),
          middleware: route.middleware,
          callback: route.callback,
        ));
      }
    }

    return this;
  }

  ///
  /// Apply the defined routes in this router
  /// to the current execution stack
  ///
  void apply([path]) {
    String basePath = path is String ? path : _basePath;

    for (var route in _routes) {
      _app.addRoute(Route(
        method: route.method,
        path: combinePath(basePath, route.path),
        middleware: route.middleware,
        callback: route.callback,
      ));
    }
  }
}
