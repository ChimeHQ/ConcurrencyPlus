[![Build Status][build status badge]][build status]
[![License][license badge]][license]
[![Platforms][platforms badge]][platforms]
[![Documentation][documentation badge]][documentation]

# ConcurrencyPlus
Utilities for working with Swift Concurrency

This is a really small library with some type and extensions that may be useful when working with Swift's concurrency system.

- A `TaskQueue` for queuing tasks in FIFO ordering
- `CheckedContinuation` extensions for improved ergonomics
- `Task` extensions for improved ergonomics when used to bridge to non-async code
- `NSXPCConnection` extensions for safe async integration
- `MainActor.runUnsafely` to help work around incorrectly- or insufficiently-annotated code not under your control

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

## Working with XPC

You might be tempted to make your XPC interface functions `async`. This approach does not handle connection failures and will violate the Structured Concurrency contract, resulting in hangs. See the post ["ExtensionKit and XPC"](https://www.chimehq.com/blog/extensionkit-xpc) for context.

This little `NSXPCConnection` extension provides a safe way to get into the async world.

```swift
func withContinuation<Service, T>(
    function: String = #function, 
    _ body: (Service, CheckedContinuation<T, Error>) -> Void
) async throws -> T
```

There are also some extensions on `CheckedContinuation` to make it easier to use in the context of XPC. These are really handy for resuming from common reply patterns.

Given an XPC service like this in your code:

```swift
protocol XPCService {
    func errorMethod(reply: (Error?) -> Void)
    func valueAndErrorMethod(reply: (String?, Error?) -> Void)
    func dataAndErrorMethod(reply: (Data?, Error?) -> Void)
}
```

The continuation helpers allow bridging like:

```swift
try await withContinuation { service, continuation in
    service.errorMethod(reply: continuation.resumingHandler)
}

try await withContinuation { service, continuation in
    service.valueAndErrorMethod(reply: continuation.resumingHandler)
}

// this one will try to use JSONDecoder on the resulting data
try await withContinuation { service, continuation in
    service.dataAndErrorMethod(reply: continuation.resumingHandler)
}
```

## Other Useful Projects

Right now, it's still quite difficult to make use of `AsyncSequence`. These libraries might be useful and are defintely worth checking out as well.

- [AnyAsyncSequence](https://github.com/vsanthanam/AnyAsyncSequence): super-focused on solving the lack type-erased sequences
- [AsyncAlgorithms](https://github.com/apple/swift-async-algorithms): Apple-owned reactive extensions to `AsyncSequence`
- [AsyncExtensions](https://github.com/sideeffect-io/AsyncExtensions): Companion to AsyncAlgorithms to add additional reactive features
- [Asynchrone](https://github.com/reddavis/Asynchrone): Extensions to bring reactive features to `AsyncSequence`

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
