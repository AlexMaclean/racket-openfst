#lang racket

(require "../abstract.rkt")


(define fst3 (fst-accept "this string is a test"))
(fst->string fst3)


(define fst4 (fst-union (fst-accept "test") (fst-accept "hello")))

(fst-shortest-path fst4)
fst3

(define f5 (fst-cross (fst-accept "hello") (fst-accept "world")))
(define f6 (fst-cross (fst-accept "world") (fst-accept "123")))
(define f7 (fst-compose f5 f6))

(fst->string (fst-shortest-path f7))

(define f8 (fst-concat "A" "B" "C"))
(fst->string (fst-shortest-path f8))

(define f9 (fst-cross "hello" "world"))

(fst->string (fst-project f9 'input))
(fst->string (fst-project f9 'output))