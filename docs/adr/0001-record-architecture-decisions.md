# ADR 0001 — Record Architecture Decisions

**Status:** Accepted
**Date:** 2026-04-09

## Context

We need a lightweight, permanent record of the "why" behind architectural choices so future contributors (and future us) don't have to re-derive them from code.

## Decision

We use Architecture Decision Records (ADRs) in `docs/adr/`, numbered sequentially, markdown-formatted. Each ADR captures: Context, Decision, Consequences.

## Consequences

- Every non-trivial architectural choice gets an ADR before or alongside implementation.
- ADRs are immutable once accepted; changes are made via new ADRs that supersede old ones.
