# Lucifer Lightbringer

<img src="https://github.com/salkuadrat/lucifer/raw/master/lucifer.png" height="200" alt="Lucifer">

Lucifer is a fast, lightweight web framework in dart.

Built on top of native dart `HttpServer` to provide an elegant way to fulfill the needs of many modern web server these days.

Lucifer is open, efficient, and provide lots of features to handle dozen kinds of things.

## Installation 

[Install Dart SDK](https://dart.dev/get-dart)

You may start creating a new Lucifer project using lucy command.

```bash
pub global activate lucy

l create desire
```

The first command will activate command-line interface (CLI), named [Lucy](https://pub.dev/packages/lucy), to be accessible from your terminal. 

Then `l create desire` will generate your new project in the `desire` directory. 

Feel free to use any project name you want.

## Starting

Now we are ready to play with our web server.

You may open `main.dart` in your project `lib` directory to learn the structure of a simple lucifer application.

```dart
import 'package:lucifer/lucifer.dart';

void main() {
  final app = App();
  final port = env('PORT') ?? 3000;

  app.use(logger());

  app.get('/', (Req req, Res res) async {
    await res.send('Hello Detective');
  });

  await app.listen(port);
  print('Server running at http://${app.host}:${app.port}');

  app.checkRoutes();
}
```

You may test running it with the following command:

```bash
cd desire
l run
```

Now you may open `http://localhost:3000` in the web browser. 

If all went well, it will display `Hello Detective` and print the following message in your terminal.

```text
Server running at http://localhost:3000
```

## Fundamentals 

You may learn the fundamentals of Lucifer by understanding the code inside the `lib/main.dart` of your new project.

The short lines of code do several things behind the scene.

First, we import `lucifer` and create a web application by assigning a new `App` instance to `app`

```dart
import 'package:lucifer/lucifer.dart';
```

```dart
final app = App();
```

Then we set the server port with value `3000` from the `.env` file in your root project directory.

You may change it with any port you want.

```dart
final port = env('PORT') ?? 3000;
```

Next we tell it to listen to a GET request on root path `/` with `app.get()`

```dart
app.get('/', (Req req, Res res) async {
  
});
```

Every HTTP verbs comes with its own method in Lucifer: `get()`, `post()`, `put()`, `patch()`, `delete()`, with the first argument corresponds to the route path.

```dart
app.get('/', (Req req, Res res) {

});

app.post('/', (Req req, Res res) {

});

app.put('/', (Req req, Res res) {

});

app.patch('/', (Req req, Res res) {

});

app.delete('/', (Req req, Res res) {

});
```

For the second argument, you may see a callback function that will be called when an incoming request is processed, and send a response with it.

To handle the incoming request and send a response, you may write your code inside the callback function.

```dart
app.get('/', (Req req, Res res) async {
  await res.send('Hello Detective');
});
```

In the route callback function, Lucifer provides two objects, `req` and `res`, that represents `Req` and `Res` instance.

`Req` is a Request class built on top of native dart `HttpRequest`. 

It holds all information about the incoming request, such as request parameters, query string, headers, body, and more.

`Res` is a Response class built on top of native dart `HttpResponse`. 

It's mostly used to manipulate response and sending it to the client.

What you did before is sending a message string `Hello Detective` to the client using `res.send()`. This method sets the string in the response body, and then close the connection.

The last line of our code starts the server and listen for incoming requests on the specified `port`:

```dart
await app.listen(port);
print('Server running at http://${app.host}:${app.port}');
```

As an alternative, you may also use `app.listen()` like so:

```dart
// listen to the specified port and host
await app.listen(port, '127.0.0.1');

// listen to the specified port with callback
await app.listen(port, () {
  print('Server running at http://${app.host}:${app.port}');
});

// listen to the specified port and host with callback
await app.listen(port, 'localhost', () {
  print('Server running at http://${app.host}:${app.port}');
});
```

## Environment Variables

Environment is a set of variables known to a process (such as, ENV, PORT, etc). 

It's highly recommended to mimic production environment during development by reading it from `.env` file.

When we run `l create` command, a `.env` file is created in the root project directory, containing these values.

```text
ENV = development
PORT = 3000
```

Then you may access the `.env` value from your dart code using `env()` method:

```dart
void main() {
  final app = App();
  final port = env('PORT') ?? 3000; // get port from env

  // get ENV value to check if it's a development or production stage
  final environment = env('ENV'); 

  ...
}
```

For maximum security, we should always use environment variables for important things, such as database configurations and JSON Web Token (JWT) secret.

And one more thing... you may open `.gitignore` file in the root directory, and see that `.env` is included there. 

It means your `.env` file will not be uploaded to remote repository like GitHub, and your environment variables values will never be exposed to the public eyes.

## Request Parameters 

We've learned before that the `req` object holds the HTTP request informations. 

There are some properties of `req` that you will likely access in your application.

<table>
  <tr>
    <th>Property</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>app</td>
    <td>holds reference to the Lucifer app object</td>
  </tr>
  <tr>
    <td>uriString</td>
    <td>URI string of the request</td>
  </tr>
  <tr>
    <td>path</td>
    <td>the URL path</td>
  </tr>
  <tr>
    <td>method</td>
    <td>the HTTP method being used</td>
  </tr>
  <tr>
    <td>params</td>
    <td>the route named parameters</td>
  </tr>
  <tr>
    <td>query</td>
    <td>a map object containing all the query string used in the request</td>
  </tr>
  <tr>
    <td>body</td>
    <td>contains the data submitted in the request body (must be parsed before you can access it)</td>
  </tr>
  <tr>
    <td>cookies</td>
    <td>contains the cookies sent by the request (needs the `cookieParser` middleware)</td>
  </tr>
  <tr>
    <td>protocol</td>
    <td>The request protocol (http or https)</td>
  </tr>
  <tr>
    <td>secure</td>
    <td>true if request is secure (using HTTPS)</td>
  </tr>
</table>

## GET Query String

Now you may learn how to retrieve the GET query parameters. 

Query string is the part that comes after URL path, and starts with a question mark `?` like `?username=lucifer`. 

Multiple query parameters can be added with character `&` like so:

```text
?username=lucifer&age=10000
```

How may we get the values?

Lucifer provides `req.query` object to make it easy to get all query values.

```dart
app.get('/', (Req req, Res res) {
  print(req.query);
});
```

The `req.query` object contains map of each query parameter. If there are no query, it will be an empty map or `{}`.

You may iterate on it with for loop. The following code will print each query key and its value:

```dart
for (var key in req.query.keys) {
  var value = req.query[key];
  print('Query $key: $value');
}
```

You may also access the individual value directly with `req.q()`

```dart
req.q('username'); // same as req.query['username']

req.q('age'); // same as req.query['age']
```

## POST Request Data

POST request data are sent by HTTP clients, such as from HTML form, or from a POST request sent using Postman or from an AJAX JavaScript code.

How may we access these data?

If the request data is sent as json with `Content-Type: application/json`, you may use `json()` middleware.

```dart
final app = App();

// use json middleware to parse json request body
// usually sent from REST API
app.use(json());
// use xssClean to clean the inputs
app.use(xssClean());
```

If it's sent as urlencoded `Content-Type: application/x-www-form-urlencoded`, you may use `urlencoded()` middleware.

```dart
final app = App();

// use urlencoded middleware to parse urlencoded request body
// usually sent from HTML form
app.use(urlencoded());
// use xssClean to clean the inputs
app.use(xssClean());
```

It all went well, you may access the parsed request data from `req.body`:

```dart
app.post('/login', (Req req, Res res) {
  final username = req.body['username'];
  final password = req.body['password'];
});
```

You may also use `req.data()` to access an individual request data directly:

```dart
app.post('/login', (Req req, Res res) {
  final username = req.data('username');
  final password = req.data('password');
});
```

Besides `json()` and `urlencoded()`, there are other available built in body parsers we can use. 

- `raw()` : to get request body as raw bytes
- `text()` : to get request body as a plain string
- `json()` : to parse json request body
- `urlencoded()` : to parse urlencoded request body
- `multipart()` : to parse multipart request body

To ensure the core framework stays lightweight, Lucifer will not assume anything about the request body. You may choose and apply the appropriate parser as needed in your application.

However, if you want to be safe and need to be able to handle all forms of request body, you may simply use the all-inclusive `bodyParser()` middleware.

```dart
final app = App();

app.use(bodyParser());
```

The `bodyParser` middleware will automatically detect the type of request body, and use the appropriate parser accordingly for each of incoming request in your application.

## Send Response 

In the example above, we have used `res.send()` to send a simple response to the client.

```dart
app.get('/', (Req req, Res res) async {
  await res.send('Hello Detective');
});
```

If you pass a string, lucifer will set `Content-Type` header to `text/html`.

If you pass a map or list object, it will set as `application/json`, and encode the data into JSON.

`res.send()` will set the correct `Content-Length` response header automatically.

`res.send()` also will close the connection when it's all done.

You may use `res.end()` method to send an empty response without any content in the response body.

```dart
app.get('/', (Req req, Res res) async {
  await res.end();
});
```

Another thing is you may also send the data directly without `res.send()` like so:

```dart
app.get('/string', (req, res) => 'string');

app.get('/int', (req, res) => 25);

app.get('/double', (req, res) => 3.14);

app.get('/json', (req, res) => { 'name': 'lucifer' });

app.get('/list', (req, res) => ['Lucifer',  'Detective']);
```

## HTTP Status Response

You may set the HTTP status response using `res.status()` method.

```dart
res.status(404).end();
```

or 

```dart
res.status(404).send('Not Found');
```

Or you may simply use `res.sendStatus()` for a shortcut.

```dart
// shortcut for res.status(200).send('OK');
res.sendStatus(200); 

// shortcut for res.status(403).send('Forbidden');
res.sendStatus(403);

// shortcut for res.status(404).send('Not Found');
res.sendStatus(404);

// shortcut for res.status(500).send('Internal Server Error');
res.sendStatus(500);
```

## JSON Response

Besides `res.send()` method, we may also use `res.json()` to send json data to the client. 

The method accepts a map or list object, and automatically encode it into json string with `jsonEncode()`

```dart
res.json({ 'name': 'Lucifer', 'age': 10000 });
```

```dart
res.json(['Lucifer', 'Detective', 'Amenadiel']);
```

## Cookies 

You may use `res.cookie()` to manage cookies in your application.

```dart
res.cookie('username', 'Lucifer');
```

The method accepts additional parameters with various options.

```dart
res.cookie(
  'username', 
  'Lucifer', 
  domain: '.luciferinheaven.com',
  path: '/admin',
  secure: true,
);
```

```dart
res.cookie(
  'username',
  'Lucifer',
  expires: Duration(milliseconds: DateTime.now().millisecondsSinceEpoch + 900000),
  httpOnly: true,
);
```

Here is some cookie parameters you may eat.

<table>
  <tr>
    <th>Value</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>domain</td>
    <td>String</td>
    <td>Domain name for the cookie. Defaults to the domain name of the app</td>
  </tr>
  <tr>
    <td>expires</td>
    <td>Date</td>
    <td>Expiry date of the cookie in GMT. If not specified or set to 0, creates a session cookie that will be deleted when client close the browser.
</td>
  </tr>
  <tr>
    <td>httpOnly</td>
    <td>bool</td>
    <td>Flags the cookie to be accessible only by the web server</td>
  </tr>
  <tr>
    <td>maxAge</td>
    <td>int</td>
    <td>Convenient option for setting the expiry time relative to the current time in milliseconds</td>
  </tr>
  <tr>
    <td>path</td>
    <td>String</td>
    <td>Path for the cookie. Defaults to /</td>
  </tr>
  <tr>
    <td>secure</td>
    <td>bool</td>
    <td>Marks the cookie to be used with HTTPS only</td>
  </tr>
  <tr>
    <td>signed</td>
    <td>bool</td>
    <td>Indicates if the cookie should be signed</td>
  </tr>
  <tr>
    <td>sameSite</td>
    <td>bool or String</td>
    <td>Set the value of SameSite cookie</td>
  </tr>
</table>

A cookie can be deleted with

```dart
res.clearCookie('username');
```

Or you may use the following code to clear all cookies.

```dart
res.clearCookies();
```

## Secure Cookies

You may secure cookies in your application using `secureCookie()` middleware.

```dart
String cookieSecret = env('COOKIE_SECRET_KEY');

app.use(secureCookie(cookieSecret));
```

`COOKIE_SECRET_KEY` needs to be set in the `.env` file and should be a random string unique to your application.

## HTTP Headers

You may get the HTTP header of a request from `req.headers`

```dart
app.get('/', (req, res) {
  print(req.headers);
});
```

You may also use `req.get()` or `req.header()` to get an individual header value.

```dart
app.get('/', (req, res) {
  final userAgent = req.get('User-Agent');

  // same as 

  req.header('User-Agent');
});
```

To change the HTTP header of a response to client, you may use use `res.set()` and `res.header()`

```dart
res.set('Content-Type', 'text/html');

// same as 

res.header('Content-Type', 'text/html');
```

Here are some other ways to modify the Content-Type header of a response to the clinet.

```dart
res.type('.html'); // res.set('Content-Type', 'text/html');

res.type('html'); // res.set('Content-Type', 'text/html');

res.type('json'); // res.set('Content-Type', 'application/json');

res.type('application/json'); // res.set('Content-Type', 'application/json');

res.type('png'); // res.set('Content-Type', 'image/png');
```

## Redirects

Using redirects are common thing to do in a web application. 

You may redirect a response in your application with `res.redirect()` or `res.to()`

```dart
res.redirect('/get-over-here');

// same as 

res.to('/get-over-here');
```

It will create redirect with the default 302 status code.

You may also use it this way to set a custom status code.

```dart
res.redirect(301, '/get-over-here');

// same as 

res.to(301, '/get-over-here');
```

You may pass the path to `res.redirect()` with an absolute path (`/get-over-here`), an absolute URL (`https://scorpio.com/get-over-here`), a relative path (`get-over-here`), or `..` to go back one level.

```dart
res.redirect('../get-over-here');

res.redirect('..');
```

Or you may simply use `res.back()` to redirect back to the previous url, based on the HTTP Referer value sent by client in the request header (defaults to / if it's not set).

```dart
res.back();
```

## Routing 

Routing is the process of determining what should happen when a URL is called, and which parts of the application needs to handle the request.

In the example before we have used routing like so:

```dart
app.get('/', (req, res) async {

});
```

The code above creates a route that maps a root path `/` with HTTP GET method to the response we provide inside the callback function.

We may use named parameters to listen for custom request. 

Say we want to provide a profile API that accepts a string as username, and return the user details. 

However, we want the string parameter to be part of the URL, not as a query string. 

So we use the named parameters like so:

```dart
app.get('/profile/:username', (Req req, Res res) {
  // get username from URL parameter
  final username = req.params['username'];

  print(username);
});
```

You may use multiple parameters in the same URL, then it will be included automatically to the `req.params` values.

You may also use `req.param()` to access an individual value of `req.params`

```dart
app.get('/profile/:username', (Req req, Res res) {
  // get username from URL parameter
  final username = req.param('username');

  print(username);
});
```

<!---
Use regular expression to match multiple paths with one statement.

```dart
app.get(RegExp(/post/), (Req req, Res res) {

});
```

The regex route above will match every requests that contains string `post`, such as `/post`, `/post/first`, `/thepost`, `/shitposting/anything` and so on.

-->

## Advanced Routing

We may use `Router` object from `app.router()` to build an organized routing.

```dart
final app = App();
final router = app.router();

router.get('/login', (req, res) async {
  await res.send('Login Page');
});

app.use('/auth', router);
```

You may run the code above, and the login page will be available at http://localhost:3000/auth/login.

You may register as many routers as you need.

```dart
final app = App();

final auth = app.router();
final user = app.router();

// register routes for auth

auth.get('/login', (Req req, Res res) async {
  await res.send('Login Page');
});

auth.post('/login', (Req req, Res res) async {
  // process POST login
});

auth.get('/logout', (Req req, Res res) async {
  // process logout
});

// register routes for user

user.get('/', (Req req, Res res) async {
  await res.send('List User');
});

user.get('/:id', (Req req, Res res) async {
  final id = req.param('id');
  await res.send('Profile $id');
});

user.post('/', (Req req, Res res) async {  
  // create user
});

user.put('/:id', (Req req, Res res) async {
  // edit user by id
});

user.delete('/', (Req req, Res res) async {
  // delete all users
});

user.delete(':id', (Req req, Res res) async {
  // delete user
});

// apply the router
app.use('/auth', auth);
app.use('/user', user);
```

Using `app.router()` is a good practice to organize your endpoints. 

You may split them into some independent files to maintain a clean, structured and easy-to-read code.

Another way to organize your app is using `app.route()`

```dart
final app = App();

app.route('/user')
  .get('/', (Req req, Res res) async {
    await res.send('List User');
  })
  .get('/:id', (Req req, Res res) async {
    final id = req.param('id');
    await res.send('Profile $id');
  })
  .post('/', (Req req, Res res) async {
    // create user
  })
  .put('/:id', (Req req, Res res) async {
    // edit user by id
  })
  .delete('/', (Req req, Res res) async {
    // delete all users
  })
  .delete('/:id', (Req req, Res res) async {
    // delete user
  });
```

Another way to use `app.route()` is by utilizing class `Controller`. 

This is useful especially when you are building a REST API.

You may create a new controller in the `/lib/controller` directory.

```dart
class UserController extends Controller {
  UserController(App app) : super(app);

  @override
  FutureOr index(Req req, Res res) async {
    await res.send('User List');
  }

  @override
  FutureOr view(Req req, Res res) async {
    await res.send('User Detail');
  }

  @override
  FutureOr create(Req req, Res res) async {
    await res.send('Create User');
  }

  @override
  FutureOr edit(Req req, Res res) async {
    await res.send('Edit User');
  }

  @override
  FutureOr delete(Req req, Res res) async {
    await res.send('Delete User');
  }

  @override
  FutureOr deleteAll(Req req, Res res) async {
    await res.send('Delete All Users');
  }
}
```

Then use it in your main app like so.

```dart
final app = App();
final user = UserController(app);

// This will add all associated routes for all methods
app.route('/user', user);

// The 1-line code above is the same as 
// manually adding these yourself
app.route('/user')
  .get('/', user.index)
  .post('/', user.create)
  .delete('/', user.deleteAll)
  .get('/:id', user.view)
  .put('/:id', user.edit)
  .delete('/:id', user.delete);
```

It's a good practice to split your routes into its own independent controllers.

You may also add more methods to your `Controller`

```dart
class UserController extends Controller {

  ...

  FutureOr vip(Req req, Res res) async {
    await res.send('List of VIP Users');
  }
}
```

And apply the method by chaining `app.route()`

```dart
final app = App();
final user = UserController(app);

// this will add route GET /user/vip into your app
// along with all the standard routes above
app.route('/user', user).get('/vip', user.vip);
```

To help you with adding `Controller` to your project, Lucifer provides another command.

```shell
$ l c post
```

The command above will create file `post_controller.dart` in the `/lib/controller` directory, and fill it with a boilerplate `PostController` class.

You may also use the command to create multiple `Controller`.

```shell
$ l c post news user customer
```

## Static Files

It's common to have images, css, and javascripts in a public folder.

You may expose them by using `static()` middleware.

```dart
final app = App();

app.use(static('public'));
```

Now if you have `index.html` file in the `public` directory, it will be served automatically when you hit `http://localhost:3000`.

## Sending Files

Lucifer provides a simple way to send file to the client with `res.download()` or `res.sendFile()`.

When user hit a route that sends file with `res.download()`, browsers will prompt the user for download. 

Instead of showing it in the browser, the file will be saved to the local drive.

```dart
app.get('/downloadfile', (Req req, Res res) async {
  await res.download('thefile.pdf');

  // same as

  await res.sendFile('thefile.pdf');
});
```

You may send file with a custom filename.

```dart
app.get('/downloadfile', (Req req, Res res) async {
  await res.download('thefile.pdf', 'File.pdf');
});
```

And use the following to handle error during the process of sending file.

```dart
app.get('/downloadfile', (Req req, Res res) async {
  final err = await res.download('./thefile.pdf', 'File.pdf');

  if (err != null) {
    // handle error
  }
});
```

## CORS 

A client app running in the browser usually can only access resources from the same domain (origin) as the server.

Loading images or scripts/styles usually works, but XHR and Fetch calls to another server will fail, unless the server implements a way to allow that connection.

That way is CORS (Cross-Origin Resource Sharing).

Loading web fonts using `@font-face` also has same-origin-policy by default, and also other less popular things (like WebGL textures).

If we don't set up a CORS policy that allows 3rd party origins, the requests will fail.

A cross origin request fail if it's sent

- to a different domain 
- to a different subdomain
- to a different port
- to a different protocol

CORS exists for your own security... to prevent any malicious users from exploiting your resources.

But if you control both the server and client, it's assumed to be safe to allow them to talk with each other.

You may use `cors` middleware to set up the CORS policy.

As an example, lets say you have a simple route without cors.

```dart
final app = App();

app.get('/no-cors', (Req req, Res res) async {
  await res.send('Risky without CORS');
});
```

When you hit `/no-cors` using fetch request from a different origin, it will raise a CORS issue.

All you need to make it work is using the built in `cors` middleware and pass it to the request handler.

```dart
final app = App();

app.get('/yes-cors', cors(), (Req req, Res res) async {
  await res.send('Now it works');
});
```

You may apply `cors` for all incoming requests by using `app.use()`

```dart
final app = App();

app.use(cors());

app.get('/', (Req req, Res res) async {
  await res.send('Now all routes will use cors');
});
```

By default, cors will set cross-origin header to accept any incoming requests. You may change it to only allow one origin and block all the others.

```dart
final app = App();

app.use(cors(
  origin: 'https://luciferinheaven.com'
));

app.get('/', (Req req, Res res) async {
  await res.send('Now all routes can only accept request from https://luciferinheaven.com');
});
```

You may also set cors to allow multiple origins.

```dart
final app = App();

app.use(cors(
  origin: [
    'https://yourfirstdomain.com',
    'https://yourseconddomain.com',
  ],
));

app.get('/', (Req req, Res res) async {
  await res.send('Now all routes can accept request from both origins');
});
```

## Session

We need to use sessions to identify client across the incoming requests.

By default, HTTP requests are stateless, sequential and two requests can't be linked to each other. 

There is no way to know if a request comes from a client that has already performed another request.

Users can't be identified unless we use some kind of magic that makes it possible.

This is what sessions are (JSON Web Token is another).

When handled correctly, each user of your application will be assigned to a unique session ID, and it allows you to store the user state.

You may use the built-in `session` middleware.

```dart
final app = App();

app.use(session(secret: 'super-s3cr3t-key'));
```

And now all requests in your application will use session.

`secret` is the only required parameter, but there are many more you can use.

`secret` should use a random string, unique to your application (or generate it from [randomkeygen](https://randomkeygen.com/)).

This session is now active and attached to the request. 

You may access it using `req.session()`

```dart
app.get('/', (Req req, Res res) {
  print(req.session()); // print all session values
});
```

To get a specific value from the session, you may use `req.session(name)`

```dart
final username = req.session('username');
```

You may use `req.session(name, value)` to add (or replace) value in the session.

```dart
final username = 'lucifer';

req.session('username', username);
```

Sessions can be used to communicate data between middlewares, or retrieve it later in the next request.

Where do we store this session? Well, it depends on the set up that we use for our sessions.

It can be stored in:

- memory: this is the default, but don't use it in production
- database: like Postgres, SQLite, MySQL or MongoDB
- memory cache: like Redis or Memcached

All the session store above will only set session ID in a cookie, and keep the real data server-side. 

Clients will receive this session id, and send it back in each of their next requests. 

Then the server can use it to get the data associated with these session.

Memory is the default setting for session. It's simple and needs zero setup on your part. 

However, it's not recommended for production. 

The most efficient is using memory cache like Redis, but it needs some efforts on your part to set up the infrastructure.

## JSON Web Token

JSON Web Token (JWT) is an open standard (RFC 7519) that defines a compact and self-contained way for securely transmitting information between parties as a JSON object. 

This information can be verified and trusted because it is digitally signed. 

JWTs can be signed using a secret (with the HMAC algorithm) or a public/private key pair using RSA or ECDSA.

You may utilize JWT in your Lucifer application by using an instance of `Jwt`  to sign and verify token.

```dart
final app = App();
final port = env('PORT') ?? 3000;

final jwt = Jwt();

// Don't forget to put your jwt secret in environment variables
final secret = env('JWT_SECRET');

app.get('/login', (Req req, Res res) {

  ...

  final payload = <String, dynamic>{
    'username': 'lucifer',
    'age': 10000,
  };

  final token = jwt.sign(
    payload, 
    secret, 
    expiresIn: Duration(seconds: 86400),
  );

  // Send token to the client by putting it  
  // into 'x-access-token' header
  res.header('x-access-token', token);

  ...

});
```

You may use `jwt.verify()` to verify the token.

```dart
final app = App();
final port = env('PORT') ?? 3000;

final jwt = Jwt();
final secret = env('JWT_SECRET');

app.get('/', (Req req, Res res) {
  // Get token from 'x-access-token' header
  final token = req.header('x-access-token');

  try {
    final data = jwt.verify(token, secret);

    if (data != null) {
      print(data['username']);
    }
  } on JWTExpiredError {
    // handle JWTExpiredError
  } on JWTError catch (e) {
    // handle JWTError
  } on Exception catch (e) {
    // handle Exception
  }

  ...

});
```

Another way to verify the token.

```dart
final app = App();
final port = env('PORT') ?? 3000;

final jwt = Jwt();
final secret = env('JWT_SECRET');

app.get('/', (Req req, Res res) {
  // Get token from client 'x-access-token' header
  final token = req.header('x-access-token');

  jwt.verify(token, secret, (error, data) {
    if (data != null) {
      print(data['username']);
    }

    if (error != null) {
      print(error);
    }
  });

  ...

});
```

## Middleware

Middleware is a function that hooks into the routing process. It performs some operations before executing the route callback handler.

Middleware is usually used to modify the req or res object, or to terminate the request before it reaches route callback.

You may add middleware in your Lucifer application like so:

```dart
app.use((Req req, Res res) async {
  // do something
});
```

The code looks similar with the route callback.

Most of the time, you will be enough with using the built-in Lucifer middlewares, like `static`, `cors`, or `session`.

However, you may create a custom middleware, and then use it for a specific route by putting it in the middle of route and callback.

```dart
final app = App();

// create custom middleware
final custom = (Req req, Res res) async {
  // do something here
};

// use the middleware for GET / request
app.get('/', custom, (Req req, Res res) async {
  await res.send('angels');
});
```

You may apply multiple middlewares to the route you want.

```dart
final app = App();

final verifyToken = (Req req, Res res) async {
  // do something here
};

final authorize = (Req req, Res res) async {
  // do something here
};

app.get('/user', [ verifyToken, authorize ], (req, res) async {
  await res.send('angels');
});
```

If you need to pass data from a middleware to be accessible at the next middlewares or the route callback, you may use `res.local()`

```dart
final app = App();

final verifyToken = (Req req, Res res) async {
  // saving token into the local data
  res.local('token', 'jwt-token');
};

final authorize = (Req req, Res res) async {
  // get token from local data
  var token = res.local('token');
};

app.get('/user', [ verifyToken, authorize ], (req, res) async {
  // get token from local data
  var token = res.local('token');
});
```

There is no `next()` to call in these middleware (unlike other web frameworks). 

Processing next is automatically handled by lucifer.

Lucifer will always run to the next middleware or callback in the current stack... Unless, you send some response to the client in the middleware, which will close the connection and stop all executions of the next middlewares/callback.

Since the call is automatic, it's important to always remember to use proper  `async` `await` when you're dealing with asynchronous functions.

As an example, remember to use `async` `await` when using `res.download()` to send a file to the client:

```dart
app.get('/download', (Req req, Res res) async {
  await res.download('somefile.pdf');
});
```

Here is a simple rule to follow... if calling a function that returns `Future` or `FutureOr`, you may be better to play safe and use `async` `await`

If in the middle of debugging your application, you see error in the terminal with messages like `HTTP headers not mutable` or `headers already sent`, it's a clear indicator that some parts in the application need to use proper `async await`.

To help you with adding custom middleware to your project, Lucifer provides another command like so:

```shell
$ l m custom
```

The command above will create file `custom.dart` in the `/lib/middleware` directory, and fill it with a boilerplate `custom` middleware function.

You may also use the command to generate multiple middlewares.

```shell
$ l m custom log auth
```

## Forms

Say we have an HTML form like so:

```html
<form method="POST" action="/login">
  <input type="text" name="username" />
  <input type="password" name="password" />
  <input type="submit" value="Login" />
</form>
```

When user press the submit button, browser will automatically make a POST request to `/login`, and with it, sending some data to the server encoded as `application/x-www-form-urlencoded`. 

In this case, the POST data contains `username` and `password`.

Form may also send data with GET method, but mostly it will use the standard POST.

The data will be attached in the request body. To extract it, you may use the built in `urlencoded` middleware.

```dart
final app = App();

app.use(urlencoded());
// always use xssClean to clean the inputs
app.use(xssClean());
```

You may test creating a POST endpoint for `/login`, and the submitted data will be available at `req.body`. 

```dart
app.post('/login', (Req req, Res res) async {
  final username = req.body['username']; // same as req.data('username');
  final password = req.body['password']; // same as req.data('password');

  ...
});
```

You may also use `req.data()` to access an individual value of the form data.

```dart
app.post('/login', (Req req, Res res) async {
  final username = req.data('username');
  final password = req.data('password');

  ...
});
```

<!---

Now you may learn how to validate and sanitize the form data using `check` middleware.

## Input Validation

Say you have a POST endpoint that accepts name, email and age.

```dart
final app = App();

app.use(urlencoded());
// always use xssClean to clean the inputs
app.use(xssClean());

app.post('/user', (Req req, Res res) async {
  final name = req.data('name');
  final email = req.data('email');
  final age = req.data('age');

  ...

});
```

How to validate those results (server-side) to make sure:

- name is a string with at least 3 characters?
- email is a valid email?
- age is a number between 0 and 150?

The easy way to do this is using `check` middleware.

```dart
final app = App();
final check = app.check();

final validations = [
  check('name').isLength({ min: 3}),
  check('email').isEmail(),
  check('age').isNumeric(),
];

app.post('/user', validations, (Req req, Res res) async {
  final name = req.data('name');
  final email = req.data('email');
  final age = req.data('age');

  ...

});
```

Beside those three `isLength`, `isEmail` and `isNumeric`, there are other methods we can use.

- `contains()`: check if the data contains a specified value
- `equals()`: check if the data equals a specified value
- `isAlpha()`
- `isAlphanumeric()`
- `isAscii()`
- `isBase64()`
- `isBoolean()`
- `isCurrency()`
- `isDecimal()`
- `isEmpty()`
- `isFloat()`
- `isHash()`
- `isHexColor()`
- `isIP()`
- `isInt()`
- `isJSON()`
- `isLatLong()`
- `isLowercase()`
- `isMobilePhone()`
- `isPostalCode()`
- `isURL()`
- `isUppercase()`
- `isWhitelisted()`: theck if the data is in a whitelist of allowed characters
- `isIn()`: check if the data is in array of specified values
- `isFQDN()`: is a fully qualified domain name

You may also validate the input with regular expression by using `matches()`.

Dates can be checked with 

- `isAfter()`: check if the entered date is after the one you pass 
- `isBefore()`: check if the entered date is before the one you pass
- `isISO8601()`
- `isRFC3339()`

All those validations can be combined like this.

```dart
check('name').isAlpha().isLength({ min: 10 })
```

If there is an error in validation, the server will automatically send it along with the response to the client. For example, if email is not valid, error message will be sent.

```json
{
  "errors": [
    {
      "location": "body",
      "msg": "Invalid value",
      "param": "email"
    }
  ]
}
```

The default error can be customized for any validation by using `withMessage()`

```dart
check('name')
  .isAlpha()
  .withMessage('Must be alphabetical chars only')
  .isLength({ min: 10 })
  .withMessage('Must be at least 10 chars long')
```

Need to have a custom validator?

Don't worry, you can create your own custom function and reject the validation by throwing  Exception inside the function.

```dart
final validation = [
  check('name').isLength({ min: 3 }),
  check('email').custom((email) {
    if (isDuplicateEmail(email)) {
      throw Exception('Email already registered');
    }
  }),
  check('age').isNumeric(),
];

app.post('/user', validation, (Req req, Res res) async {

});
```

## Input Sanitization

One sensible rule to follow when you run a public server is... never trust any input from any user.

Even if you have sanitized and make sure people can't enter weird things in the client side, you would still be open to people with tools (such as Chrome devtools or Postman) to send a POST request directly to your server.

Or some bots trying some clever ways to find a hole in your ship.

The thing we should do is sanitize the inputs.

You may use the same `check` middleware to perform this sanitization.

Say you already have a POST endpoint with complete validation.

```dart
final validations = [
  check('name').isLength({ min: 3}),
  check('email').isEmail(),
  check('age').isNumeric(),
];

app.post('/user', validations, (Req req, Res res) async {
  final name = req.data('name');
  final email = req.data('email');
  final age = req.data('age');

  ...

});
```

Now you may piping some sanitization methods after the validation.

```dart
final validations = [
  check('name').isLength({ min: 3}),
  check('email').isEmail().normalizeEmail(),
  check('age').isNumeric().trim().escape(),
];

app.post('/user', validations, (Req req, Res res) async {
  final name = req.data('name');
  final email = req.data('email');
  final age = req.data('age');

  ...

});
```

In the above example, we use three methods:

- `trim()`: to trim characters (whitespace by default) at the beginning and the end of a string
- `escape()`: to replace `<`, `>`, `&`, `'`, `"` and `/` with their corresponding HTML entities
- `normalizeEmail()`: to normalize an email address. It accepts several options to lowercase email addresses or subaddresses (e.g. lucifer+morningstar@heaven.com)

There are many other methods we can use.

- `blacklist()`: remove characters that appear in the blacklist
- `whitelist()`: remove characters that do not appear in the whitelist 
- `unescape()`: replaces HTML encoded entities
- `ltrim`: like `trim()`, but only at the start of the string
- `rtrim()`: like `trim()`, but only at the end of the string
- `stripLow()`: remove ASCII control characters, which are normally invisible

And to force conversion to some formats.

- `toBool()`: convert the input string to a boolean. Everything except for '0', 'false' and '' will return true.
- `toDate()`: convert the input string to a date, or null if the input is not a date
- `toDouble()`: convert the input string to a double, or null if the input is not a double
- `toInt()`: convert the input string to an integer, or null if the input is not an integer

Like validators, you may also create a custom sanitizer.

```dart
final custom = (value) {
  // sanitize this value however you like
};
  
final validation = [
  check('value').customSanitizer((value) => custom(value))
];

app.post('/user', validation, (Req req, Res res) async {
  // get the sanitized value
  final value = req.data('value');
});
```
-->

## File Uploads

Lets say you have an HTML form that allows user to upload file.

```html
<form method="POST" action="/upload">
  <input type="file" name="document" />
  <input type="submit" value="Upload" />
</form>
```

When press the submit button, browser will automatically send a POST request to the route `/upload`, and sending file from the input file.

It won't be sent as `application/x-www-form-urlencoded` like the standard form, but as `multipart/form-data`.

Handling multipart data can be tricky and error prone, so you may use the built-in `FormParser` object that you can access with `app.form()`

```dart
final app = App();
final form = app.form();

app.post('/upload', (Req req, Res res) async {
  await form.parse(req, (error, fields, files) {
    if (error) {
      print('$error');
    }

    print(fields);
    print(files);
  });
});
```

You may use it per event that will be notified whenever each file is processed. This will also notify other events, such as when processing end, when receiving other non-file field, or when an error happened.

```dart
final app = App();
final form = app.form();

app.post('/upload', (Req req, Res res) async {
  await form
    .onField((name, field) {
      print('${name} ${field}');
    })
    .onFile((name, file) {
      print('${name} ${file.filename}');
    })
    .onError((error) {
      print('$error');
    })
    .onEnd(() {
      res.end();
    })
    .parse(req);
});
```

You may also use it like this:

```dart
final app = App();
final form = app.form();

app.post('/upload', (Req req, Res res) async {
  await form
    .on('field', (name, field) {
      print('${name} ${field}');
    })
    .on('file', (name, file) {
      print('${name} ${file}');
    })
    .on('error', (error) {
      print('$error');
    })
    .on('end', () {
      res.end();
    })
    .parse(req);
});
```

Either way, you will get one or more `UploadedFile` objects, containing information about the uploaded files. 

Here are the value you may use.

- `file.name`: to get the name from input file
- `file.filename`: to get the filename 
- `file.type`: to get the MIME type of the file
- `file.data`: to get raw byte data of the uploaded file

By default, `FormParser` will only contains raw bytes data of the file and not save it into any folder.

You may handle it yourself like so:

```dart
import 'package:path/path.dart' as path;

// file is an UploadedFile object you get before

// save to uploads directory
String uploads = path.absolute('uploads');

// use the same filename as sent by the client,
// but feel free to use other file naming strategy
File f = File('$uploads/${file.filename}');

// check if the file exists at uploads directory
bool exists = await f.exists();

// create file if not exists
if (!exists) {
  await f.create(recursive: true);
}

// write bytes data into the file
await f.writeAsBytes(file.data);

print('File is saved at ${f.path}');
```

## Templating

Lucifer provides a default templating by utilizing the `Mustache` engine. 

It uses a [`mustache_template`](https://pub.dev/packages/mustache_template) package which is implemented from the [official mustache spec](https://mustache.github.io/).

As usual, to keep the core framework stays lightweight, lucifer doesn't attach any template engine to your default application. 

To use the `mustache` templating engine, you may apply it first like so:

```dart
final app = App();

app.use(mustache());
```

Then you may use the `mustache` to render any template you have in the project `views` directory.

Let say you have `index.html` in the `views` directory.

```html
<!DOCTYPE html>
<html>
  <head></head>
  <body>
    <h2>{{ title }}</h2>
  </body>
</html>
```

You may render the template using `res.render()` or `res.view()`:

```dart
final app = App();

app.use(mustache());

app.get('/', (Req req, Res res) async {
  await res.render('index', { 'title': 'Hello Detective' });
});
```

Now, you may run `l run` command, open http://localhost:3000, and you will see a rendered html page displaying `Hello Detective`.

You may change the default `views` directory with any directory you want.

```dart
final app = App();

// use 'template' as the views directory
app.use(mustache('template'));

app.get('/', (Req req, Res res) async {
  await res.view('index', { 'title': 'Hello Detective' });
});
```

You may add `index.html` to the `template` directory.

```html
<!DOCTYPE html>
<html>
  <head></head>
  <body>
    <h2>{{ title }} from template</h2>
  </body>
</html>
```

Then you may run it, open in the browser, and you will see another html page containing `Hello Detective from template`.

For more details on how to use `Mustache` engine, you may refer to the [mustache manual](https://mustache.github.io/mustache.5.html).

If you want to use other templating engines, such as [jinja](https://pub.dev/packages/jinja) or [jaded](https://pub.dev/packages/jaded), you may do it by handling the template rendering yourself and send the rendered html using `res.send()`

```dart
app.get('/', (Req req, Res res) async {
  // render your jinja/jaded template into 'html' variable
  // then send it to the client
  await res.send(html);
});
```

You may also doing it by creating a custom middleware to handle templating with your chosen engine.

You may learn from the example code of the `mustache` middleware to create your own custom templating.

```dart
// 
// name it with anything you want
// 
Callback customTemplating([String? views]) {
  return (Req req, Res res) {
    // 
    // you need to overwrite res.renderer
    // using the chosen template engine
    //
    res.renderer = (String view, Map<String, dynamic> data) async {
      // 
      // most of the time, these 2 lines will stay
      // 
      String directory = views ?? 'views';
      File file = File('$directory/$view.html');

      // 
      // file checking also stay
      // 
      if (await file.exists()) {
        // 
        // mostly, all you need to do is edit the following two lines 
        // 
        Template template = Template(await file.readAsString());
        String html = template.renderString(data);

        // 
        // for the final act, send the rendered html to the client
        //
        await res.send(html);
      }
    };
  };
}
```

To apply the new templating middleware, you may use `app.use()`

```dart
final app = App();

app.use(customTemplating());
```

## Security

Lucifer has a built-in `security` middleware that covers a complete standard security protections for guarding your application. 

To use them, you may simply apply it using `app.use()`

```dart
final app = App();

app.use(security());
```

[Read here](https://infosec.mozilla.org/guidelines/web_security.html) to learn more about the intricacies of web security.

## Error Handling

Lucifer will automatically handle the errors that occured in your application. 

However, you may set your own error handling using `app.on()`

```dart
final app = App();

app.on(404, (req, res) {
  // handle 404 Not Found Error in here
  // such as, showing a custom 404 page
});

// another way is using StatusCode
app.on(StatusCode.NOT_FOUND, (req, res) { });
app.on(StatusCode.INTERNAL_SERVER_ERROR, (req, res) { });
app.on(StatusCode.BAD_REQUEST, (req, res) { });
app.on(StatusCode.UNAUTHORIZED, (req, res) { });
app.on(StatusCode.PAYMENT_REQUIRED, (req, res) { });
app.on(StatusCode.FORBIDDEN, (req, res) { });
app.on(StatusCode.METHOD_NOT_ALLOWED, (req, res) { });
app.on(StatusCode.REQUEST_TIMEOUT, (req, res) { });
app.on(StatusCode.CONFLICT, (req, res) { });
app.on(StatusCode.UNPROCESSABLE_ENTITY, (req, res) { });
app.on(StatusCode.NOT_IMPLEMENTED, (req, res) { });
app.on(StatusCode.SERVICE_UNAVAILABLE, (req, res) { });
```

You may also trigger HTTP exceptions in the middleware or callback function.

```dart
app.get('/unauthorized', (Req req, Res res) async {
  throw UnauthorizedException();
});
```

Here is a complete list of all the HTTP exceptions that you can use in your application.

```dart
BadRequestException

UnauthorizedException

PaymentRequiredException

ForbiddenException

NotFoundException

MethodNotAllowedException

RequestTimeoutException

ConflictException

UnprocessableException

InternalErrorException

NotImplementedException

ServiceUnavailableException
```

## Parallel Processing

Parallel and multithread-ing is supported by default in Lucifer/Dart. 

You may do it by distributing the application processes evenly in various isolates.

```dart
import 'dart:async';
import 'dart:isolate';

import 'package:lucifer/lucifer.dart';

void main() async {
  // Start an app
  await startApp();

  // Spawn 10 new app with each own isolate
  for (int i = 0; i < 10; i++) {
    Isolate.spawn(spawnApp, null);
  }
}

void spawnApp(data) async {
  await startApp();
}

Future<App> startApp() async {
  final app = App();
  final port = env('PORT') ?? 3000;

  app.get('/', (Req req, Res res) async {
    await res.send('Hello Detective');
  });

  await app.listen(port);
  print('Server running at http://${app.host}:${app.port}');

  return app;
}
```

## Web Socket

Web socket is a necessary part of web application to initiate persistent communications between client and server. 

You may utilize web socket in your Lucifer application like so:

```dart
import 'dart:io';

import 'package:lucifer/lucifer.dart';

void main() async {
  final app = App();
  final port = env('PORT') ?? 3000;

  app.use(static('public'));

  app.get('/', (Req req, Res res) async {
    await res.sendFile('chat.html');
  });

  app.get('/ws', (Req req, Res res) async {
    List clients = [];

    final socket = app.socket(req, res);

    socket.on('open', (WebSocket client) {
      clients.add(client);
      for (var c in clients) {
        if (c != client) {
          c.send('New human has joined the chat');
        }
      }
    });
    socket.on('close', (WebSocket client) {
      clients.remove(client);
      for (var c in clients) {
        c.send('A human just left the chat');
      }
    });
    socket.on('message', (WebSocket client, message) {
      for (var c in clients) {
        if (c != client) {
          c.send(message);
        }
      }
    });
    socket.on('error', (WebSocket client, error) {
      res.log('$error');
    });
    
    await socket.listen();
  });

  await app.listen(port);
  print('Server running at http://${app.host}:${app.port}');
}
```

<!---

## Deployment

As there are many roads to Rome, there are many ways to deploy a lucifer application. 

You can upload the dart code to your own server, or to a VPS, or run `dart build` and upload the generated binary file. 

Or use cloud service like Heroku, and use its automatic build system to help the deployment.

Create a new Heroku app.

```bash
$ heroku create 

Creating secure-spire-84236... done, stack is cedar-14
http://secure-spire-84236.herokuapp.com/ ...
Git remote heroku added
```

This will generate a random name for your app, in this case `secure-spire-84236`

Commit the project and add heroku remote.

```bash
$ git init 
$ git add .
$ git commit -m "Initial commit"

$ heroku git:remote -a secure-spire-84236
```

Configure the buildpack.

Running the deploy command now (`git push heroku master`) will throw an exception since Heroku needs the correct buildpack for running Dart apps.

A buildpack contains scripts that set the necessary dependencies to build and serve a project. 

Heroku does not officially support Dart at present time. 

```bash
$ heroku buildpacks:set https://github.com/igrigorik/heroku-buildpack-dart.git
```

Set the required configurations needed by the buildpack:

```bash
$ heroku config:set DART_SDK_URL=https://storage.googleapis.com/dart-archive/channels/dev/release/2.0.0-dev.67.0/sdk/dartsdk-linux-x64-release.zip

$ heroku config:set DART_BUILD_CMD="/app/dart-sdk/bin/pub global activate webdev && /app/dart-sdk/bin/pub global run webdev build"
```

This tells the buildpack to pull the latest Dart SDK and build the project using the webdev tool.

Create a `Procfile` at the project root directory with instructions to start our server.

```text
web: ./dart-sdk/bin/dart bin/main.dart
```

Commit the changes and start deploying.

```bash
$ git push heroku master
```
-->

<!---
## REST API

This part will includes a simple tutorial to create a fully functioning REST API with Lucifer.
-->

<!---
## GraphQL

This part will includes a simple tutorial to create a fully functioning GraphQL with Lucifer.
-->

## Contributions

Feel free to contribute to the project in any ways. 

This includes code reviews, pull requests, documentations, tutorials, or reporting bugs that you might found in Lucifer.

## License 

MIT License

Copyright (c) 2021 Lucifer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.