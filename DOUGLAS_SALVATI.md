# Sheet Music Editor in Racket

## Douglas Salvati
### 30 April, 2017

# Overview
The Sheet Music editor is an interactive application which lets you create, edit, play, and export sheet music.
My contributions primarily involved the modules

(a) **Draw**, which turns the internal music representation into a graphic, and

(b) **Export**, which allows export of the graphic to PDF format, as well as the ability to save and load our own
native file format (basically just a Racket list).

[Draw](/src/draw.rkt) itself consists of several modules.  First, the size of the document is calculated and a border
is drawn for the page.  Then, blank staves (a set of one or more sets of 5 lines) are drawn until the end of the page
is reached.  Next, the time signatures and key signatures are written, followed by the notes themselves.  The result is
a bitmap image which can either be written to a PDF file or to a frame in the [GUI](src/ui.rkt), written by
[Matthew DiBello](https://github.com/mdibello).

Export makes use of Draw but also writes the name of the document on top of the page to make the PDF document suitable for
printing and distributing. To save the user's score, we simply dump the list representing the notes, referred to as the
`global-score` into a file.  Later, when loading, we read the contents of this file and `set!` the `global-score` to its contents.
Please refer to the sample [PDF](/sample/sample.pdf) and [score file](/sample/sample.scr) at these links.

**Authorship note:** All of the code described here was written by myself, though the basic code for opening a file is adapted from tutorials on the Racket webpage.

# Libraries Used
The code uses four libraries:

```
(require racket/draw)
(require racket/gui)
(require rsound)
```

* with ```racket/draw``` being the primary one for my code. It allows drawing the sheet music to an arbitrary location, abstracted
as a "Drawing Context".
* ```racket/gui``` library is used to create an interface to allow anyone to achieve what we would do in the REPL.
* ```rsound``` library allows us to listen to the sound to test the music while we're writing it.

# Key Code Excerpts

Here is a discussion of the most essential procedures, including a description of how they embody ideas from 
UMass Lowell's COMP.3010 Organization of Programming languages course.

Five examples are shown and they are individually numbered. 

## 1. Using recursion for repetitive drawing.

Although recursion is used extensively, here is a bottom-level example of using recursion to complete a drawing task.
Here, we want to draw a set of 5 bars for the staff.  This is achieved by applying the tail-recursive procedure `draw-bars-helper`,
which draws `cnt` bars until the counter is reduced to zero. In each iteration, a `begin` is used to draw a line from the
left margin to the right margin and then recurse. The y-coordinate of the line depends on the iteration number, so one line is drawn and then we request
the procedure to call itself to draw `cnt`-minus-one lines at a lower y-coordinate.
```
(define (draw-bars y)
    (define (draw-bars-helper cnt)
      (if (= cnt 0)
          'done
          (begin (send dc draw-line
                       l-margin-px
                       (+ y (* (- cnt 1) (floor (/ stave-height-px 4))))
                       (- page-width-px r-margin-px)
                       (+ y (* (- cnt 1) (floor (/ stave-height-px 4)))))
                 (draw-bars-helper (- cnt 1)))))
    (draw-bars-helper 5))
 ```
 
 At a higher level, we have more recursion.  For instance, to draw an arbitrary number of staves, we recurse through them and
 apply `draw-bars` for each one.
 
## 2. Lazy evaluation and functional programming for note locations

A note is stored as a name (C, D, E, F, G, A, or B) and an octave number.  Since its location on the staff is only important to
the Draw procedure, it is not calculated until there has been a request to draw it.  When this happens, a procedure called
`find-note-position` is applied to find the precise y-coordinate to draw the note:
```
(+ y (* (find-note-position clef key pitch) (/ stave-height-px 8)) note-offset-px))
```
The procedure relies heavily on `cond`itionals because the key signature and clef affect where a note goes:
```
(define (find-note-position clef key pitch)
  (define (line-mapper is-sharp is-flat n)
    (cond [(= n 0)  0]                                     ;; B# or C
          [(= n 1)  (if (and is-flat (is-in 'D key)) 1 0)] ;; C# or Db
          [(= n 2)  1]                                     ;; D
          [(= n 3)  (if (and is-flat (is-in 'E key)) 2 1)] ;; D# or Eb
          [(= n 4)  2]                                     ;; E  or Fb, always go with E-natural
          [(= n 5)  3]                                     ;; E# or F
          [(= n 6)  (if (and is-flat (is-in 'G key)) 4 3)] ;; F# or Gb
          [(= n 7)  4]                                     ;; G
          [(= n 8)  (if (and is-flat (is-in 'A key)) 5 4)] ;; G# or Ab
          [(= n 9)  5]                                     ;; A
          [(= n 10) (if (and is-flat (is-in 'B key)) 6 5)] ;; A# or Bb
          [else     6]                                     ;; B  or Cb or ERROR
          ))
  (define (find-position-helper note0 octave0)
    (- (* 7 (- octave0 (get-octave pitch))) (- (line-mapper (sharp? key) (flat? key) (get-note pitch))
                                               (line-mapper #f #f note0))))
  (cond [(equal? clef 'treble) (find-position-helper F 5)]
        [else (find-position-helper A 3)]))
  ```
  Rather than save state by recording all of these positions, we take a functional approach and calculate on-the-fly,
  no state modification required.
  
  In fact, Drawing uses no state modification (aside from modifying the drawing canvas, of course; in other words, no `set!` is used).
  Recursively drawing items at functionally calculated coordinates is really all there is to it.
        
## 3. Fold and map

When calculating the length of the document, we need to know how many beats there are in the score, and how many beats
per line.  The latter is a `define`d constant called `beats-per-line` while the former needs to be calculated, resulting
in the number of lines being `(/ (count-beats score) beats-per-line)`.

To count the beats, we first create a list of note durations.  To do this, we get a list of notes and `map` it with the
function `get-duration`.  This means, for instance, if there is a list of 4 half-notes, the `map` operation produces
a list '(2 2 2 2).

From there, all that needs to be done is to sum up the contents of the list, which can be achieved with a `foldl` operation,
producing 32 in this example.

```
(define (count-beats score)
  (foldl + 0 (map get-duration (get-notes (get-staff score 0)))))
```
The code is short, sweet, and powerful.

## 4. Using eval and list recursion to load files.

This part of the code called back ideas from the metacircular evaluator, where we realize that code can be passed around
as a string and processed by other code.
The 'read' call opens a `.scr` score file and recursively `loop`s as it reads in each character, accumulating a string.
Since the format of the file is a textual string representing a list (in '() notation), we can send the string to `eval`
to have it evaluated into a tree data structure.  Then, as mentioned, it is `set!` to be the `global-score` to finish
the `load` operation.

```
(define (load path)
  (begin (set! global-score (eval (read (open-input-string (call-with-input-file (string-append path ".scr")
                                                      (lambda (input-port)
                                                        (let loop ((x (read-char input-port)) (mystr ""))
                                                          (if (not (eof-object? x))
                                                              (loop (read-char input-port)(string-append mystr (string x))) mystr ))))))))
         (send music-canvas refresh)
         (set! global-edit-info (make-edit-info 0 0))))
 ```

# Acknowledgements
* "Katie" from [this site](http://midnightmusic.com.au/2013/06/the-big-free-music-notation-image-library), who provides
a set of FREE images which we used for rendering professional-quality musical notation.
* Writeup template courtesy of Professor Fred Martin, UMass Lowell.
