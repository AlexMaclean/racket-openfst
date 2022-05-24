#lang racket/base

(require "abstract.rkt" racket/contract)

(provide/contract
 [fst-add-weight (fst-like? real? . -> . FST?)]
 [fst-insert     ((fst-like?) (#:weight real?) . ->* . FST?)]
 [fst-delete     ((fst-like?) (#:weight real?) . ->* . FST?)]
 #;[fst-join       (fst-like? fst-like? . -> . FST?)])

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

; (define (fst-join exp sep)
;   (fst-concat exp (fst-closure (fst-concat sep exp))))
