# :warning: This project is transfered to [`chromite`](https://github.com/otiai10/chromite) and [`jstorm`](https://github.com/otiai10/jstorm) :warning:

* Chrome Messaging Kit (`Router`, `Client`) => [`chromite`](https://github.com/otiai10/chromite)
* Chrome Storage (and LocalStorage) ORM => [`jstorm`](https://github.com/otiai10/jstorm) 

--------------

chomex
========

[![Latest Stable Version](https://img.shields.io/npm/v/chomex.svg)](https://www.npmjs.com/package/chomex)
[![NPM Downloads](https://img.shields.io/npm/dt/chomex.svg)](https://www.npmjs.com/package/chomex)
[![Node.js CI](https://github.com/otiai10/chomex/workflows/Node.js%20CI/badge.svg)](https://github.com/otiai10/chomex/actions?query=workflow%3A%22Node.js+CI%22)
[![codecov](https://codecov.io/gh/otiai10/chomex/branch/main/graph/badge.svg?token=n6lt67hpyd)](https://codecov.io/gh/otiai10/chomex)

Chrome Extension Messaging Routing Kit.

- [Router](https://github.com/otiai10/chomex/tree/master/src/Router/README.md) to handle `onMessage` with routes expression
- [Client](https://github.com/otiai10/chomex/tree/master/src/Client/README.md) to Promisify `sendMessage`
- [Model](https://github.com/otiai10/chomex/tree/master/src/Model/README.md) to access to `localStorage` like `ActiveRecord`
- [Types](https://github.com/otiai10/chomex/tree/master/src/Model/Types/README.md) to define data schema of `Model`

# Installation

```sh
npm install chomex
```

# Why?

## `.onMessage` like a server routing

:-1: Dispatching message inside `addListener` function makes my code messy and unreeadable.

```javascript
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  switch(message.action) {
  case "/users/get":
    GetUser.apply(sender, [message, sendResponse]);
    break;
  default:
    NotFound.apply(sender, [message, sendResponse]);
  }
  return true;
});
```

:+1: `chomex.Router` makes it more claen and readable.

```javascript
const router = new chomex.Router();
router.on("/users/get", GetUser);
chrome.runtime.onMessage.addListener(router.listener());
```

_Happy_ :hugs:

## `.sendMessage` like a fetch client

:-1: Handling the response of `sendMessage` by callback makes my code messy and unreadable.

```js
chrome.runtime.sendMessage({action:"/users/get",id:123}, (response) => {
  if (response.status == 200) {
    alert("User: " + response.user.name);
  } else {
    console.log("Error:", response);
  }
});
```

:+1: `chomex.Client` makes it clean and readable by handling response with `Promise`.

```js
const client = new chomex.Client(chrome.runtime);
const response = await client.message("/users/get", {id:123});
alert("User: " + response.data.user.name);
```

_Happy_ :hugs:

# Examples

> NOTE: These examples are using async/await on top-level. I believe you are familiar with asyc/await.

## `background.js` as a server

```javascript
import {Router, Model, Types} from 'chomex';

// Define your model
class User extends Model {
  static schema = {
    name: Types.string.isRequired,
    age:  Types.number,
  }
}

const router = new Router();

// Define your routes
router.on("/users/create", message => {
  const obj = message.user;
  const user = User.new(obj).save();
  return user;
});

router.on("/users/get", message => {
  const userId = message.id;
  const user = User.find(userId);
  if (!user) {
    return {status:404,error:"not found"};
  }
  // You can also return async Promise
  return Promise.resolve(user);
});

// Of course, you can separate files
// in which controller functions are defined.
import {UserDelete} from "./Controllers/Users";
router.on("/users/delete", UserDelete);

// Don't forget to add listener to chrome modules.
chrome.runtime.onMessage.addListener(router.listener());
```

## `content_script.js` as a client

```javascript
import {Client} from 'chomex';

const client = new Client(chrome.runtime);

// it sends message to "/users/get" route.
const user = {name: 'otiai10', age: 30};
const response = await client.message('/users/create', {user});
console.log("Created!", response.data);

const {data: user} = await client.message('/users/get', {id: 12345});
console.log("Found:", res.data);
```

# Customize `Router` for other listeners

You can also customize resolver for routing.
It's helpful when you want to make routings for EventListener modules on `chrome`, such as `chrome.notifications.onClicked`, `chrome.webRequest.onBeforeRequest` or so.

```javascript
// Resolver rule, which resolve given "id" to routing name.
const resolve = (id) => {
  const prefix = id.split(".")[0];
  return {name: prefix};
};

const router = new Router(resolve);
// You see, this controller is invoked when
// a notification with ID "quest.xxxx" is clicked.
router.on('quest', NotificaionOnClickController.Quest);

chrome.notifications.onClicked.addListener(router.listener());
```

# For more information

- [Router](https://github.com/otiai10/chomex/tree/master/src/Router/README.md)
- [Client](https://github.com/otiai10/chomex/tree/master/src/Client/README.md)
- [Model](https://github.com/otiai10/chomex/tree/master/src/Model/README.md)
- [Types](https://github.com/otiai10/chomex/tree/master/src/Model/Types/README.md)

# Reference Projects

Projects using `chomex`

- [otiai10/kanColleWidget: `Route` / `Controller`](https://github.com/otiai10/kanColleWidget/blob/master/src/js/Application/Routes/MessageRoutes.js)
- [otiai10/chant: `Model`](https://github.com/otiai10/chant/blob/master/client/src/js/models/index.js)
- [henry40408/awesome-stars: `Router` with `async/await`](https://github.com/henry40408/awesome-stars/blob/6417543a998d9bfb5504c60dc35fe38d04a9b694/app/scripts/background/messageRouter.js#L25-L33)
