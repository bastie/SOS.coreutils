# IDR#0002 3rd-party libraries

2026-02-01

## Context and Problem Statement
Using 3rd-party libraries carries risks related to compliance, such as licenses and security (including the supply chain).

## Decision

**Chosen option:**
* 3rd-party libraries use should be limited to what is necessary.
* Permitted libraries are listed in the appendix.

## Consequences

**Good:** 

* It is clear what is permitted.
* License and security problemes can be detected before included in source code.

**Bad:**

* It can be slower implemented, if good libraries are noch permitted.

**Neutral:** 

* none
