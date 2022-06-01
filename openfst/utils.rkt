#lang racket/base

(require "main.rkt" racket/contract)

(provide/contract
 [fst-add-weight (fst-like? real? . -> . fst?)]
 [fst-insert     ((fst-like?) (#:weight real?) . ->* . fst?)]
 [fst-delete     ((fst-like?) (#:weight real?) . ->* . fst?)]
 [fst-join       (fst-like? fst-like? . -> . fst?)]
 [fst-rewrite (fst-like? string? . -> . (or/c string? #f))])

;; Functions
;; ----------------------------------------------------------------------------

(define (fst-add-weight fst weight)
  (fst-concat (fst-accept "" #:weight weight) fst))

(define (fst-insert fst #:weight [weight #f])
  (let ([result (fst-cross (fst-accept "") fst)])
    (if weight
        (fst-add-weight result weight)
        result)))

(define (fst-delete fst #:weight [weight #f])
  (let ([result (fst-cross fst (fst-accept ""))])
    (if weight
        (fst-add-weight result weight)
        result)))

(define (fst-join exp sep)
  (fst-concat exp (fst-closure (fst-concat sep exp))))

(define (fst-rewrite fst str)
  (define lattice (fst-compose str fst))
  (and (fst-start lattice) (fst->string (fst-shortest-path lattice))))
