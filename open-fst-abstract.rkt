#lang racket/base

(require "open-fst-raw.rkt" racket/contract racket/match)

(define fst-like? (or/c string? FST?))

(provide/contract
    [fst-write (fst-like? path-string? . -> . void?)]
    [rename Fst-Read fst-read (path-string? . -> . FST?)]
    [fst-cross (fst-like? fst-like? . -> . FST?)]
    [fst->string (fst-like? . -> . string?)]
    [fst-shortest-path ((fst-like?) ((and/c integer? positive?)) . ->* . FST?)]
    [fst-union ((fst-like?) #:rest (listof fst-like?) . ->* . FST?)]
    [fst-compose ((fst-like?) #:rest (listof fst-like?) . ->* . FST?)]
    [fst-concat ((fst-like?) #:rest (listof fst-like?) . ->* . FST?)]
    [fst-accept ((string?) (#:weight real?) . ->* . FST?)]
    [fst-like (fst-like? . -> . FST?)])

(provide fst-like?)

(define compiler (new-StringCompiler))
(define printer (new-StringPrinter))

(define (fst->string fst)
    (StringPrinter-call printer (fst-like fst)))

(define (fst-shortest-path fst [n-paths 1])
 (Fst-ShortestPath (fst-like fst) n-paths))

(define (fst-union fst1 . fsts)
    (repeated-apply Fst-Union (cons fst1 fsts)))

(define (fst-compose fst1 . fsts)
    (repeated-apply Fst-Compose (cons fst1 fsts)))

(define (fst-concat fst1 . fsts)
    (repeated-apply Fst-Concat (cons fst1 fsts)))

(define (fst-accept str #:weight [weight 0.0])
    (StringCompiler-call compiler str weight))

(define (fst-cross fst1 fst2)
    (Fst-Cross (fst-like fst1) (fst-like fst2)))

(define (fst-write fst path)
    (Fst-Write (fst-like fst) path))

;; Misc.

(define (fst-like arg)
    (if (string? arg) (fst->string arg) arg))

;; Helper Functions

(define (repeated-apply binary-fun arg-list)
    (match arg-list
        [(list arg) (fst-like arg)]
        [(cons arg rst) (binary-fun (fst-like arg) (repeated-apply binary-fun rst))]))