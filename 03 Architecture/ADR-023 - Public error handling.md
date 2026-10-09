# ADR-023: Public error handling

- **Status:** Accepted
- **Date:** 2026-10 (Accepted 2026-10-09)
- **Deciders:** Miguel (Lead Engineer)
- **Task:** S7-D3 ([[2026-09 Sprint 07 - Scene Events and Input Boundary]])
- **Amended 2026-10-09, decision:** §6 "No speculative migration … Each moves to §2 when it is
  touched for another reason" → the existing shapes migrate now, in S7-D3's own sweep. Miguel
  chose to pay the migration once instead of living with two styles. Two scope calls came with
  it: the editor's `ProjectResult` migrates too, although §4 names only modules; and Scene's and
  `Transform`'s `bool` mutators stay `bool`, because one `false` there covers several reasons
  that no artifact has classified yet. S7-D3.
- **Related:** [[ADR-006 - v2 core architecture & module layout]] §3 ·
  [[ADR-011 - Diagnostics (Logger & Assert)]] §5 §10 ·
  [[ADR-005 - v2 tech stack & toolchain]] · [[Assert - Design]] · [[File Access - Design]] ·
  [[Serialization - Design]] · [[Logger - Design]]

## Context

`CONVENTIONS.md`'s *Open* table has carried an undecided Error handling row ("exceptions vs
`std::expected` vs error codes") since July. The row's trigger fired twice without a decision:
`addLogSink` returns a bare `bool`, and `Reader` carries a sticky `ReadStatus`. The row also
owns the revisit of the `[[nodiscard]]` ban for fallible APIs.

While the row stayed open, the engine grew five failure shapes in its public headers. All
evidence is from engine `371dbd9a`:

| Shape | Example |
|---|---|
| Per-module status enum, data through an out-param | `FileResult`, `engine/platform/include/TechEngine/platform/files/FileResult.hpp:6` |
| Sticky status on a stateful reader | `ReadStatus`, `engine/core/include/TechEngine/core/serialization/Reader.hpp:15` |
| A `bool` that means "did it work" | `addLogSink`, `engine/base/src/diagnostics/Log.cpp:148`; Scene mutators, `engine/core/include/TechEngine/core/scene/Scene.hpp:162` |
| A status plus a `std::exception_ptr` | `engine/core/include/TechEngine/core/jobs/DedicatedThread.hpp:21` |
| Exceptions: thrown by apps, or caught in `core` to roll back and rethrow | `apps/runtime/src/RuntimeApp.cpp:30`; `engine/core/src/scene/Archetype.cpp:49` |

There is no common type, so a layer that passes a failure upward must translate it into its
own enum or lose it. `addLogSink`'s `false` also mixes a programmer error (a null sink) with a
runtime limit (a full table), which the assert rules already keep apart.

Two constraints shape the options. First, the project builds as C++20 (`CMakeLists.txt:18`),
and every module publishes `cxx_std_20` (`cmake/techengine_module.cmake:45`). `std::expected`
exists only from C++23 in MSVC's STL, libstdc++ and libc++. ADR-005's allowance for C++23
library features "where MSVC ships them" therefore does not reach it. Second, `std::error_code`
is already in use: `FileAccess.cpp` receives one from every `std::filesystem` call.

## Decision

### 1. Three lanes, each with one shape

| What went wrong | How it is reported |
|---|---|
| A programmer error, impossible if the code is correct | An assert tier, unchanged (ADR-011 §5) |
| An expected runtime failure: a missing file, malformed bytes, a full table | A `std::error_code` |
| An unrecoverable failure: allocation, a third-party throw, a thread that died | An exception |

An absent value that is not a failure is reported as a `bool` plus an out-param, the same data
shape as §2. `std::optional` does not appear in a function signature; a private member may
still use it for late construction (`CONVENTIONS.md`). A query that answers a question, such as
`Scene::contains`, stays `bool`.

### 2. Expected failures return `std::error_code`

- Each module that reports failures owns one error enum and one `std::error_category`. The
  enum's values start at **1**, and there is no `Ok` value.
- Success is `return {};`. A caller tests `if (error)` and compares against a module's code
  with `error == FileError::NotFound`.
- Data comes back as it does today: through an out-param, or through a sticky error on a
  stateful object such as `Reader`.
- An OS or `std::filesystem` error is **mapped** to the module's own code where it is
  received. The module's enum is its whole contract, and the OS detail goes to the log at the
  point of mapping.
- A layer that cannot act on a failure returns the `std::error_code` unchanged. It does not
  translate it.

### 3. Exceptions carry only the unrecoverable

No public API throws to report an expected failure. In `core`, a `catch` exists only to roll
back a half-finished change and rethrow. Thread and App boundaries catch at their top level and
hand the failure to their owner as a `std::exception_ptr` (ADR-018 §3's cross-thread report).

### 4. Scope

This ADR covers the public headers of every module (ADR-006 §3 tier 1). The script SDK
(tier 2) is deferred to the scripting ADR, as ADR-011 §10 does for diagnostics.

### 5. `[[nodiscard]]` stays banned

The ban in `CONVENTIONS.md` § *Attributes* keeps no exception for fallible APIs. A discarded
`std::error_code` is caught by review only, which is the cost that section already accepts.

### 6. No speculative migration

> **Amended 2026-10-09:** superseded by the header entry. The shapes below migrate in S7-D3's
> sweep, except Scene's and `Transform`'s `bool` mutators. So the *two styles side by side*
> cost in *Consequences* now applies to those mutators only.

`FileResult`, `ReadStatus`, the `bool` mutators and `addLogSink` keep their current shape. Each
moves to §2 when it is touched for another reason. New public fallible APIs follow §2 from the
start.

The mechanism (the category class, where each hook must live, the worked example and the
caller style) belongs in `CONVENTIONS.md` § *Error handling*, which replaces the *Open* row.

## Consequences

- **Benefit:** One error type crosses every module. A failure can travel up through layers
  that do not understand it, and a caller can test for codes from two modules in one place.
- **Benefit:** `std::expected<T, std::error_code>` uses this exact error type, so a later move
  to C++23 is an upgrade for value-returning APIs, not a rewrite of the error codes.
- **Benefit:** The lanes match code that already exists. File access and the thread boundary
  already behave this way, so nothing working is rewritten.
- **Cost:** About 20 lines of category code per module. Three placements must be exact, or the
  enum stops converting with no error: `make_error_code` in the enum's namespace, the
  `std::is_error_code_enum` specialization in the header, and one category instance.
- **Cost:** `message()` returns a `std::string` and allocates. It belongs on the failure path,
  never on a hot path. `std::format` has no formatter for `std::error_code` in C++20, so a log
  line calls `.message()`.
- **Cost:** Two styles live side by side until the old shapes are touched. A reader meets
  `FileResult` and `std::error_code` in the same module for a while.
- **Risk:** Nothing flags an ignored error, because `[[nodiscard]]` stays banned.
- **Revisit when:**
  - The toolchain moves to C++23 for any reason. Adopt `std::expected<T, std::error_code>`
    for value-returning fallible APIs.
  - A public API must return a value and several failure reasons, and an out-param is awkward
    there. Resource loading that returns handles is the likely first case.
  - A copy-pasted category causes a real bug. Add a helper template for the category, not a
    macro.
  - The scripting ADR decides the SDK's error surface.

## Alternatives considered

| Option | For it | Why not |
|---|---|---|
| Exceptions for every failure | One channel; no out-params; a constructor can fail. | Nothing at the call site shows that a call can fail, and a missing file is normal game flow, not an exceptional event. [[File Access - Design]] already chose no exceptions. |
| Per-module status enums only | No new machinery; already shipped (`FileResult`). | No common type, so each layer translates or widens its own enum. Each enum needs its own message function. |
| `std::expected` everywhere | Value and error in one return. | Needs a C++23 move on every leg, and `cxx_std_20` is PUBLIC, so the SDK moves too. `Reader`'s sticky status does not fit a per-call return, so two shapes remain anyway. Deferred, not rejected: see *Revisit when*. |
| A house `Error` type in `base` | Less code per enum; formats through the Logger's seam. | The engine owns the category and comparison machinery itself, and it does not interoperate with `std::filesystem` or a future `std::expected` without an adapter. |
