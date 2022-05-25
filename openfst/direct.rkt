#lang racket/base

(require racket/contract racket/match racket/stream "wrapper.rkt")

(define natural? (and/c exact-integer? (not/c negative?)))
(define label? (or/c natural? char?))

(provide/contract
 [rename new-VectorFst make-fst (-> FST?)]
 [rename VectorFst-AddState fst-add-state! (FST? . -> . natural?)]
 [rename VectorFst-AddStates fst-add-states! (FST? natural? . -> . void?)]
 [rename VectorFst-NumStates fst-num-states (FST? . -> . natural?)]
 [rename VectorFst-NumArcs fst-num-arcs (FST? natural? . -> . natural?)]
 [rename VectorFst-AddArc fst-add-arc! (FST? natural? FST-Arc? . -> . void?)]
 [rename VectorFst-SetStart fst-set-start! (FST? natural? . -> . void?)]
 [rename VectorFst-SetFinal fst-set-final! (FST? natural? real? . -> . void?)]
 [rename Fst-Start fst-start (FST? . -> . natural?)]
 [rename Fst-Final fst-weight (FST? natural? . -> . real?)]
 [rename Fst-InputSymbols fst-input-symbols (FST? . -> . any/c)]
 [rename Fst-OutputSymbols fst-output-symbols (FST? . -> . any/c)]
 [make-arc (label? label? real? natural?  . -> . FST-Arc?)]
 [fst-states (FST? . -> . (stream/c natural?))]
 [fst-arcs (FST? natural? . -> . (stream/c FST-Arc?))])

;; Functions
;; ----------------------------------------------------------------------------

(define (make-arc ilabel olabel weight dest)
  (new-Arc (label ilabel) (label olabel) weight dest))

(define (fst-states fst)
  (iterator->stream (new-StateIterator fst) StateIterator-Value
                    StateIterator-Done StateIterator-Next))

(define (fst-arcs fst state)
  (iterator->stream (new-ArcIterator fst state) ArcIterator-Value
                    ArcIterator-Done ArcIterator-Next))

;; Helper Functions
;; ----------------------------------------------------------------------------

(define (label l)
  (match l
    [(? char?) (char->integer l)]
    [(? exact-integer?) l]))

(define (SymbolTable->hash-table SymbolTable)
  (for/hash ([pos (in-range (SymbolTable-NumSymbols SymbolTable))])
    (let ([key (SymbolTable-GetNthKey SymbolTable pos)])
      (values key (SymbolTable-Find SymbolTable key)))))

(define (iterator->stream iter value done? next!)
  (define (first) (value iter))
  (define (rest)
    (if (done? iter) empty-stream
        (begin (next! iter) (stream-cons (first) (rest)))))
  (if (done? iter) empty-stream
      (stream-cons (first) (rest))))
