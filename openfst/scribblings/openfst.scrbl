#lang scribble/manual
@require[@for-label[racket/base]]

@title{OpenFST}

@author[(author+email "Alex MacLean" "alex@alex-maclean.com")]


@defmodule[openfst]

Package Description Here



@section{Direct Transducer Access}


@defproc[(make-fst) FST?]{
  A
}

@defproc[(fst-add-state! [fst FST?]) natural?]{
  A
}

@defproc[(fst-add-states! [fst FST?] [n natural?]) void?]{
  A
}

@defproc[(fst-add-arc! [fst FST?] [state natural?] [arc Arc?]) void?]{
  A
}

@defproc[(fst-set-start! [fst FST?] [state natural?]) void?]{
  A
}

@defproc[(fst-set-final! [fst FST?] [state natural?] [weight real?]) void?]{
  A
}


@defproc[(fst-num-states [fst FST?]) natural?]{
  A
}

@defproc[(fst-num-arcs [fst FST?] [state natural?]) natural?]{
  A
}

@defproc[(fst-start [fst FST?]) natural?]{
  A
}

@defproc[(fst-weight [fst FST?] [state natural?]) real?]{
  A
}



 [rename Fst-InputSymbols fst-input-symbols (FST? . -> . any/c)]
 [rename Fst-OutputSymbols fst-output-symbols (FST? . -> . any/c)]

 [fst-states (FST? . -> . (stream/c natural?))]
 [fst-arcs (FST? natural? . -> . (stream/c Arc?))]

 [Arc (label? label? real? natural?  . -> . Arc?)]
 [Arc-ilabel (Arc? . -> . natural?)]
 [Arc-olabel (Arc? . -> . natural?)]
 [Arc-weight (Arc? . -> . real?)]
 [rename Arc-nextstate Arc-next-state (Arc? . -> . natural?)])