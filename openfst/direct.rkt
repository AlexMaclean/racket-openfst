#lang racket/base

(require racket/contract racket/match racket/stream "wrapper.rkt")

(define natural? (and/c exact-integer? (not/c negative?)))
(define label? (or/c natural? char?))

(provide/contract
 [rename new-Fst make-fst (-> FST?)]
 [rename Fst-AddState fst-add-state! (FST? . -> . natural?)]
 [rename Fst-AddStates fst-add-states! (FST? natural? . -> . void?)]
 [rename Fst-AddArc fst-add-arc! (FST? natural? Arc? . -> . void?)]
 [rename Fst-SetStart fst-set-start! (FST? natural? . -> . void?)]
 [rename Fst-SetFinal fst-set-final! (FST? natural? real? . -> . void?)]
 [rename Fst-NumStates fst-num-states (FST? . -> . natural?)]
 [rename Fst-NumArcs fst-num-arcs (FST? natural? . -> . natural?)]
 [rename Fst-Start fst-start (FST? . -> . natural?)]
 [rename Fst-Final fst-weight (FST? natural? . -> . real?)]
 [rename Fst-InputSymbols fst-input-symbols (FST? . -> . any/c)]
 [rename Fst-OutputSymbols fst-output-symbols (FST? . -> . any/c)]

 [fst-states (FST? . -> . (stream/c natural?))]
 [fst-arcs (FST? natural? . -> . (stream/c Arc?))]

 [Arc (label? label? real? natural?  . -> . Arc?)]
 [Arc-ilabel (Arc? . -> . natural?)]
 [Arc-olabel (Arc? . -> . natural?)]
 [Arc-weight (Arc? . -> . real?)]
 [rename Arc-nextstate Arc-next-state (Arc? . -> . natural?)])

;; Functions
;; ----------------------------------------------------------------------------

(define (Arc ilabel olabel weight dest)
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
