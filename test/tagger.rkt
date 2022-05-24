; import csv
; from pathlib import Path

; import pynini
; from nemo_text_processing.inverse_text_normalization.en.taggers.cardinal import (
;     CardinalFst,
; )
; from nemo_text_processing.inverse_text_normalization.en.taggers.decimal import (
;     DecimalFst,
; )
; from pynini.lib import pynutil
; from pynini.lib import utf8

; CHAR = utf8.VALID_UTF8_CHAR
; WHITE_SPACE = pynini.union(" ", "\t", "\n", "\r", "\u00A0").optimize()
; NOT_SPACE = pynini.difference(CHAR, WHITE_SPACE).optimize()
(define CHAR VALID-UTF8-CHAR)
(define WHITE-SPACE (fst-union " " "\t" "\n" "\r" "\u00A0"))
(define NOT-SPACE (fst-difference CHAR WHITE-SPACE))

; maybe_delete_space = pynutil.delete(pynini.closure(WHITE_SPACE))
; delete_space = pynutil.delete(pynini.closure(WHITE_SPACE, lower=1))
; insert_space = pynutil.insert(" ")
; delete_extra_space = pynini.cross(pynini.closure(WHITE_SPACE, 1), " ")
; sigma = pynini.closure(CHAR)
(define maybe-delete-space (fst-delete (fst-closure WHITE-SPACE)))
(define delete-space (fst-delete (fst-closure WHITE-SPACE #:lower 1)))
(define insert-space (fst-insert " "))
(define delete-extra-space (fst-cross (fst-closure WHITE-SPACE #:lower 1) " "))


; # Racket Ops
; OF = "of"
; NEXT = "next"
; AND = "and"
; STRING = "string"
; GROUP = "group"
(define OF "of")
(define NEXT "next")
(define AND "and")
(define STRING "string")
(define GROUP "group")


; def racket_fst():
(define (racket-fst)
;     cardinal = remove_and(CardinalFst())
;     symbol = symbol_fst()
;     number = number_fst(cardinal=cardinal)


;     basic = basic_fst(number=number, symbol=symbol)
;     string = string_fst(basic=basic)
;     name = name_fst(cardinal=cardinal, symbol=symbol)

;     atom = pynini.union(
;         pynutil.add_weight(token("number", number), 0.01),
;         pynutil.add_weight(token("string", string), -0.1),
;         pynutil.add_weight(token("name", name), 0.03),
;     )

;     op = pynini.union(
;         pynutil.delete(AND),
;         token("op", pynini.accep(NEXT)),
;         basic_token(
;             "op",
;             maybe(pynini.cross(GROUP + delete_space, 'group: "1" '))
;             + pynini.cross(OF, f'text: "{OF}"'),
;         ),
;     )

;     graph = (
;         maybe_delete_space
;         + maybe(pynutil.join(pynini.union(op, atom), delete_space))
;         + maybe_delete_space
;     )

;     return graph.optimize()
)

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


; def words_to_fst(words):
;     result = pynini.accep((words[0]))
;     for word in words[1:]:
;         result += delete_space + pynini.accep(word)
;     return result
(define (word->fst words)
    (foldl (lambda (word fst)
                (fst-concat fst delete-space (fst-accept word)))
        (fst-accept (first words)) (rest words)))


; def number_fst(cardinal):
;     return (
;         maybe(pynini.cross(pynini.union("minus", "negative"), "-") + delete_space)
;         + cardinal.graph_no_exception
;         + maybe(
;             delete_space
;             + pynini.cross("point", ".")
;             + delete_space
;             + DecimalFst(cardinal).graph
;         )
;     )
(define (number-fst cardinal decimal)
    (fst-concat (fst-maybe (fst-concat (fst-cross (fst-union "minus" "negative") "-") delete-space))
                cardinal
                (fst-maybe (fst-concat delete-space (fst-cross "point" ".") delete-space decimal))))


; def name_fst(cardinal: CardinalFst, symbol):
;     no_delimit = pynutil.join(
;         pynini.union(cardinal.graph_no_exception, symbol), delete_space
;     )
;     word = pynutil.add_weight(
;         exclude(
;             pynini.closure(NOT_SPACE, lower=1),
;             pynini.union(OF, GROUP, AND, NEXT),
;         ),
;         1.1,
;     )
;     undelimited = pynutil.add_weight(
;         pynini.union(
;             no_delimit,
;             (
;                 maybe(no_delimit + delete_space)
;                 + word
;                 + pynini.closure(delete_space + no_delimit + maybe(delete_space + word))
;             ),
;         ),
;         0.1,
;     )

;     name = pynutil.join(undelimited, pynini.cross(delete_space, "-"))

;     return name.optimize()
(define (name-fst cardinal symbol)
    (let* ([no-delimit (fst-join (fst-union cardinal symbol) delete-space)]
          [word (fst-add-weight
          (exclude (fst-closure NOT-SPACE #:lower 1)
                                        (fst-union OF GROUP AND NEXT)) 1.1)]
           [undelimited (fst-add-weight (fst-union no-delimit (fst-concat
            (maybe (fst-concat no-delimit delete-space))
            word (fst-closure (fst-concat delete-space no-delimit (maybe (fst-concat delete-space word)))))) 0.1)])

           (fst-join undelimited (fst-cross delete-space "-"))
        ))


; def basic_fst(number, symbol):
;     return (
;         pynutil.add_weight(number, -0.1)
;         | pynutil.add_weight(symbol, -0.1)
;         | pynutil.add_weight(pynini.closure(NOT_SPACE, lower=1), 0)
;     ).optimize()
(define (basic-fst number symbol)
    (fst-union
        (fst-add-weight number -0.1)
        (fst-add-weight symbol -0.1)
        (fst-add-weight (fst-closure NOT-SPACE #:lower 1) 0)))


; def string_fst(basic):
;     return (
;         pynutil.delete(STRING + delete_space + OF)
;         + maybe(
;             delete_space
;             + pynutil.join(exclude(basic, NEXT), delete_extra_space)
;             + maybe(delete_space + pynutil.delete(NEXT))
;         )
;     ).optimize()
(define (string-fst basic)
    (fst-concat
        (fst-delete (fst-concat STRING delete-space OF))
        (maybe (fst-concat
            delete-space
            (fst-join (exclude basic NEXT) delete-extra-space)
            (maybe (fst-concat delete-space (fst-delete NEXT)))))))


; def token(type, fst):
;     return (
;         pynutil.insert(f'tokens {{ type: "{type}" text: "')
;         + fst
;         + pynutil.insert('" } ')
;     )
(define (token type fst)
    (fst-concat
        (fst-insert (format "tokens { type: \"~a\" text: \"" type))
        fst
        (fst-insert "\" } ")))


; def basic_token(type, fst):
;     return pynutil.insert(f'tokens {{ type: "{type}" ') + fst + pynutil.insert(" } ")
(define (basic-token type fst)
    (fst-concat (fst-insert (format "tokens { type: \"~a\" " type))
            fst
            (fst-insert " } ")))


; def remove_and(cardinal: CardinalFst):
;     graph = cardinal.graph_no_exception
;     graph = (
;         pynini.cdrewrite(pynutil.delete("and"), WHITE_SPACE, WHITE_SPACE, sigma) @ graph
;     )

;     cardinal.graph_no_exception = graph
;     return cardinal


; def exclude(fst, ex):
;     return (pynini.project(fst, "input") - ex) @ fst
(define (exclude fst ex)
    (fst-compose (fst-difference (fst-project fst 'input) ex) fst))


; def maybe(fst):
;     return pynini.closure(fst, upper=1)
(define (maybe fst)
    (fst-closure fst #:upper 1))


; if __name__ == "__main__":
;     print("Racket FST:")
;     graph = racket_fst()
;     graph.write("racket.fst")
;     print("done")
