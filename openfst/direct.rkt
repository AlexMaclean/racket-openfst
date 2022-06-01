#lang racket/base

(require racket/contract racket/match "wrapper.rkt")

(define label? (or/c exact-nonnegative-integer? char?))

(provide/contract
 [rename new-Fst make-fst (-> fst?)]
 [rename Fst-AddState fst-add-state! (fst? . -> . exact-nonnegative-integer?)]
 [rename Fst-AddArc fst-add-arc! (fst? exact-nonnegative-integer? arc? . -> . void?)]
 [rename Fst-SetStart fst-set-start! (fst? exact-nonnegative-integer? . -> . void?)]
 [rename Fst-SetFinal fst-set-final! (fst? exact-nonnegative-integer? real? . -> . void?)]
 [rename Fst-NumStates fst-num-states (fst? . -> . exact-nonnegative-integer?)]
 [rename Fst-NumArcs fst-num-arcs (fst? exact-nonnegative-integer? . -> . exact-nonnegative-integer?)]
 [rename Fst-Final fst-final (fst? exact-nonnegative-integer? . -> . real?)]

 [fst-states (fst? . -> . (listof exact-nonnegative-integer?))]
 [fst-arcs (fst? exact-nonnegative-integer? . -> . (listof arc?))]
 [fst-start (fst? . -> . (or/c #f exact-nonnegative-integer?))]

 [arc (label? label? real? exact-nonnegative-integer?  . -> . arc?)]
 [rename Arc-ilabel arc-ilabel (arc? . -> . exact-nonnegative-integer?)]
 [rename Arc-olabel arc-olabel (arc? . -> . exact-nonnegative-integer?)]
 [rename Arc-weight arc-weight (arc? . -> . real?)]
 [rename Arc-nextstate arc-next-state (arc? . -> . exact-nonnegative-integer?)]

 [arc? (any/c . -> . boolean?)])

;; Functions
;; ----------------------------------------------------------------------------

(define (arc ilabel olabel weight dest)
  (new-Arc (label ilabel) (label olabel) (exact->inexact weight) dest))

(define (fst-states fst)
  (iterator->list (new-StateIterator fst) StateIterator-Value
                    StateIterator-Done StateIterator-Next))

(define (fst-arcs fst state)
  (iterator->list (new-ArcIterator fst state) ArcIterator-Value
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

(define (iterator->list iter value done? next!)
    (if (done? iter)
      '()
      (cons (value iter) (begin (next! iter) (iterator->list iter value done? next!)))))
