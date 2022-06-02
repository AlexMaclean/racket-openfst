#lang scribble/manual
@require[@for-label[racket/base openfst racket/stream racket/contract racket/math]]

@title{OpenFst: Racket Bindings}

@author[(author+email "Alex MacLean" "alex@alex-maclean.com")]

@defmodule[openfst]

This package is definitely a work in progress. Apologies for the current incompleteness!

@section{Abstract Automata Manipulation}

@defproc[(fst? [v any/c]) boolean?]{
 Returns @racket[#true] if the given @racket[v] is a finite-state transducer.
}

@defproc[(fst-like? [v any/c]) boolean?]{
 Returns @racket[(or (string? v) (fst? v))].
}

@defproc[(fst-accept [str string?] [#:weight weight real? 0]) fst?]{

}

@defproc[(fst-cross [fst1 fst-like?] [fst2 fst-like?]) fst?]{

}

@defproc[(fst-closure [fst fst-like?] [#:lower lower exact-nonnegative-integer? 0]
                      [#:upper upper (and/c positive? (or/c exact-integer? infinite?)) +inf.0]) fst?]{
}

@defproc[(fst-union [fst fst-like?] ...+) fst?]{

}

@defproc[(fst-compose [fst fst-like?] ...+) fst?]{

}

@defproc[(fst-concat [fst fst-like?] ...+) fst?]{

}

@defproc[(fst-difference [fst1 fst-like?] [fst2 fst-like?]) fst?]{

}

@defproc[(fst-project [fst fst-like?] [type (or/c 'input 'output)]) fst?]{

}


@defproc[(fst-shortest-path [fst fst-like?] [n exact-positive-integer? 1]) fst?]{

}

@defproc[(fst->string [fst fst-like?]) string?]{

}


@subsection{Derived Utilities}

@defmodule[openfst/utils]

@defproc[(fst-add-weight [fst fst-like?] [weight real?]) fst?]{
  Creates a new FST equivalent to @racket[fst], except that every path through
  the FST has @racket[weight] added to it.

  This is accomplished by adding an 𝛆 transition to the start of @racket[fst] with the given
  @racket[weight].
}

@defproc[(fst-insert [fst fst-like?] [#:weight weight real? 0]) fst?]{
  Create a new FST that accepts @racket[""] and produces the language of the given
  @racket[fst]. This function is nearly equivalent to
  @racket[(fst-cross "" fst)]. If a @racket[weight] is provided this weight is
  applied to the resulting FST.

  This function has the effect of replacing the input-label of every arc in the input
  FST with 𝛆.
}

@defproc[(fst-delete [fst fst-like?] [#:weight weight real? 0]) fst?]{
  Create a new FST that accepts the language of the given @racket[fst] and
  produces @racket[""]. This function is nearly equivalent to
  @racket[(fst-cross fst "")]. If a @racket[weight] is provided this weight is
  applied to the resulting FST.

  This function has the effect of replacing the output-label of every arc in the input
  FST with 𝛆.
}

@defproc[(fst-join [fst1 fst-like?] [fst2 fst-like?]) fst?]{
  Create a new FST that is equivalent to (@racket[fst1] (@racket[fst2] @racket[fst1])*)
}

@defproc[(fst-rewrite [fst fst-like?] [input string?]) (or/c string #f)]{
  rewrites the given input string with the given FST. If the FST cannot accept @racket[input] then
  @racket[#f] is returned, otherwise the rewritten string is returned. If the FST can accept the
  input string this is equivalent to
  @racket[(fst->string (fst-shortest-path (fst-compose input fst)))].
}


@section{Direct Automata Access}


@defproc[(make-fst) fst?]{
 Creates a new empty finite state transducer.
}

@defproc[(fst-add-state! [fst fst?]) exact-nonnegative-integer?]{
 Mutate the given @racket[fst] adding a new state and returns that state's id. Generally states
 start at 0 and increase sequentially, but probably not a good idea to count on this.
}

@defproc[(fst-add-arc! [fst fst?] [state exact-nonnegative-integer?] [arc arc?]) void?]{
 Mutates the given @racket[fst] adding a transition @racket[arc] initiating at @racket[state].
}

@defproc[(fst-set-start! [fst fst?] [state exact-nonnegative-integer?]) void?]{
 Mutates the given @racket[fst] re-assigning the start state to the given @racket[state]. The
 provided @racket[state] must already be in the FST. The state that was previously the start
 state will no longer be.
}

@defproc[(fst-set-final! [fst fst?] [state exact-nonnegative-integer?] [weight real?]) void?]{
 Mutates the given @racket[fst], setting the final weight for @racket[state]. This value represents
 the weight that will be added to a path that ends at this state. A value of @racket[+inf.0]
 is the default weight for all states and indicates that a path may not end at this state
 (a non-final state).
}

@defproc[(fst-num-states [fst fst?]) exact-nonnegative-integer?]{
 Returns the total number of states in @racket[fst].
 This is equivalent to @racket[(length (fst-states fst))], though somewhat more efficient.
}

@defproc[(fst-num-arcs [fst fst?] [state exact-nonnegative-integer?]) exact-nonnegative-integer?]{
 Returns the total number of arcs coming from @racket[state] in @racket[fst].
 This is equivalent to @racket[(length (fst-arcs fst state))], though somewhat more efficient.
}

@defproc[(fst-start [fst fst?]) (or/c #f exact-nonnegative-integer?)]{
 Returns the state id of the start state for the given @racket[fst]. If the FST does not have a
 start state, either because it is empty
 or invalid, returns @racket[#false].
}

@defproc[(fst-final [fst fst?] [state exact-nonnegative-integer?]) real?]{
 Returns the final weight associated with the given state. This represents the weight that will be
 added to a path that ends on this state. Final states will have finite weights while non-final
 states have a weight of @racket[+inf.0].
}

@defproc[(fst-states [fst fst?]) (listof exact-nonnegative-integer?)]{
 Returns a list of the state ids present in @racket[fst].

 Example:
 @racketblock[
 (for/list ([state (fst-states fst)])
   (cons state (fst-final fst state)))
 ]
}

@defproc[(fst-arcs [fst fst?] [state exact-nonnegative-integer?]) (listof arc?)]{
 Returns a list of the arcs originating from @racket[state] in @racket[fst].

 Example:
 @racketblock[
 (for/list ([arc (fst-arcs fst state)])
   (arc-next-state arc))
 ]
}

@subsection{Transition Arcs}

Arcs represented transitions between states in an finite-state transducer. Each arc consists of a
in-label, an out-label, a weight and a next state. Arcs are added to the automata at the states
from which they originate.

As an implementation note, arc objects are in fact pointers to underlying C++ objects in foreign
memory. From the perspective of the user, however they conform to the @racket[struct] interface.

@defproc[(arc? [v any/c]) boolean?]{
 Returns @racket[#true] if the given @racket[v] is a finite-state transducer arc.
}

@defproc[(arc [ilabel (or/c char? exact-nonnegative-integer?)]
              [olable (or/c char? exact-nonnegative-integer?)] [weight real?]
              [next-state exact-nonnegative-integer?]) arc?]{

}

@deftogether[
 (@defproc[(arc-ilabel (arc arc?)) exact-nonnegative-integer?]
   @defproc[(arc-olabel (arc arc?)) exact-nonnegative-integer?]
   @defproc[(arc-weight (arc arc?)) real?]
   @defproc[(arc-next-state (arc arc?)) exact-nonnegative-integer?])]{

}


@bibliography[
 @bib-entry[#:key "pynini"
            #:title "Pynini: A Python library for weighted finite-state grammar compilation"
            #:author "K. Gorman"
            #:date "2016"
            #:location "Proc. ACL Workshop on Statistical NLP and Weighted Automata, 75-80"
            #:url "https://pypi.org/project/pynini/"]
 @bib-entry[#:key "openfst"
            #:title "OpenFst: A General and Efficient Weighted Finite-State Transducer Library"
            #:author "Cyril Allauzen, M. Riley, J. Schalkwyk, Wojciech Skut, Mehryar Mohri"
            #:date "16 July 2007"
            #:url "https://www.openfst.org"]
 ]

