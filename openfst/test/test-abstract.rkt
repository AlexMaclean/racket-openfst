#lang racket

(require "../main.rkt"
         "../utils.rkt"
         rackunit
         rackunit/text-ui)

(define (tests)
  (run-tests
   (test-suite
    "OpenFst Abstract Manipulation"

    (test-case
     "Simple closure"

     (define xor-fst (fst-closure (fst-union (fst-cross "0" "1") (fst-cross "1" "0"))))

     (check-equal? (fst-rewrite xor-fst "0101") "1010")
     (check-equal? (fst-rewrite xor-fst "") "")
     (check-equal? (fst-rewrite xor-fst "1011000") "0100111")
     (check-equal? (fst-rewrite xor-fst "bogus") #f))

    (test-case
    "String Conversion with unicode"
    (define l (fst-accept "λ" #:weight 32))

    (check-equal? (fst->string l) "λ")
    (check-equal? (fst-num-states l) 2)
    (check-= (fst-final l 1) 32.0 1e-10)
    (check-equal? (arc-ilabel (first (fst-arcs l 0))) (char->integer #\λ)))

    )
   'verbose)
  (void))

(tests)


; (define fst3 (fst-accept "this string is a test"))
; (fst->string fst3)


; (define fst4 (fst-union (fst-accept "test") (fst-accept "hello")))

; (fst-shortest-path fst4)
; fst3

; (define f5 (fst-cross (fst-accept "hello") (fst-accept "world")))
; (define f6 (fst-cross (fst-accept "world") (fst-accept "123")))
; (define f7 (fst-compose f5 f6))

; (fst->string (fst-shortest-path f7))

; (define f8 (fst-concat "A" "B" "C"))
; (fst->string (fst-shortest-path f8))

; (define f9 (fst-cross "hello" "world"))

; (fst->string (fst-project f9 'input))
; (fst->string (fst-project f9 'output))