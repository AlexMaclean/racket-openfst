#lang racket

(require "../main.rkt"
         "../utils.rkt"
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
     (check-equal? (fst-states fst) '())
     (check-equal? (fst-start fst) #f)
     (check-equal? (fst? fst) #t))

    (test-case
     "Single State Acceptor"
     (define fst (make-fst))
     (define s0 (fst-add-state! fst))
     (define a (arc #\A #\A 0 s0))

     (fst-add-arc! fst s0 a)
     (fst-set-start! fst s0)
     (fst-set-final! fst s0 0.12)

     (check-equal? (arc? a) #t)
     (check-equal? (fst-num-states fst) 1)
     (check-equal? (fst-num-arcs fst s0) 1)
     (check-equal? (fst-start fst) s0)
     (check-= (fst-final fst s0) 0.12 0.0001)

     (check-equal?  (fst-states fst) (list s0))
     (check-equal? (length (fst-arcs fst s0)) 1)

     (check-equal? (fst->string (fst-shortest-path fst)) "")
     (check-equal? (fst->string (fst-shortest-path (fst-compose "AAAA" fst))) "AAAA")
     (check-equal? (fst-start (fst-shortest-path (fst-compose "AAABA" fst))) #f))

    (test-case
     "Slightly Larger Transducer"
     (define fst (make-fst))
     (define s0 (fst-add-state! fst))
     (define s1 (fst-add-state! fst))

     (fst-add-arc! fst s0 (arc #\A #\1 0 s1))
     (fst-add-arc! fst s1 (arc #\B #\2 0 s0))
     (fst-set-start! fst s0)
     (fst-set-final! fst s1 0.0)

     (check-equal? (fst->string (fst-shortest-path fst)) "1")
     (check-equal? (fst->string (fst-shortest-path (fst-compose "A" fst))) "1")
     (check-equal? (fst->string (fst-shortest-path (fst-compose "ABABA" fst))) "12121")
     (check-equal? (fst-start (fst-shortest-path (fst-compose "B" fst))) #f)
     (check-equal? (fst-start (fst-shortest-path (fst-compose "AB" fst))) #f)
     (check-equal? (fst-start (fst-shortest-path (fst-compose "invalid" fst))) #f))

    (test-case
     "Transducer Arcs"

     (define a1 (arc 4 5 0.2 1))
     (define a2 (arc 4 5 0.2 1))
     (define a3 (arc 4 4 0.2 1))

     (check-equal? a1 a2)
     (check-equal? (equal? a1 a3) #f)

     (check-equal? (arc-ilabel a1) 4)
     (check-equal? (arc-olabel a1) 5)
     (check-= (arc-weight a1) 0.2 0.00001)
     (check-equal? (arc-next-state a1) 1))

    (test-case
     "Tricky FST construction (add1)"
     (define add1*
       (make-fst
        '((start 0)
          (#\0 #\1 0 done)
          (#\1 #\0 0 carry))
        '(carry
          (#\0 #\1 0 done)
          (#\1 #\0 0 carry)
          (0 #\1 0 very-done))
        '((done 0)
          (#\0 #\0 0 done)
          (#\1 #\1 0 done))
        '((very-done 0))))

     (define add1 (fst-reverse add1*))

     (check-equal? (fst-rewrite add1 "0") "1")
     (check-equal? (fst-rewrite add1 "10") "11")
     (check-equal? (fst-rewrite add1 "11") "100")
     (check-equal? (fst-rewrite add1 "1001011") "1001100")))
   'verbose)
  (void))

(tests)
