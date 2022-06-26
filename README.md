[![License][license badge]][license]

# ConcurrencyPlus
Utilities for working with Swift Concurrency

## TaskQueue

Conceptually similar to a serial `DispatchQueue`, but can accept async blocks. Unlike with an unstructured `Task`, this makes it possible to control the ordering of events. `TaskQueue` may need to boost priorities to avoid priority inversions.

```swift
let queue = TaskQueue()

queue.addOperation {
    await asyncFunction()
    await anotherAsyncFunction()
}
```

```swift
// These are garanteed to execute in the order they were submitted.
Task.ordered(priority: .background) {
    event1()
}

Task.ordered {
    event2()
}

Task.ordered {
    event3()
}
```

## CancellingContinuation

Just like a `CheckedContinuation`, but will automatically resume by throwing if it is deallocated without being resumed manually. This is useful for situations where you cannot guarantee that a closure will be called. An example of such a situation is an XPC call.

```swift
try await withCancellingContinutation({ continuation in
    funcThatMightNotInvokeItsCallback(completionHandler: { in
        continuation.resume()
    })
})
```

### Suggestions or Feedback

We'd love to hear from you! Get in touch via [twitter](https://twitter.com/chimehq), an issue, or a pull request.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

[license]: https://opensource.org/licenses/BSD-3-Clause
[license badge]: https://img.shields.io/github/license/ChimeHQ/ConcurrencyPlus
