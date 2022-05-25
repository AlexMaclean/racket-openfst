#lang racket

(require "../direct.rkt" "../abstract.rkt"
    rackunit rackunit/text-ui racket/stream)

; (run-tests
; (test-suite "openfst"

;; A vector FST is a general mutable FST
; (let ([fst (make-fst)])
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

(define a (fst-states fst))
(stream->list a)

(stream->list (fst-arcs fst 1))
; (define fst2 (fst-read "test.fst"))
; (fst-num-states fst2)
; (fst-num-arcs fst2 0)
; )))