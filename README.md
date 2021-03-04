# TJBackgroundTask

This project is a wrapper around [`UIApplication`'s background task APIs](https://developer.apple.com/documentation/uikit/uiapplication/1623051-beginbackgroundtaskwithname?language=objc) that reduces boiler plate and helps avoid common pitfalls.

## What does this do for me?

This project class does the following handy things
- It automatically ends background tasks that are about to expire.
- It uses object lifecycles instead of background task IDs for managing tasks, which makes it harder to "leak" or mismanage tasks. Tasks are automatically ended when `TJBackgroundTask`s are deallocated.
- It avoids starting background tasks if < 5 seconds of background time remains, which is recommended in [this WWDC talk](https://developer.apple.com/videos/play/wwdc2020/10078/?t=640).

## Usage

```objc
TJBackgroundTask *const task = [[TJBackgroundTask alloc] initWithName:@"my async work"];
dispatch_async(..., ^{
    // Do some work
    // ...
    [task endTask];
});

// or, more simply

TJBackgroundTask *const task = [[TJBackgroundTask alloc] initWithName:@"my sync work"];
// Do some work
// ...
[task endTask];
```

Some notes:
- You can call `-endTask` any number of times, it'll do the right thing if you call it more than once.
- `TJBackgroundTask`'s initializers will return `nil` if the app is in a state it deems isn't eligible for background tasks.
- `TJBackgroundTask` can be used from any thread if you're into that sort of thing.