# `flutter_modern_test`: Modern, elegant and productive test framework for Flutter, inspired by [Cypress](https://www.cypress.io/)

GitHub: https://github.com/fzyzcjy/flutter_modern_test

## Why?

Writing tests should be as easy as speaking to a human being about what is expected to happen. No extra care and code should be made for anything else.

## Features

* **Human-readable GUI for reviewing and debugging**: See the video below.
* **Test recording and time-traveling**: Look at screenshots of any step of the test. Easily figure out what is happening. Make debugging much easier (at least for me).
* **Robust with retry-ability**: Integration tests are fragile and easy to fail. Now, the retry-ability ([explanation in Cypress](https://docs.cypress.io/guides/core-concepts/retry-ability)) will automatically retry and make it much more robust. 
* **Planned: Other features that [Cypress](https://www.cypress.io/) has**: Take a look at their [website](https://www.cypress.io/).

## Video demo

Before I record video of `flutter_modern_test` (since I am not sure whether people are interested in this lib, I do not spend much time on writing readme), please watch this Cypress video and imagine the counterpart...

<p align="center">
  <a href="https://player.vimeo.com/video/237527670">
    <img alt="" src="https://user-images.githubusercontent.com/1271364/31739717-dbdff0ee-b41c-11e7-9b16-bfa1b6ac1814.png" width="75%" height="75%" />
  </a>
</p>
## Finding co-authors

I have long been wishing that Flutter could have a testing framework as productive as [Cypress](https://www.cypress.io/) in JavaScript; but with a long wait there is still none yet. So I write one (many thanks for Cypress's inspiration!).

Obviously, the rich features of Cypress itself are not made by one programmer. Even if I have made the core functionality for this library, there are still many features to add. If you are interested, please contact me (maybe via [GitHub issues](https://github.com/fzyzcjy/flutter_modern_test/issues))!

## Example

Code looks like:

```dart
tTestWidgets('test one', (t) async {
  // tap, drag, ... anything you like
  await t.get('load_data_button').tap();
  
  // With retry-ability, no need to wait for data to be loaded or retry.
  await t.get('My Title').should(findsOneWidget);
  
  // some other examples
  await t.logout();
  await t.routeName().shouldEquals('/create_chat');
});
```

UI looks like: (See that video above)

## Status

I have used it internally for my app (in production) and it worked well. But to make it a great open-source project, work is still needed.

The current code repository lacks some trivial internal library dependencies, but of course I will port them here soon.

