# Working With XPC

XPC-specific features to help integrate Swift Concurrency.

## Overview

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
