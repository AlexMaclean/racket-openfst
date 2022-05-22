#lang racket

(provide (all-defined-out))

(require "open-fst-raw.rkt")

(define compiler (new-StringCompiler))

(define fst->string
    (curry StringPrinter-call (new-StringPrinter)))

(define (fst-write fst path)
 (Fst-Write fst path))

(define (fst-read path)
 (Fst-Read path))

(define (fst-shortest-path fst [n-paths 1])
 (Fst-ShortestPath fst n-paths))

(define (fst-union fst1 . fsts)
    (repeated-apply Fst-Union (cons fst1 fsts)))
(define fst-U fst-union)

(define (fst-compose fst1 . fsts)
    (repeated-apply Fst-Compose (cons fst1 fsts)))

(define (fst-concat fst1 . fsts)
    (repeated-apply Fst-Concat (cons fst1 fsts)))

(define (fst-cross fst1 fst2)
    (Fst-Cross fst1 fst2))

(define (fst-accept str [weight 0.0])
    (StringCompiler-call compiler str weight))


;; Helper Functions

(define (repeated-apply binary-fun arg-list)
    (match arg-list
        [(list arg) arg]
        [(cons arg rst) (binary-fun arg (repeated-apply binary-fun rst))]))