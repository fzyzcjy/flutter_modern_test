# `flutter_modern_test`: Modern and elegant test framework for Flutter, inspired by [Cypress](https://www.cypress.io/)

Write down tests as if you are speaking English. *Only* express your business logic, and no more code is needed.

As we know, integration tests are fragile and easy to fail. Now, no need to manually write down `for (var i in range(3)) check_that_widget_is_visible();`, and `flutter_modern_test`'s strong retry-ability ([explanation](https://docs.cypress.io/guides/core-concepts/retry-ability)) will automatically retry and make it much more robust. 

```
tTestWidgets('test one', (t) async {
  // example: easy-to-read grammar
  await t.login('tom');
  await t.visit('/friends');
  // example: interactions
  await t.get(FriendMark.tabBarMenu).tap();
  await t.get('my_list_view').drag(Offset(0, 100));
  // example: assertions
  await t.routeName().shouldEquals('/create_chat');
  await t.get(find.text('My Title')).should(findsOneWidget);
});
```

Moreover, you get an UI with **a human-readable view** of what is happening.

In addition, test recording and **time travelling**: Look at screenshot of any previous step, to easily figure out what is happening (and what is going wrong)

Before I record video of `flutter_modern_test` (since I am not sure whether people are interested in this lib, I do not spend much time on writing readme), please watch this Cypress video to know what each feature above means...

<p align="center">
  <a href="https://player.vimeo.com/video/237527670">
    <img alt="" src="https://user-images.githubusercontent.com/1271364/31739717-dbdff0ee-b41c-11e7-9b16-bfa1b6ac1814.png" width="75%" height="75%" />
  </a>
</p>

## Status

I have used it internally for my app (in production) and it worked well. But to make it a great open-source project, work is still needed.

The current code repository lacks some trivial internal library dependencies, but of course I will port them here soon.

## Remarks

I have long wished Flutter could have a testing framework that is as productive as [Cypress](https://www.cypress.io/) in JavaScript, so I write one. So many thanks for Cypress, which gives the inspiration of this library!
