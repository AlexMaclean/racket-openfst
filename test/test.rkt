#lang racket

(require "open-fst-abstract.rkt" "open-fst-direct.rkt")

;; A vector FST is a general mutable FST
(define fst (make-fst))

;; Adds state 0 to the initially empty FST and make it the start state.
(fst-add-state! fst)   ;; 1st state will be state 0 (returned by AddState)
(fst-set-start! fst 0)  ;; arg is state ID

;; Adds two arcs exiting state 0.
;; Arc constructor args: ilabel, olabel, weight, dest state ID.
(fst-add-arc! fst 0 (make-arc 1 1 0.5 1))  ;; 1st arg is src state ID
(fst-add-arc! fst 0 (make-arc 2 2 1.5 1))

;; Adds state 1 and its arc.
(fst-add-state! fst)
(fst-add-arc! fst 1 (make-arc 3 3 2.5 2))

;; Adds state 2 and set its final weight.
(fst-add-state! fst)
(fst-set-final! fst 2 3.5)  ;; 1st arg is state ID, 2nd arg weight

(fst-input-symbols fst)
(fst-output-symbols fst)

(fst-write fst "test.fst")

(define fst2 (fst-read "test.fst"))
(fst-num-states fst2)
(fst-num-arcs fst2 0)

(define fst3 (fst-accept "this string is a test"))
(fst-num-states fst3)
(fst->string fst3)

(define p (fst-shortest-path fst 1))

(fst->string p)
p

(define fst4 (fst-union (fst-accept "test") (fst-accept "hello")))

(fst-shortest-path fst4)
fst3

(define f5 (fst-cross (fst-accept "hello") (fst-accept "world")))
(define f6 (fst-cross (fst-accept "world") (fst-accept "123")))
(define f7 (fst-compose f5 f6))

(fst->string (fst-shortest-path f7))

(define f8 (fst-concat (fst-accept "A") (fst-accept "B") (fst-accept "C")))
(fst->string (fst-shortest-path f8))