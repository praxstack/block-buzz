# Spec: #8033 ACP panic dead-letter is silent

Status: APPROVED (design review round 2)

## Problem

`EventQueue::requeue` returns `Some(batch)` when the retry budget is
exhausted so the caller can post a visible failure notice. `handle_prompt_result`
does that. `recover_panicked_agent` currently `let _ = queue.requeue(batch)`
and comments that a panic path has no notice. Exhausted panic retries discard
the user's request with no channel message.

## Decision

1. Park a bounded dead-letter journal on the queue when `requeue` exhausts
   retries (durable record even if REST is missing).
2. `recover_panicked_agent` takes `rest_client` and, on dead-letter, posts
   the same class of failure notice as other exhausted-retry paths, including
   a short last-message preview.
3. Non-exhausted panic requeues stay silent (retry will run).

## Tests

- `requeue` parks a journal record at the dead-letter threshold
- panic recovery with `MAX_RETRIES` already spent parks the batch and does
  not leave undispatched work
