[![Build Status][build status badge]][build status]
[![License][license badge]][license]
[![Platforms][platforms badge]][platforms]
[![Documentation][documentation badge]][documentation]

# ConcurrencyPlus
Utilities for working with Swift Concurrency

This is a really small library with some type and extensions that may be useful when working with Swift's concurrency system.

- A `TaskQueue` for queuing tasks in FIFO ordering
- `CheckedContinuation` extensions for improved ergnomics
- `Task` extensions for improved ergnomics when used to bridge to non-async code
- `NSXPCConnection` extensions for safe async integration
- `MainActor.runUnsafely` to help work around incorrectly- or insufficently-annotated code not under your control
- `Async(Throwing)Subject` to make it easier to construct AsyncSequences from non-async code

## TaskQueue

```swift
let queue = TaskQueue()

queue.addOperation {
    await asyncFunction()
    await anotherAsyncFunction()
}

// This can can also return the underlying Task, so you can cancel, or await a value
let task = await queue.addOperation {
    return await makeValue()
}

let value = try await task.value
```

```swift
// Without .ordered, the execution order of these tasks is not well-defined.
Task.ordered {
    event1()
}

Task.ordered(priority: .background) {
    event2()
}

Task.ordered {
    event3()
}
```

## Async(Throwing)Subject

Very simple wrapper around `AsyncStream` that works a lot like a Combine `Subject`. Handy for forwarding events into an `AsyncSequence`.

```swift
let subject = AsyncSubject<Int>()

Task {
    subject.send(1)
    subject.send(1)
    subject.send(1)
}

for await value in subject {
    print("value: ", value)
}
```

## Suggestions or Feedback

We'd love to hear from you! Get in touch via [twitter](https://twitter.com/chimehq), an issue, or a pull request.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

[build status]: https://github.com/ChimeHQ/ConcurrencyPlus/actions
[build status badge]: https://github.com/ChimeHQ/ConcurrencyPlus/workflows/CI/badge.svg
[license]: https://opensource.org/licenses/BSD-3-Clause
[license badge]: https://img.shields.io/github/license/ChimeHQ/ConcurrencyPlus
[platforms]: https://swiftpackageindex.com/ChimeHQ/ConcurrencyPlus
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FChimeHQ%2FConcurrencyPlus%2Fbadge%3Ftype%3Dplatforms
[documentation]: https://swiftpackageindex.com/ChimeHQ/ConcurrencyPlus/main/documentation
[documentation badge]: https://img.shields.io/badge/Documentation-DocC-blue
