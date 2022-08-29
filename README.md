[![Build Status][build status badge]][build status]
[![License][license badge]][license]
[![Platforms][platforms badge]][platforms]

# ConcurrencyPlus
Utilities for working with Swift Concurrency

This is a really small library with some type and extensions that may be useful when working with Swift's concurrency system. For API details, see the [documentation](https://swiftpackageindex.com/ChimeHQ/ConcurrencyPlus/main/documentation/concurrencyplus).

## Types

### TaskQueue

Conceptually similar to a serial `DispatchQueue`, but can accept async blocks. Unlike with an unstructured `Task`, this makes it possible to control the ordering of events.

```swift
let queue = TaskQueue()

queue.addOperation {
    await asyncFunction()
    await anotherAsyncFunction()
}

// This can can also return the underlying Task,
// so you can cancel, or await a value
let task = await queue.addOperation {
    return await makeValue()
}

let value = try await task.value
```

`TaskQueue` also defines a single global queue, to enable this:

```swift
// Without .ordered, the execution order of these
// tasks is not well-defined.
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

### NSXPCConnection

You might be tempted to make your XPC interface functions `async`. This does not handle connection failures and can hang your `Task`s because it violates the Structured Concurrency contract, so it is unsafe. See the post ["ExtensionKit and XPC"](https://www.chimehq.com/blog/extensionkit-xpc) for context.

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

### Suggestions or Feedback

We'd love to hear from you! Get in touch via [twitter](https://twitter.com/chimehq), an issue, or a pull request.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

[build status]: https://github.com/ChimeHQ/ConcurrencyPlus/actions
[build status badge]: https://github.com/ChimeHQ/ConcurrencyPlus/workflows/CI/badge.svg
[license]: https://opensource.org/licenses/BSD-3-Clause
[license badge]: https://img.shields.io/github/license/ChimeHQ/ConcurrencyPlus
[platforms]: https://swiftpackageindex.com/ChimeHQ/ConcurrencyPlus
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FChimeHQ%2FConcurrencyPlus%2Fbadge%3Ftype%3Dplatforms
