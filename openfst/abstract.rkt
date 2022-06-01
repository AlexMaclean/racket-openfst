#lang racket/base

(require "wrapper.rkt" racket/contract racket/match racket/math)

(define (fst-like? v)
  (or (string? v) (fst? v)))

(provide/contract
 [fst-write (fst-like? path-string? . -> . void?)]
 [rename Fst-Read fst-read (path-string? . -> . fst?)]
 [fst-cross (fst-like? fst-like? . -> . fst?)]
 [fst->string (fst-like? . -> . string?)]
 [fst-shortest-path ((fst-like?) (exact-positive-integer?) . ->* . fst?)]
 [fst-union   ((fst-like?) #:rest (listof fst-like?) . ->* . fst?)]
 [fst-compose ((fst-like?) #:rest (listof fst-like?) . ->* . fst?)]
 [fst-concat  ((fst-like?) #:rest (listof fst-like?) . ->* . fst?)]
 [fst-accept ((string?) (#:weight real?) . ->* . fst?)]
 [fst-closure ((fst?) (#:lower exact-nonnegative-integer?
                       #:upper (and/c positive? (or/c exact-integer? infinite?))) . ->* . fst?)]
 [fst-difference (fst-like? fst-like? . -> . fst?)]
 [fst-project (fst-like? (or/c 'input 'output) . -> . fst?)]

 [fst-like? (any/c . -> . boolean?)]
 [fst? (any/c . -> . boolean?)])

;; Functions
;; ----------------------------------------------------------------------------

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

(define (fst-difference fst1 fst2)
  (Fst-Difference (fst-like fst1) (fst-like fst2)))

(define (fst-project fst project-type)
  (Fst-Project (fst-like fst)
               (match project-type
                 ['input 'PROJECT_INPUT]
                 ['output 'PROJECT_OUTPUT])))

(define (fst-closure fst #:lower [lower 0] #:upper [upper +inf.0])
  (when (lower . > . upper)
    (error 'fst-closure "lower bound ~e is greater than upper bound ~e" lower upper))
  (Fst-Closure (fst-like fst) lower (if (equal? upper +inf.0) 0 upper)))

(define (fst-like arg)
  (if (string? arg) (fst-accept arg) arg))

;; Helper Functions
;; ----------------------------------------------------------------------------

(define (repeated-apply binary-fun arg-list)
  (match arg-list
    [(list arg) (fst-like arg)]
    [(cons arg rst) (binary-fun (fst-like arg) (repeated-apply binary-fun rst))]))