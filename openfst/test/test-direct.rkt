#lang racket

(require "../main.rkt"
         rackunit
         rackunit/text-ui)

(define (tests)
  (run-tests
   (test-suite
    "OpenFst Direct Access"

    (test-case
     "Empty Fst"
     (define fst (make-fst))

     (check-equal? (fst-num-states fst) 0)
     (check-equal? (stream->list (fst-states fst)) '())
     (check-equal? (fst-start fst) #f))

    (test-case
     "Single State Acceptor"
     (define fst (make-fst))
     (define s0 (fst-add-state! fst))
     (define arc (Arc #\A #\A 0 s0))
     (fst-add-arc! fst s0 arc)
     (fst-set-start! fst s0)
     (fst-set-final! fst s0 0.0)

     (check-equal? (fst-num-states fst) 1)
     (check-equal? (fst-num-arcs fst s0) 1)
     (check-equal? (fst-start fst) s0)

     (check-equal? (stream->list (fst-states fst)) (list s0))
     (check-equal? (length (stream->list (fst-arcs fst s0))) 1)

     (check-equal? (fst->string (fst-shortest-path fst)) "")
     (check-equal? (fst->string (fst-shortest-path (fst-compose "AAAA" fst))) "AAAA")
     (check-equal? (fst-start (fst-shortest-path (fst-compose "AAABA" fst))) #f))

    (test-case
     "Slightly Larger Transducer"
     (define fst (make-fst))
     (define s0 (fst-add-state! fst))
     (define s1 (fst-add-state! fst))

     (fst-add-arc! fst s0 (Arc #\A #\1 0 s1))
     (fst-add-arc! fst s1 (Arc #\B #\2 0 s0))
     (fst-set-start! fst s0)
     (fst-set-final! fst s1 0.0)

     (check-equal? (fst->string (fst-shortest-path fst)) "1")
     (check-equal? (fst->string (fst-shortest-path (fst-compose "A" fst))) "1")
     (check-equal? (fst->string (fst-shortest-path (fst-compose "ABABA" fst))) "12121")
     (check-equal? (fst-start (fst-shortest-path (fst-compose "B" fst))) #f)
     (check-equal? (fst-start (fst-shortest-path (fst-compose "AB" fst))) #f)
     (check-equal? (fst-start (fst-shortest-path (fst-compose "invalid" fst))) #f))
    ))
  (void))

(tests)
