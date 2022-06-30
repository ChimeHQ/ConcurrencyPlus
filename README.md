[![License][license badge]][license]
[![Platforms][platforms badge]][platforms]

# ConcurrencyPlus
Utilities for working with Swift Concurrency

## Types

### TaskQueue

Conceptually similar to a serial `DispatchQueue`, but can accept async blocks. Unlike with an unstructured `Task`, this makes it possible to control the ordering of events.

> **Note**
> A queue of tasks like this introduces the possibility of priority inversions. To help avoid this, you can only set a priority on a per-queue basis, not per-operation.

```swift
let queue = TaskQueue()

queue.addOperation {
    await asyncFunction()
    await anotherAsyncFunction()
}

// Can also run an operation that will return a value once executed. Neat!
let value = await queue.addResultOperation {
    return await makeValue()
}
```

`TaskQueue` also defines a single global queue, to enable this:

```swift
// Without .ordered, the execution order of these tasks is not well-defined.
Task.ordered {
    event1()
}

Task.ordered {
    event2()
}

Task.ordered {
    event3()
}
```

### CancellingContinuation

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
[platforms]: https://swiftpackageindex.com/ChimeHQ/ConcurrencyPlus
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FChimeHQ%2FConcurrencyPlus%2Fbadge%3Ftype%3Dplatforms
