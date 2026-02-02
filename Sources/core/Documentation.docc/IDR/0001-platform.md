# IDR#0001 Supported Platform

2026-02-01

## Context and Problem Statement
Swift runs on many platforms and not all are testable for free. Also complexity of source code can be more if all platforms are supported.

## Decision

**Chosen option:**
* Primary platform is **macOS**.
  * It is recommended also support other Swift platforms like FreeBSD, Linux, Windows and so on. This other platforms can be in *Supported Tier X* later.
    * A pure Swift implementation without operating system-dependent APIs should be available if possible.

## Consequences

**Good:**

* Faster forward, because one local existing testsystem.
* Clean code without bad os conditional compiling.

**Bad:**

* Especially Linux has a great big OSS community, who is missing.

**Neutral:** 

* none
