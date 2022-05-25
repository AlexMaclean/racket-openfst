#lang racket

(require openfst)

(define CHAR 'a)
(define WHITE-SPACE (fst-union " " "\t" "\n" "\r" "\u00A0"))
(define NOT-SPACE (fst-difference CHAR WHITE-SPACE))

(define maybe-delete-space (fst-delete (fst-closure WHITE-SPACE)))
(define delete-space (fst-delete (fst-closure WHITE-SPACE #:lower 1)))
(define insert-space (fst-insert " "))
(define delete-extra-space (fst-cross (fst-closure WHITE-SPACE #:lower 1) " "))

(define OF "of")
(define NEXT "next")
(define AND "and")
(define STRING "string")
(define GROUP "group")


(define (racket-fst)
  (define cardinal #f)
  (define symbol (symbol-fst))
  (define number (number-fst number))
  (define basic (basic-fst number symbol))
  (define string (string-fst basic))
  (define name (name-fst cardinal symbol))
  (define atom
    (fst-union (fst-add-weight (token "number" number) 0.01)
               (fst-add-weight (token "string" string) -0.1)
               (fst-add-weight (token "name" name) 0.03)))
  (define op
    (fst-union (fst-delete AND)
               (token "op" (fst-accept NEXT))
               (basic-token "op"
                            (fst-concat (maybe (fst-cross (fst-concat GROUP delete-space)
                                                          "group: \"1\" "))
                                        (fst-cross OF (format "text: \"~a\"" OF))))))
  (define graph
    (fst-concat maybe-delete-space
                (maybe (fst-join (fst-union op atom) delete-space))
                maybe-delete-space))
  graph)

; def symbol_fst():
;     with open(Path(__file__).parent / "data" / "symbols.tsv", "r") as keywords_file:
;         reader = csv.reader(keywords_file, delimiter="\t")
;         keyword_mappings = [
;             (name.split(" "), row[0]) for row in reader for name in row[1:]
;         ]

;     graph = pynini.union(
;         *[
;             pynini.cross(words_to_fst(words), pynini.escape(sym))
;             for words, sym in keyword_mappings
;         ]
;     )
;     return graph.optimize()



(define (word->fst words)
  (foldl (λ (word fst)
           (fst-concat fst delete-space (fst-accept word)))
         (fst-accept (first words)) (rest words)))


(define (number-fst cardinal decimal)
  (fst-concat (fst-maybe (fst-concat (fst-cross (fst-union "minus" "negative") "-") delete-space))
              cardinal
              (fst-maybe (fst-concat delete-space (fst-cross "point" ".") delete-space decimal))))


(define (name-fst cardinal symbol)
  (let* ([no-delimit (fst-join (fst-union cardinal symbol) delete-space)]
         [word (fst-add-weight
                (exclude (fst-closure NOT-SPACE #:lower 1)
                         (fst-union OF GROUP AND NEXT)) 1.1)])
    (fst-join
     (fst-add-weight
      (fst-union
       no-delimit
       (fst-concat (maybe (fst-concat no-delimit delete-space))
                   word
                   (fst-closure (fst-concat delete-space
                                            no-delimit
                                            (maybe (fst-concat delete-space word))))))
      0.1)

     (fst-cross delete-space "-"))
    ))



(define (basic-fst number symbol)
  (fst-union
   (fst-add-weight number -0.1)
   (fst-add-weight symbol -0.1)
   (fst-add-weight (fst-closure NOT-SPACE #:lower 1) 0)))


(define (string-fst basic)
  (fst-concat
   (fst-delete (fst-concat STRING delete-space OF))
   (maybe (fst-concat
           delete-space
           (fst-join (exclude basic NEXT) delete-extra-space)
           (maybe (fst-concat delete-space (fst-delete NEXT)))))))


(define (token type fst)
  (fst-concat (fst-insert (format "tokens { type: \"~a\" text: \"" type))
              fst
              (fst-insert "\" } ")))


(define (basic-token type fst)
  (fst-concat (fst-insert (format "tokens { type: \"~a\" " type))
              fst
              (fst-insert " } ")))


(define (exclude fst ex)
  (fst-compose (fst-difference (fst-project fst 'input) ex) fst))

(define (maybe fst)
  (fst-closure fst #:upper 1))

