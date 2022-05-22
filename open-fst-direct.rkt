#lang racket

(provide (all-defined-out))

(require "open-fst-raw.rkt")

(define (make-fst) (new-VectorFst))

(define (fst-add-state! fst)
    (VectorFst-AddState fst))

(define (fst-add-states! fst n)
 (VectorFst-AddStates fst n))

(define (fst-num-states fst)
 (VectorFst-NumStates fst))

(define (fst-num-arcs fst state)
 (VectorFst-NumArcs fst state))

(define (fst-add-arc! fst state arc)
 (VectorFst-AddArc fst state arc))

(define (fst-set-start! fst state)
    (VectorFst-SetStart fst state))

(define (fst-set-final! fst state weight)
    (VectorFst-SetFinal fst state weight))

(define (fst-start fst)
 (Fst-Start fst))

(define (fst-final fst state)
(Fst-Final fst state))

(define (fst-input-symbols fst)
 (Fst-InputSymbols fst))

(define (fst-output-symbols fst)
 (Fst-OutputSymbols fst))

(define make-arc new-Arc)

;; Helper Functions

(define (SymbolTable->hash-table SymbolTable)
  (for/hash ([pos (in-range (SymbolTable-NumSymbols SymbolTable))])
    (let ([key (SymbolTable-GetNthKey SymbolTable pos)])
     (values key (SymbolTable-Find SymbolTable key)))))