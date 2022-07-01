# ``ConcurrencyPlus``

Execute async tasks preserving the order in which they are scheduled by using an async task queues.

Run async tasks in order as simple as:

```swift
Task.ordered {
    event1()
}

Task.ordered(priority: .background) {
    event2()
}
```

## Topics

### Getting Started

- <doc:GettingStarted>

### Running async tasks

- ``TaskQueue``
- ``TaskQueue/addOperation(priority:operation:)-8lp35``
- ``TaskQueue/addOperation(priority:operation:)-4p67v``

### Cancelling continuation

- ``withCancellingContinutation(function:_:)``
- ``CancellingContinuation``
- ``CancellingContinuationError``
