# IDR#0005 Project target

2026-02-04 (update)

## Context and Problem Statement
What is the target of this project? Many reimplementations have different targets. 

## Decision

**Chosen option:**
* Programming with Swift.
* A reimplementation of POSIX tools to be an replacement of BSD core tools.
* BSD implementation beats GNU implementation
* Feature scope
  * Existing core implementation 🥉
    * OpenBSD scope 
      * NetBSD scope 🥈
        * FreeBSD scope 🥇
          * macOS scope (Apple Silicon) 
            * GNU extensions
* Base for SOS, so more utils than Rust uutil and GNU coreutils are implemented.

## Consequences

**Good:** 

* Clear target

**Bad:**

* Not every persons dream.

**Neutral:** 

* none

## Note

This weak decision originated in the project start phase, but is now being rigorously documented.
