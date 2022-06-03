#lang racket/base

(require racket/contract racket/match "wrapper.rkt")

(define (label? v)
  (or (exact-nonnegative-integer? v) (char? v)))

(provide/contract
 [make-fst (() #:rest (listof (cons/c (or/c symbol? (list/c symbol? real?))
                                      (listof (list/c label? label? real? symbol?)))) . ->* . fst?)]
 [rename Fst-AddState fst-add-state! (fst? . -> . exact-nonnegative-integer?)]
 [rename Fst-AddArc fst-add-arc! (fst? exact-nonnegative-integer? arc? . -> . void?)]
 [rename Fst-SetStart fst-set-start! (fst? exact-nonnegative-integer? . -> . void?)]
 [fst-set-final! (fst? exact-nonnegative-integer? real? . -> . void?)]
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

 [arc? (any/c . -> . boolean?)]
 [label? (any/c . -> . boolean?)])

;; Functions
;; ----------------------------------------------------------------------------

(define (make-fst . states)
  (define fst (new-Fst))
  ;; Add all the states to the FST with appropriate weights, keep a mapping
  ;; of symbol-ids to acctual state-ids in the FST
  (define state-ids
    (for/hash ([state-info states])
      (define id (Fst-AddState fst))
      (define weight (state-def-weight state-info))
      (when weight
        (fst-set-final! fst id weight))
      (values (state-def-id state-info) id)))

  ;; Add the arcs to the fst, using the state-ids table from above
  (for ([state-info states])
    (define source-id (hash-ref state-ids (state-def-id state-info)))
    (for ([arc-info (cdr state-info)])
      (match arc-info
        [(list ilabel olabel weight next-id)
         (Fst-AddArc
          fst source-id
          (arc ilabel olabel weight
               (hash-ref state-ids next-id
                         (λ () (error 'make-fst "undefined arc destenation ~e in ~e"
                                      next-id state-info)))))])))

  ;; Unless teh FST is empty assign the first state provided as the start state.
  (unless (equal? states '())
    (Fst-SetStart fst (hash-ref state-ids (state-def-id (car states)))))

  fst)

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

(define (fst-set-final! fst state weight)
  (Fst-SetFinal fst state (exact->inexact weight)))

;; Helper Functions
;; ----------------------------------------------------------------------------

(define (state-def-id state-def)
  (match (car state-def)
    [(list id _) id]
    [id id]))

(define (state-def-weight state-def)
  (match (car state-def)
    [(list _ weight) weight]
    [_ #f]))

(define (label l)
  (match l
    [(? char?) (char->integer l)]
    [(? exact-integer?) l]))

(define (iterator->list iter value done? next!)
  (if (done? iter)
      '()
      (cons (value iter) (begin (next! iter) (iterator->list iter value done? next!)))))
