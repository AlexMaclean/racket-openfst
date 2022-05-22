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

; maybe_delete_space = pynutil.delete(pynini.closure(WHITE_SPACE))
; delete_space = pynutil.delete(pynini.closure(WHITE_SPACE, lower=1))
; insert_space = pynutil.insert(" ")
; delete_extra_space = pynini.cross(pynini.closure(WHITE_SPACE, 1), " ")
; sigma = pynini.closure(CHAR)

; # Racket Ops
; OF = "of"
; NEXT = "next"
; AND = "and"
; STRING = "string"
; GROUP = "group"


; def racket_fst():
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


; def basic_fst(number, symbol):
;     return (
;         pynutil.add_weight(number, -0.1)
;         | pynutil.add_weight(symbol, -0.1)
;         | pynutil.add_weight(pynini.closure(NOT_SPACE, lower=1), 0)
;     ).optimize()


; def string_fst(basic):
;     return (
;         pynutil.delete(STRING + delete_space + OF)
;         + maybe(
;             delete_space
;             + pynutil.join(exclude(basic, NEXT), delete_extra_space)
;             + maybe(delete_space + pynutil.delete(NEXT))
;         )
;     ).optimize()


; def token(type, fst):
;     return (
;         pynutil.insert(f'tokens {{ type: "{type}" text: "')
;         + fst
;         + pynutil.insert('" } ')
;     )


; def basic_token(type, fst):
;     return pynutil.insert(f'tokens {{ type: "{type}" ') + fst + pynutil.insert(" } ")


; def remove_and(cardinal: CardinalFst):
;     graph = cardinal.graph_no_exception
;     graph = (
;         pynini.cdrewrite(pynutil.delete("and"), WHITE_SPACE, WHITE_SPACE, sigma) @ graph
;     )

;     cardinal.graph_no_exception = graph
;     return cardinal


; def exclude(fst, ex):
;     return (pynini.project(fst, "input") - ex) @ fst


; def maybe(fst):
;     return pynini.closure(fst, upper=1)


; if __name__ == "__main__":
;     print("Racket FST:")
;     graph = racket_fst()
;     graph.write("racket.fst")
;     print("done")
