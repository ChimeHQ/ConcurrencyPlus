# ``ConcurrencyPlus``

Utilities for working with Swift Concurrency.

## Overview

ConcurrencyPlus includes a number of types and extensions that are helpful when working with Swift Concurrency.

- A ``TaskQueue`` for queuing tasks in FIFO ordering
- `CheckedContinuation` extensions for improved ergnomics
- `Task` extensions for improved ergnomics when used to bridge to non-async code
- `NSXPCConnection` extensions for safe async integration
- `MainActor.runUnsafely` to help work around incorrectly- or insufficently-annotated code not under your control

## Topics

### Working with Tasks

- ``TaskQueue``

### XPC and Continuations

- <doc:Working-With-XPC>
