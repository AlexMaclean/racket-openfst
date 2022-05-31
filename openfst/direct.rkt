#lang racket/base

(require racket/contract racket/match racket/stream "wrapper.rkt")

(define label? (or/c exact-nonnegative-integer? char?))

(provide/contract
 [rename new-Fst make-fst (-> FST?)]
 [rename Fst-AddState fst-add-state! (FST? . -> . exact-nonnegative-integer?)]
 [rename Fst-AddArc fst-add-arc! (FST? exact-nonnegative-integer? Arc? . -> . void?)]
 [rename Fst-SetStart fst-set-start! (FST? exact-nonnegative-integer? . -> . void?)]
 [rename Fst-SetFinal fst-set-final! (FST? exact-nonnegative-integer? real? . -> . void?)]
 [rename Fst-NumStates fst-num-states (FST? . -> . exact-nonnegative-integer?)]
 [rename Fst-NumArcs fst-num-arcs (FST? exact-nonnegative-integer? . -> . exact-nonnegative-integer?)]
 [rename Fst-Final fst-weight (FST? exact-nonnegative-integer? . -> . real?)]
 [rename Fst-InputSymbols fst-input-symbols (FST? . -> . any/c)]
 [rename Fst-OutputSymbols fst-output-symbols (FST? . -> . any/c)]

 [fst-states (FST? . -> . (stream/c exact-nonnegative-integer?))]
 [fst-arcs (FST? exact-nonnegative-integer? . -> . (stream/c Arc?))]
 [fst-start (FST? . -> . (or/c #f exact-nonnegative-integer?))]

 [Arc (label? label? real? exact-nonnegative-integer?  . -> . Arc?)]
 [Arc-ilabel (Arc? . -> . exact-nonnegative-integer?)]
 [Arc-olabel (Arc? . -> . exact-nonnegative-integer?)]
 [Arc-weight (Arc? . -> . real?)]
 [rename Arc-nextstate Arc-next-state (Arc? . -> . exact-nonnegative-integer?)])

;; Functions
;; ----------------------------------------------------------------------------

(define (Arc ilabel olabel weight dest)
  (new-Arc (label ilabel) (label olabel) (exact->inexact weight) dest))

(define (fst-states fst)
  (iterator->stream (new-StateIterator fst) StateIterator-Value
                    StateIterator-Done StateIterator-Next))

(define (fst-arcs fst state)
  (iterator->stream (new-ArcIterator fst state) ArcIterator-Value
                    ArcIterator-Done ArcIterator-Next))

(define (fst-start fst)
  (let ([start (Fst-Start fst)])
   (if (equal? start -1) #f start)))

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
  (define (first)
    (value iter))
  (define (get-stream)
    (if (done? iter)
      empty-stream
      (stream-cons #:eager (first) (rest))))
  (define (rest)
    (next! iter)
    (get-stream))

  (get-stream))
