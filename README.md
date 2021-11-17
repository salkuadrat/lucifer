# Lucifer Lightbringer

<img src="https://github.com/salkuadrat/lucifer/raw/master/lucifer.png" height="200" alt="Lucifer">

Lucifer is a fast, light-weight web framework in dart. 

It's built on top of native `HttpServer` to provide a simple way to fulfill the needs of many modern web server these days.

Lucifer is open, efficient, and has lots of built-in features to handle many kinds of things.

## Installation 

[Install Dart SDK](https://dart.dev/get-dart)

You can start create a new project using lucy command.

```shell
$ pub global activate lucy

$ lucy create desire
```

The first will activate lucifer command-line interface (CLI), named [Lucy](https://pub.dev/packages/lucy), to be accessible from your terminal. Then `lucy create desire` creates a new project named `desire` in the `desire` directory. 

Feel free to use any project name you want.

## Starting

Now we are ready to build our web server. 

Open file `main.dart` in your project `lib` directory and see the structure of a simple lucifer application.

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

Test running it with command.

```shell
$ cd desire

$ lucy run
```

Then open URL `http://localhost:3000` in your browser.

If all went well, it will display `Hello Detective` and print this message in your terminal.

```text
Server running at http://localhost:3000
```

## Fundamentals 

We can learn the basics of Lucifer by understanding the `lib/main.dart` code above.

Those short lines of code do several things behind the scene.

First, we import `lucifer` and create a web application by assigning a new `App` object to `app`

```dart
import 'package:lucifer/lucifer.dart';
```

```dart
final app = App();
```

Then we set the server port to `3000` from `.env` file that's located in your root project directory.

Feel free to change it with any port number you want.

```dart
final port = env('PORT') ?? 3000;
```

Once we have the `app`, we tell it to listen to GET request on path `/` with `app.get()`

```dart
app.get('/', (Req req, Res res) async {
  
});
```

Every HTTP verbs has its own methods in Lucifer: `get()`, `post()`, `put()`, `delete()`, `patch()` with the first argument corresponds to the route path.

```dart
app.get('/', (Req req, Res res) {

});

app.post('/', (Req req, Res res) {

});

app.put('/', (Req req, Res res) {

});

app.delete('/', (Req req, Res res) {

});

app.patch('/', (Req req, Res res) {

});
```

Next to it, we can see a callback function that will be called when an incoming request is processed, and send a response with it. 

To handle the incoming request and send a response, we can write our code inside.

```dart
app.get('/', (Req req, Res res) async {
  await res.send('Hello Detective');
});
```

Lucifer provides two objects, `req` and `res`, that represents `Req` and `Res` instance.

`Req` is an HTTP request built on top of native `HttpRequest`. It holds all information about the incoming request, such as request parameters, query string, headers, body, and much more.

`Res` is an HTTP response built on top of native `HttpResponse`. It's mostly used for manipulating response and sending it to the client.

What we did before is sending a message string `Hello Detective` to the client using `res.send()`. This method sets the string in the response body, and then close the connection.

The last line of our code starts the server and listen for incoming requests on the specified `port`

```dart
await app.listen(port);
print('Server running at http://${app.host}:${app.port}');
```

Alternatively, we can also use `app.listen()` as follows.

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

Environment is some set of variables known to a process (such as, ENV, PORT, etc). It's recommended to mimic production environment during development by reading it from `.env` file.

When we run `lucy create`, a `.env` file is created in the root project directory, containing these values.

```text
ENV = development
PORT = 3000
```

Then the value can be called from the dart code by using `env()` method.

```dart
void main() {
  final app = App();
  final port = env('PORT') ?? 3000; // get port from env

  // get ENV to check if it's in a development or production stage
  final environment = env('ENV'); 

  ...
}
```

For maximum security, we should use environment variables for important things, such as database configurations and JSON Web Token (JWT) secret.

One more thing... if you open `.gitignore` file in the root directory, you can see `.env` is included there. It means our `.env` file will not be uploaded to remote repository like github, and the values inside will never be exposed to public.

## Request Parameters 

A simple reference to all the request object properties and how to use them.

We've learned before that the `req` object holds the HTTP request informations. There are some properties of `req` that you will likely access in your application.

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

Now we'll see how to retrieve the GET query parameters. 

Query string is the part that comes after URL path, and starts with a question mark `?` like `?username=lucifer`.

Multiple query parameters can be added with character `&`.

```text
?username=lucifer&age=10000
```

How can we get those values?

Lucifer provides a `req.query` object to make it easy to get those query values.

```dart
app.get('/', (Req req, Res res) {
  print(req.query);
});
```

This object contains map of each query parameter.

If there are no query, it will be an empty map or `{}`.

We can easily iterate on it with for loop. This will print each query key and its value.

```dart
for (var key in req.query.keys) {
  var value = req.query[key];
  print('Query $key: $value');
}
```

Or you can access the value directly with `req.q()`

```dart
req.q('username'); // same as req.query['username']

req.q('age'); // same as req.query['age']
```

## POST Request Data

POST request data are sent by HTTP clients, such as from HTML form, or from a POST request using Postman or from JavaScript code.

How can we access these data?

If it's sent as json with `Content-Type: application/json`, we need to use `json()` middleware.

```dart
final app = App();

// use json middleware to parse json request body
// usually sent from REST API
app.use(json());
// use xssClean to clean the inputs
app.use(xssClean());
```

If it's sent as urlencoded `Content-Type: application/x-www-form-urlencoded`, use `urlencoded()` middleware.

```dart
final app = App();

// use urlencoded middleware to parse urlencoded request body
// usually sent from HTML form
app.use(urlencoded());
// use xssClean to clean the inputs
app.use(xssClean());
```

Now we can access the data from `req.body`

```dart
app.post('/login', (Req req, Res res) {
  final username = req.body['username'];
  final password = req.body['password'];
});
```

or simply use `req.data()`

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

To ensure the core framework stays lightweight, Lucifer will not assume anything about your request body. So you can choose and apply the appropriate parser as needed in your application.

However, if you want to be safe and need to be able to handle all forms of request body, simply use the `bodyParser()` middleware. 

```dart
final app = App();

app.use(bodyParser());
```

It will automatically detect the type of request body, and use the appropriate parser accordingly for each incoming request.

## Send Response 

In the example above, we've used `res.send()` to send a simple response to the client.

```dart
app.get('/', (Req req, Res res) async {
  await res.send('Hello Detective');
});
```

If you pass a string, lucifer will set `Content-Type` header to `text/html`.

If you pass a map or list object, it will set as `application/json`, and encode the data into JSON.

`res.send()` sets the correct `Content-Length` response header automatically.

`res.send()` also close the connection when it's all done.

You can use `res.end()` method to send an empty response without any content in the response body.

```dart
app.get('/', (Req req, Res res) async {
  await res.end();
});
```

Another thing is you can send the data directly without `res.send()`

```dart
app.get('/string', (req, res) => 'string');

app.get('/int', (req, res) => 25);

app.get('/double', (req, res) => 3.14);

app.get('/json', (req, res) => { 'name': 'lucifer' });

app.get('/list', (req, res) => ['Lucifer',  'Detective']);
```

## HTTP Status Response

You can set HTTP status response using `res.status()` method.

```dart
res.status(404).end();
```

or 

```dart
res.status(404).send('Not Found');
```

Or simply use `res.sendStatus()`

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

Besides `res.send()` method we've used before, we can use `res.json()` to send json data to the client. 

It accepts a map or list object, and automatically encode it into json string with `jsonEncode()`

```dart
res.json({ 'name': 'Lucifer', 'age': 10000 });
```

```dart
res.json(['Lucifer', 'Detective', 'Amenadiel']);
```

## Cookies 

Use `res.cookie()` to manage cookies in your application.

```dart
res.cookie('username', 'Lucifer');
```

This method accepts additional parameters with various options.

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

Here is some cookie parameters you can eat.

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

Or to clear all cookies.

```dart
res.clearCookies();
```

## Secure Cookies

You can secure cookies in your application using `secureCookie()` middleware.

```dart
String cookieSecret = env('COOKIE_SECRET_KEY');

app.use(secureCookie(cookieSecret));
```

`COOKIE_SECRET_KEY` needs to be set in the `.env` file and should be a random string unique to your application.

## HTTP Headers

We can get HTTP header of a request from `req.headers`

```dart
app.get('/', (req, res) {
  print(req.headers);
});
```

Or we use `req.get()` to get an individual header value.

```dart
app.get('/', (req, res) {
  final userAgent = req.get('User-Agent');

  // same as 

  req.header('User-Agent');
});
```

To change HTTP header of a response to the client, we can use `res.set()` and `res.header()`

```dart
res.set('Content-Type', 'text/html');

// same as 

res.header('Content-Type', 'text/html');
```

There are other ways to handle the Content-Type header.

```dart
res.type('.html'); // res.set('Content-Type', 'text/html');

res.type('html'); // res.set('Content-Type', 'text/html');

res.type('json'); // res.set('Content-Type', 'application/json');

res.type('application/json'); // res.set('Content-Type', 'application/json');

res.type('png'); // res.set('Content-Type', 'image/png');
```

## Redirects

Using redirects are common thing to do in a web application. You can redirect a response in your application with `res.redirect()` or `res.to()`

```dart
res.redirect('/get-over-here');

// same as 

res.to('/get-over-here');
```

This will create redirect with a default 302 status code.

We can also use it this way.

```dart
res.redirect(301, '/get-over-here');

// same as 

res.to(301, '/get-over-here');
```

You can pass the path with an absolute path (`/get-over-here`), an absolute URL (`https://scorpio.com/get-over-here`), a relative path (`get-over-here`), or `..` to go back one level.

```dart
res.redirect('../get-over-here');

res.redirect('..');
```

Or simply use `res.back()` to redirect back to the previous url based on the HTTP Referer value sent by client in the request header (defaults to / if not set).

```dart
res.back();
```

## Routing 

Routing is the process of determining what should happen when a URL is called, and which parts of the application needs to handle the request.

In the example before we've used.

```dart
app.get('/', (req, res) async {

});
```

This creates a route that maps root path `/` with HTTP GET method to the response we provide inside the callback function.

We can use named parameters to listen for custom request. 

Say we want to provide a profile API that accepts a string as username, and return the user details. We want the string parameter to be part of the URL (not as query string). 

So we use named parameters like this.

```dart
app.get('/profile/:username', (Req req, Res res) {
  // get username from URL parameter
  final username = req.params['username'];

  print(username);
});
```

You can use multiple parameters in the same URL, and it will automatically added to `req.params` values.

As an alternative, you can use `req.param()` to access an individual value of `req.params`

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

We can use `Router` object from `app.router()` to build an organized routing.

```dart
final app = App();
final router = app.router();

router.get('/login', (req, res) async {
  await res.send('Login Page');
});

app.use('/auth', router);
```

Now the login page will be available at http://localhost:3000/auth/login.

You can register more than one routers in your app.

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

Using `app.router()` is a good practice to organize your endpoints. You can split them into independent files to maintain a clean, structured and easy-to-read code.

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

With this `app.route()` you can also use `Controller`. This is especially useful when you're building a REST API.

Lets create a new controller in the `controller` directory.

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

Then use it in your main app like this.

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

It's good practice to split your routes into its own independent controllers.

Also, feel free to add more methods to your `Controller`

```dart
class UserController extends Controller {

  ...

  FutureOr vip(Req req, Res res) async {
    await res.send('List of VIP Users');
  }
}
```

Then apply the method by chaining `app.route()`

```dart
final app = App();
final user = UserController(app);

// this will add route GET /user/vip into your app
// along with all the standard routes above
app.route('/user', user).get('/vip', user.vip);
```

To help you with adding `Controller` to your project, Lucifer provides another command like this.

```shell
$ lucy c post
```

These command will create a `post_controller.dart` file in the `/bin/controller` directory, and automatically fill it with a boilerplate `PostController` class.

You can use it to create more than one `Controller` like this.

```shell
$ lucy c post news user customer
```

## Static Files

It's common to have images, css, and javascripts in a public folder, and expose them.

You can do it by using `static()` middleware.

```dart
final app = App();

app.use(static('public'));
```

Now if you have `index.html` file in the `public` directory, it will be served automatically when you hit `http://localhost:3000`.

## Sending Files

Lucifer provides a simple way to send file as an attachment to the client with `res.download()`

When user hit a route that sends file with this method, browsers will prompt the user for download. Instead of showing it in a browser, it will be saved into local disk.

```dart
app.get('/downloadfile', (Req req, Res res) async {
  await res.download('thefile.pdf');

  // same as

  await res.sendFile('thefile.pdf');
});
```

You can send a file with a custom filename.

```dart
app.get('/downloadfile', (Req req, Res res) async {
  await res.download('thefile.pdf', 'File.pdf');
});
```

And to handle the error when sending file, use this.

```dart
app.get('/downloadfile', (Req req, Res res) async {
  final err = await res.download('./thefile.pdf', 'File.pdf');

  if (err != null) {
    // handle error
  }
});
```

## CORS 

A client app running in the browser usually can access only the resources from the same domain (origin) as the server.

Loading images or scripts/styles usually works, but XHR and Fetch calls to another server will fail, unless the server implements a way to allow that connection.

That way is CORS (Cross-Origin Resource Sharing).

Loading web fonts using `@font-face` also has same-origin-policy by default, and also other less popular things (like WebGL textures).

If you don't set up a CORS policy that allows 3rd party origins, their requests will fail.

A cross origin request fail if it's sent

- to a different domain 
- to a different subdomain
- to a different port
- to a different protocol

and it's there for your own security, to prevent any malicious users from exploiting your resources.

But if you control both the server and the client, you have good reasons to allow them to talk with each other.

Use `cors` middleware to set up the CORS policy.

As example, lets say you have a simple route without cors.

```dart
final app = App();

app.get('/no-cors', (Req req, Res res) async {
  await res.send('Risky without CORS');
});
```

If you hit `/no-cors` using fetch request from a different origin, it will raise a CORS issue.

All you need to make it work is using the built in `cors` middleware and pass it to the request handler.

```dart
final app = App();

app.get('/yes-cors', cors(), (Req req, Res res) async {
  await res.send('Now it works');
});
```

You can apply `cors` for all incoming requests by using `app.use()`

```dart
final app = App();

app.use(cors());

app.get('/', (Req req, Res res) async {
  await res.send('Now all routes will use cors');
});
```

By default, cors will set cross-origin header to accept any incoming requests. You can change it to only allow one origin and block all the others.

```dart
final app = App();

app.use(cors(
  origin: 'https://luciferinheaven.com'
));

app.get('/', (Req req, Res res) async {
  await res.send('Now all routes can only accept request from https://luciferinheaven.com');
});
```

You can also set it up to allow multiple origins.

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

We need to use sessions to identify client across many requests.

By default, web requests are stateless, sequential and two requests can't be linked to each other. There is no way to know if a request comes from a client that has already performed another request before.

Users can't be identified unless we use some kind of magic that makes it possible.

This is what sessions are (JSON Web Token is another).

When handled correctly, each user of your application or your API will be assigned to a unique session ID, and it allows you to store the user state.

We can use built in `session` middleware in lucifer.

```dart
final app = App();

app.use(session(secret: 'super-s3cr3t-key'));
```

And now all requests in your app will use session.

`secret` is the only required parameter, but there are many more you can use. `secret` should use a random string, unique to your application. Or use a generated string from [randomkeygen](https://randomkeygen.com/).

This session is now active and attached to the request. And you can access it from `req.session()`

```dart
app.get('/', (Req req, Res res) {
  print(req.session()); // print all session values
});
```

To get a specific value from the session, you can use `req.session(name)`

```dart
final username = req.session('username');
```

Or use `req.session(name, value)` to add (or replace) value in the session.

```dart
final username = 'lucifer';

req.session('username', username);
```

Sessions can be used to to communicate data between middlewares, or to retrieve it later on the next request.

Where do we store this session?

Well, it depends on the set up that we use for our sessions.

It can be stored in

- memory: this is the default, but don't use it in production
- database: like Postgres, SQLite, MySQL or MongoDB
- memory cache: like Redis or Memcached

All the session store above will only set session ID in a cookie, and keep the real data server-side. 

Clients will receive this session id, and send it back with each of their next HTTP requests. Then the server can use it to get the store data associated with these session.

Memory is the default setting for session, it's pretty simple and requires zero setup on your part. However, it's not recommended for production.

The most efficient is using memory cache like Redis, but it needs some more efforts on your part to set up the infrastructure.

## JSON Web Token

JSON Web Token (JWT) is an open standard (RFC 7519) that defines a compact and self-contained way for securely transmitting information between parties as a JSON object. 

This information can be verified and trusted because it is digitally signed. JWTs can be signed using a secret (with the HMAC algorithm) or a public/private key pair using RSA or ECDSA.

You can use JWT feature in Lucifer by using an instance of `Jwt`  to sign and verify token. Remember to put the jwt secret in environment variables.

```dart
final app = App();
final port = env('PORT') ?? 3000;

final jwt = Jwt();
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

Use `jwt.verify()` to verify the token.

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

Middleware is function that hooks into the routing process. It performs some operations before executing the route callback handler.

Middleware is usually to edit the request or response object, or terminate the request before it reach the route callback.

You can add middleware like this.

```dart
app.use((Req req, Res res) async {
  // do something
});
```

This is a bit similar as defining the route callback.

Most of the time, you'll be enough by using built in middlewares provided by Lucifer, like the `static`, `cors`, `session` that we've used before. 

But if you need it, you can easily create your own middleware, and use it for a specific route by putting it in the middle between route and callback handler.

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

You can apply multiple middlewares to any route you want.

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

If you want to save data in a middleware and access it from the next middlewares or from the route callback, use `res.local()` 

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

There is no `next()` to call in these middleware (unlike other framework like Express). 

Processing next is handled automatically by lucifer. 

A lucifer app will always run to the next middleware or callback in the current processing stack... 

Unless, you send some response to the client in the middleware, which will close the connection and automatically stop all executions of the next middlewares/callback.

Since these call is automatic, you need to remember to use a proper  `async` `await` when calling asynchronous functions.

As example, when using `res.download()` to send file to the client.

```dart
app.get('/download', (Req req, Res res) async {
  await res.download('somefile.pdf');
});
```

One simple rule to follow: if you call a function that returns `Future` or `FutureOr`, play safe and use `async` `await`.

If in the middle of testing your application, you see an error in the console with some message like `HTTP headers not mutable` or `headers already sent`, it's an indicator that some parts of your application need to use proper `async await`

## Forms

Now lets learn to process forms with Lucifer.

Say we have an HTML form:

```html
<form method="POST" action="/login">
  <input type="text" name="username" />
  <input type="password" name="password" />
  <input type="submit" value="Login" />
</form>
```

When user press the submit button, browser will automatically make a POST request to `/login` in the same origin of the page, and with it sending some data to the server, encoded as `application/x-www-form-urlencoded`. 

In this case, the data contains `username` and `password` 

Form also can send data with GET, but mostly it will use the standard  & safe POST method.

These data will be attached in the request body. To extract it, you can use the built in `urlencoded` middleware.

```dart
final app = App();

app.use(urlencoded());
// always use xssClean to clean the inputs
app.use(xssClean());
```

We can test create a POST endpoint for `/login`, and the submitted data will be available from `req.body`

```dart
app.post('/login', (Req req, Res res) async {
  final username = req.body['username']; // same as req.data('username');
  final password = req.body['password']; // same as req.data('password');

  ...

  await res.end();
});
```

<!---

Now lets see how to validate and sanitize these data by using `check` middleware.

## Input Validation

Say we have a POST endpoint that accepts name, email and age.

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

The easy way to do this is using the `check` middleware.

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

You can also validate the input with regular expression by using `matches()`.

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

One sensible rule to follow when you run a public server: never trust any input from any user.

Even if you have sanitized and make sure people can't enter weird things from client side, you would still be open to people with tools (such as Chrome devtools or Postman) send a POST request directly to your server.

Or some bots trying some clever ways to find a hole in your ship.

The thing we should do is sanitize these inputs.

We can use `check` middleware like before to perform this sanitization.

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

Now you can piping some sanitize methods after the validation.

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

Like validators, you can also create a custom sanitizer.

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

Learn to handle uploading file(s) via forms.

Lets say you have an HTML form that allows user to upload file.

```html
<form method="POST" action="/upload">
  <input type="file" name="document" />
  <input type="submit" value="Upload" />
</form>
```

When user press the submit button, browser will automatically send a POST request to `/upload` in the same origin, and sending file from the input file. 

It's not sent as `application/x-www-form-urlencoded` like the usual standard form, but `multipart/form-data`

Handling multipart data manually can be tricky and error prone, so we will use a built in `FormParser` utility that you can access with `app.form()`

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

You can use it per event that will be notified when each file is processed. This also notify other events, like on processing end, on receiving other non-file field, or when an error happened.

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

Or use it like this.

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

Either way, you get one or more `UploadedFile` objects, which will give you information about the uploaded files. These are some value you can use.

- `file.name`: to get the name from input file
- `file.filename`: to get the filename 
- `file.type`: to get the MIME type of the file
- `file.data`: to get raw byte data of the uploaded file

By default, `FormParser` only include the raw bytes data and not save it into any temporary folder. You can easily handle this yourself like this.

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

Lucifer provides default templating with `Mustache` engine. It uses a package [`mustache_template`](https://pub.dev/packages/mustache_template) that's implemented from the [official mustache spec](https://mustache.github.io/).

By default, to keep the core framework light-weight, lucifer doesn't attach any template engine to your app. To use the `mustache` middleware, you need to apply it first.

```dart
final app = App();

app.use(mustache());
```

Then these `mustache` can render any template you have in the project `views` directory.

Say you have this `index.html` in the `views` directory.

```html
<!DOCTYPE html>
<html>
  <head></head>
  <body>
    <h2>{{ title }}</h2>
  </body>
</html>
```

And render the template with `res.render()`

```dart
final app = App();

app.use(mustache());

app.get('/', (Req req, Res res) async {
  await res.render('index', { 'title': 'Hello Detective' });
});
```

If you run command `lucy run` and open http://localhost:3000 in the browser, it'll shows an html page displaying `Hello Detective`

You can change the default `views` with other directory you want.

```dart
final app = App();

// now use 'template' as the views directory
app.use(mustache('template'));

app.get('/', (Req req, Res res) async {
  // can also use res.view()
  await res.view('index', { 'title': 'Hello Detective' });
});
```

Now if you add this `index.html` file to the `template` directory.

```html
<!DOCTYPE html>
<html>
  <head></head>
  <body>
    <h2>{{ title }} from template</h2>
  </body>
</html>
```

Then run the app and open it in the browser, it will shows another html page containing `Hello Detective from template`

For more complete details to use `Mustache` template engine, you can read the [mustache manual](https://mustache.github.io/mustache.5.html).

To use other engines, such as [jinja](https://pub.dev/packages/jinja) or [jaded](https://pub.dev/packages/jaded), you can manage the template rendering yourself, and then send the html by calling `res.send()`

```dart
app.get('/', (Req req, Res res) async {
  // render your jinja/jaded template into 'html' variable
  // then send it to the client
  await res.send(html);
});
```

Or you can create a custom middleware to handle templating with your chosen engine.

Here is example you can learn from the `mustache` middleware to create your own custom templating.

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
        // mostly, all you need to do is edit these two lines 
        // 
        Template template = Template(await file.readAsString());
        String html = template.renderString(data);

        // 
        // in the end, always send the rendered html
        //
        await res.send(html);
      }
    };
  };
}
```

To apply the new templating middleware, use `app.use()` like before.

```dart
final app = App();

app.use(customTemplating());
```

## Security

Lucifer has a built in `security` middleware that covers dozens of standard security protections to guard your application. To use them, simply add it to your app with `app.use()`

```dart
final app = App();

app.use(security());
```

[Read here](https://infosec.mozilla.org/guidelines/web_security.html) to learn more about web security.

## Error Handling

Lucifer automatically handle the errors that occured in your application. However, you can set your own error handling with `app.on()`

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

You can trigger HTTP exceptions from middleware or callback function.

```dart
app.get('/unauthorized', (Req req, Res res) async {
  throw UnauthorizedException();
});
```

Here is the list of all default exceptions we can use.

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

Parallel and multithread-ing is supported by default with Dart/Lucifer. It can be done by distributing the processes evenly in various isolates.

Here is one way to do it.

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

Web socket is a necessary part of web application if you need persistent communications between client and server. Here is an example to use web socket with Lucifer.

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

Feel free to contribute to the project in any ways. This includes code reviews, pull requests, documentations, tutorials, or reporting bugs that you found in Lucifer.

## License 

MIT License

Copyright (c) 2021 Lucifer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.