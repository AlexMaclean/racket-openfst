#lang scribble/manual
@require[scribble/eval
         @for-label[racket/base openfst racket/stream racket/contract racket/math openfst/utils]]

@title{OpenFst: Racket Bindings}

@author[(author+email "Alex MacLean" "alex@alex-maclean.com")]

@defmodule[openfst]

This package provides Racket bindings for OpenFst, "a library for constructing, combining,
optimizing, and searching @italic{weighted finite-state transducers} (FSTs)" @cite["openfst"].
Extensions to OpenFst based on the Python package @tt{pynini} are also included @cite["pynini"].

@section{Getting Started}

A weighted finite-state transducers (FSTs) is a type of automata that consists of:

@itemlist[
 @item{A set of states, represented by natural numbers. Each state is also assigned a final
  weight representing the weight of terminating computation in this state (Infinity is used to
  represent non-final states).}
 @item{A set of arcs (or transitions) between states, consisting of a current and a next state,
  an input and output label, and a weight. labels are integers representing the unicode encoding
 of characters with 0 represinging ε, or no-character.}
 @item{A special state designated as the start state, from which computation begins. Empty or
  non-sane FSTs may lack a start state.}]

This library provides a high- and low-level for interacting with FSTs. The high-level abstract
functional interface contains functions
over FSTs such as @racket[fst-union] and @racket[fst-compose]. The low-level direct interface
allows for inspection and stateful mutation and of the structure of an FST.

@subsection{Example: Thousand Separators}
To better understand what FSTs are and how OpenFST enables their use, we'll performs some
simple formatting tasks on natural numbers. First consider the task of adding commas after
every third digit as thousand separators, that is:
@centered{
 @racket["7577130400"] → @racket["7,577,130,400"]
}

To do this, we first define an FST that accepts any single digit called @racket[digit]. Next, we
take the closure over this FST with a lower and upper bound of 3. The resulting FST, @racket[digits3],
will accept only strings of exactly 3 digits and rewrite them unchanged.

@racketblock[
 (define digit (fst-union "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"))
 (define digits3 (fst-closure digit #:lower 3 #:upper 3))
 ]

Next we add a comma inserting FST before @racket[digits3] and take the Kleene @tt{*} of this to get
@racket[digits3*]. The resulting FST will accept a string of digits with length divisible by 3 and
insert a comma before every 3rd digit. Finally we concatenate this FST with an FST taking 1, 2, or 3
digits representing the leading digit of the number, to produce @racket[add-commas-fst].

@racketblock[
 (define digits3*
   (fst-closure (fst-concat (fst-cross "" ",") digits3)))
 (define add-commas-fst
   (fst-concat (fst-closure digit #:lower 1 #:upper 3)
               digits3*))
 ]

To actually apply this FST to a string we use @racket[fst-compose] to implicitly convert the
string to an FST itself and then compose that FST with the one we build for thousand separation.
Finally, we convert the resulting FST back into a string. For the purposes of this example we do
this explicitly, but @racket[fst-rewrite] wraps this functionality up nicely.

@racketblock[
 (define (add-commas number-string)
   (fst->string
    (fst-compose number-string add-commas-fst)))
 ]

@(define helper-eval (make-base-eval))
@interaction-eval[#:eval helper-eval
                  (require openfst openfst/utils)]

@interaction-eval[
 #:eval helper-eval
 (define digit (fst-union "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"))
 (define digits3 (fst-closure digit #:lower 3 #:upper 3))
 (define digits3* (fst-closure (fst-concat (fst-cross "" ",") digits3)))
 (define add-commas-fst (fst-concat (fst-closure digit #:lower 1 #:upper 3) digits3*))

 (define (add-commas number-string)
   (fst->string
    (fst-compose number-string add-commas-fst)))
 ]
@examples[
 #:eval helper-eval
 (add-commas "7577130400")
 (add-commas "81")
 (add-commas "100000")
 ]

@subsection{Example: Leading Zeros}

To see how weights can be applied to FSTs, consider the problem of removing leading zeros from
a number. While this task can be accomplished with an unweighted-FST, introducing weights
simplifies the solution.

@centered{
 @racket["007"] → @racket["7"]
}

The leading-zero removing transducer is defined as the concatenation of an FST that removes zero
or more @racket["0"]s and an FST that accepts one or more digits. While the second FST could process
the leading @racket["0"]s without removing them, this path will have more weight associated with it.

@racketblock[
 (define leading-0s
   (fst-concat (fst-closure (fst-cross "0" ""))
               (fst-closure (fst-add-weight digit 1.0) #:lower 1)))
 ]

Note that this FST can be composed with the thousand separator from the previous problem into a
single new FST. When applying this FST, @racket[fst-shortest-path] must be used since now multiple
computations exist for some strings.

@racketblock[
 (define cleanup-fst (fst-compose leading-0s add-commas-fst))

 (define (cleanup-number number-string)
   (fst->string
    (fst-shortest-path
     (fst-compose number-string cleanup-fst))))
 ]

@interaction-eval[
 #:eval helper-eval
 (define leading-0s
   (fst-concat (fst-closure (fst-cross "0" ""))
               (fst-closure (fst-add-weight digit 10.0) #:lower 1)))

 (define cleanup-fst (fst-compose leading-0s add-commas-fst))

 (define (cleanup-number number-string)
   (fst->string
    (fst-shortest-path
     (fst-compose number-string cleanup-fst))))
 ]
@examples[
 #:eval helper-eval
 (cleanup-number "07577130400")
 (cleanup-number "00000000")
 (cleanup-number "100000")
 ]


@section{Abstract Automata Manipulation}

@defproc[(fst? [v any/c]) boolean?]{
 Returns @racket[#true] if the given @racket[v] is a finite-state transducer. 
}

@defproc[(fst-like? [v any/c]) boolean?]{
 Returns @racket[(or (string? v) (fst? v))]. Nearly all of the
 following functions accept FST-like arguments and convert strings to FSTs with @racket[fst-accept].
}

@defproc[(fst-accept [str string?] [#:weight weight real? 0]) fst?]{
 Constructs a new FST that accepts the given @racket[str] at the given @racket[weight].
 This FST takes the form of a chain of states each connected to the next by a single
 arc with weight 0 and an input and output lable corresponding to a character in the
 input string. The final state has a weight of @racket[weight].
}

@defproc[(fst-cross [fst1 fst-like?] [fst2 fst-like?]) fst?]{
 Creates a new FST that accepts input strings from the langauge of @racket[fst1] and
 produces output strings in the language of @racket[fst2].

 @examples[
 #:eval helper-eval
 (fst-rewrite (fst-cross "hello" "world") "hello")
 ]

}

@defproc[(fst-closure [fst fst-like?] [#:lower lower exact-nonnegative-integer? 0]
                      [#:upper upper (or/c #f exact-positive-integer?) #f]) fst?]{
 Produces an FST that accepts strings in the language of @racket[fst] repeated between @racket[lower]
 and @racket[upper] times. If @racket[upper] is @racket[#false], then strings may be repeated an
 infinite number of times.

 @itemlist[
 @item{@racket[(fst-closure fst)] is equivalent to the Kleene @tt{*}.}
 @item{@racket[(fst-closure fst #:lower 1)] is equivalent to the Kleene @tt{+}.}
 @item{@racket[(fst-closure fst #:upper 1)] is equivalent to the @tt{?}.}
 ]

 @examples[
 #:eval helper-eval
 (define f (fst-closure (fst-cross "A" "B") #:lower 2))
 (fst-rewrite f "AAAAA")
 (fst-rewrite f "AA")
 (fst-rewrite f "A")
 ]

}

@defproc[(fst-union [fst fst-like?] ...+) fst?]{
 Create a new FST representing the union (or sum) of the given FSTs. The resulting FSTs will transduce
 all the strings in the input FSTs to all the correpsonding ouput strings.
}

@defproc[(fst-compose [fst fst-like?] ...+) fst?]{
 Create a new FST that has the effect of applying each of the given FSTs in order. This operation
 is also useful because it can be used to rewrite a string repersended as an acceptor FST.

 @examples[
 #:eval helper-eval
 (define more+s (fst-closure (fst-cross "+" "++")))
 (fst->string (fst-compose "+" more+s))
 (fst->string (fst-compose "+" more+s more+s more+s))
 ]
}

@defproc[(fst-concat [fst fst-like?] ...+) fst?]{
 Construct a new FST that transduces strings that are a concatentation of the strings of the input
 FST.

 @examples[
 #:eval helper-eval
 (define f (fst-concat (fst-cross "a" "b") (fst-cross "x" "y")))
 (fst-rewrite f "ax")
 (fst-rewrite f "a")
 ]
}

@defproc[(fst-project [fst fst-like?] [type (or/c 'input 'output)]) fst?]{
 Given a transducer @racket[fst], produces an acceptor that accepts either the input or the
 output language. This is accomplished by replacing the in-lables of every arc with the out-lables
 or vice verssa.

 @examples[
 #:eval helper-eval
 (define A->B (fst-cross "A" "B"))
 (fst->string (fst-project A->B 'input))
 (fst->string (fst-project A->B 'output))
 ]

}

@defproc[(fst-shortest-path [fst fst-like?] [n exact-positive-integer? 1]) fst?]{
 Constructs a new FST representing the @racket[n] shortest paths through the given FST.
}

@defproc[(fst->string [fst fst-like?]) string?]{
 If there is only one possible path through the given FST prodcues a string by walking
 this path and adding all output-lables to a string. If there
 are multiple paths an error is printed and @racket[""] is returned.
}

@defproc[(fst-inverse [fst fst-like?]) fst?]{
 Creates a new FST that has oposite input and output langages as the given @racket[fst]. This is
 accomplished by switching the input and output labels on every arc.

  @examples[
 #:eval helper-eval
 (define f (fst-inverse (fst-cross "hello" "world")))
 (fst-rewrite f "world")
 ]
}

@defproc[(fst-reverse [fst fst-like?]) fst?]{
 Creates a new FST that accepts the reverse of the strings in the given FST and produces the reverse
 of the products.

 @examples[
 #:eval helper-eval
 (define f (fst-reverse (fst-cross "hello" "world")))
 (fst-rewrite f "olleh")
 ]
}

@defproc[(fst-optimize [fst fst-like?]) fst?]{
Creates a new FST with the same effect as the provided FST but possibly with fewer states and
arcs.
}

@defproc[(fst-difference [fst1 fst-like?] [fst2 fst-like?]) fst?]{
 Create an FST acceptor that accepts all strings accepted by @racket[fst1], except those accepted
 by @racket[fst2]. Both input FSTs must be acceptors.

  @examples[
 #:eval helper-eval
 (define f (fst-difference (fst-union "a" "b" "c") "c"))
 (fst-rewrite f "a")
 (fst-rewrite f "c")
 ]
}


@defproc[(fst-sane? [fst fst-like?]) boolean?]{
 Performs a sanity check on the given FST returning @racket[#true] if all arc point to valid
 states and there is a start state for non-empty FSTs.
}


@subsection{Derived Utilities}

@defmodule[openfst/utils]

@defproc[(fst-add-weight [fst fst-like?] [weight real?]) fst?]{
 Creates a new FST equivalent to @racket[fst], except that every path through
 the FST has @racket[weight] added to it.

 This is accomplished by adding an ε transition to the start of @racket[fst] with the given
 @racket[weight].
}

@defproc[(fst-insert [fst fst-like?] [#:weight weight real? 0]) fst?]{
 Create a new FST that accepts @racket[""] and produces the language of the given
 @racket[fst]. This function is nearly equivalent to
 @racket[(fst-cross "" fst)]. If a @racket[weight] is provided this weight is
 applied to the resulting FST.

 This function has the effect of replacing the input-label of every arc in the input
 FST with ε.
}

@defproc[(fst-delete [fst fst-like?] [#:weight weight real? 0]) fst?]{
 Create a new FST that accepts the language of the given @racket[fst] and
 produces @racket[""]. This function is nearly equivalent to
 @racket[(fst-cross fst "")]. If a @racket[weight] is provided this weight is
 applied to the resulting FST.

 This function has the effect of replacing the output-label of every arc in the input
 FST with ε.
}

@defproc[(fst-join [exp fst-like?] [sep fst-like?]) fst?]{
 Create a new FST that is equivalent to @italic{(<@racket[exp]> (<@racket[sep]> <@racket[exp]>)*)
}}

@defproc[(fst-rewrite [fst fst-like?] [input string?]) (or/c string #f)]{
 rewrites the given input string with the given FST. If the FST cannot accept @racket[input] then
 @racket[#f] is returned, otherwise the rewritten string is returned. If the FST can accept the
 input string this is equivalent to:
 @racketblock[
 (fst->string (fst-shortest-path (fst-compose input fst)))
 ]
}


@section{Direct Automata Access}


@defproc[(make-fst [state-info
                    (cons/c
                     (or/c symbol? (list/c symbol? real?))
                     (listof (list/c label? label? real? symbol?)))] ...) fst?]{
 Creates a new finite state transducer given a series of s-expressions representing states.
 The first element in each list is either a symbol used to refer to the state or a list containing
 the symbol and a final weight to be assigned to this state. Without a weight states receive a weight
 of @racket[+inf.0]. The elements in the list after this are quadruples of arguments passed to
 @racket[arc]. The first element in the list is assigned the role of start state. Note that the
 symbols used for the states do not persist beyond construction of the FST.

 Example:
 @racketblock[
 (make-fst
  '(a (#\A #\B 1 a)
      (#\B #\C 1 b))
  '((b 0) (#\A #\B 1 a)))
 ]
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
}

@defproc[(fst-arcs [fst fst?] [state exact-nonnegative-integer?]) (listof arc?)]{
 Returns a list of the arcs originating from @racket[state] in @racket[fst].
}


@subsection{Transition Arcs}

Arcs represented transitions between states in an finite-state transducer. Each arc consists of a
in-label, an out-label, a weight, and a next state. Arcs are added to the automata at the states
from which they originate.

As an implementation note, arc objects are in fact pointers to underlying C++ objects in foreign
memory. From the perspective of the user, however they conform to the @racket[struct] interface.

@defproc[(arc? [v any/c]) boolean?]{
 Returns @racket[#true] if the given @racket[v] is a finite-state transducer arc.
}

@defproc[(label? [v any/c]) boolean?]{
 Returns @racket[#true] if the given @racket[v] is suitable for use as an input or
 output label for an arc. Equivalent to @racket[(or (exact-nonnegative-integer? v) (char? v))]
}

@defproc[(arc [ilabel label?] [olable label?] [weight real?]
              [next-state exact-nonnegative-integer?]) arc?]{
 Create a new arc object.
}

@deftogether[
 (@defproc[(arc-ilabel (arc arc?)) exact-nonnegative-integer?]
   @defproc[(arc-olabel (arc arc?)) exact-nonnegative-integer?]
   @defproc[(arc-weight (arc arc?)) real?]
   @defproc[(arc-next-state (arc arc?)) exact-nonnegative-integer?])]{
 Accessor methods for an arc object. Note that even when arcs are constructed with character
 labels these values are represented internal as integers so @racket[arc-ilabel] and
 @racket[arc-olabel] will return the corresponding integer.

}

@section{Limitations}

This library currently only supports @tt{x86_64} architecture. Getting it working on different
hardware @italic{should} be as simple as running the build script corresponding to the OS
in the @tt{lib/} directory of the GitHub Repo, but I haven't tested this...

While it should not be visible to the consumers of this library, the Windows implemenation of
this library is using an unoffical port of OpenFST @cite["winfst"] Because the offical OpenFST
distrobution does not support Windows. 

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
 @bib-entry[#:key "winfst"
            #:title "OpenFST port for Windows"
            #:url "https://github.com/kkm000/openfst"]
 ]

