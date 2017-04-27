;; SHEET MUSIC EDITOR - DRAW ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#lang racket

(require racket/draw)
(require racket/gui)
(require "core.rkt")

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Namespace stuff
(define-namespace-anchor anc)
(define ns (namespace-anchor->namespace anc))

;; Document size properties
(define page-width-px 750)
(define top-margin-px 100)
(define stave-height-px 40)
(define stave-gap-px 30)
(define row-gap-px 50)
(define bottom-margin-px 100)
(define l-margin-px 20)
(define r-margin-px 20)

;; Essentially dictates how many measures we cram into a line
;;   Using TWELVE to make the code simple for 1, 2, 3, or 4 beat measures
;;   This will prevent awkward formatting
;;   The code will not work for 5, etc, because it does not divide 12
(define beats-per-line 16)

;; How much space to leave for key signature
(define clef-padding-px 5)
(define key-sig-padding-px 60)
(define time-sig-padding-px 100)
(define signature-width 150)
(define beat-size-px (/ (- page-width-px l-margin-px r-margin-px signature-width) beats-per-line))

;; Fonts
(define time-sig-font (make-font #:size (/ stave-height-px 1.5) #:family 'roman #:weight 'bold))

;; Scales for images in /img/small
;; (Images in that directory are assumed to be a certain size
;;   because there is no reason they should be changed)
(define clef-img-scale 160) ;; for Clefs
(define acc-img-scale 500)  ;; for Accidentals
(define note-img-scale 160) ;; for Notes and Rests
(define note-offset-px (- (* 2.5 (/ stave-height-px 4))))

;; No key, used for drawing objects on certain lines but to which no key applies
(define no-key (make-key-sig C))

;; Utilities ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Offsets for rests are dynamic and include (x,y components)
(define (rest-offset-px duration measure-width)
  (cond [(= duration 0.5) (cons 0 (* 1.2 (/ stave-height-px 4)))] ;; Eighth
        [(= duration 1.0) (cons 0 (* 0.5 (/ stave-height-px 4)))] ;; Quarter
        [(= duration 2.0) (cons (/ measure-width 7)
                                (* 1.5 (/ stave-height-px 4)))] ;; Half
        [(= duration 4.0) (cons (/ measure-width 3)
                                (* 1.0 (/ stave-height-px 4)))] ;; Whole
        [else (cons 0 0)]))

;; Decides the height of bitmap based on number of lines in the score
(define (decide-height score)
  (let ([num-staves (length (get-staves score))]
        [num-lines (ceiling (/ (count-beats score) beats-per-line))])
    (+ top-margin-px
       (* num-lines (+ (* num-staves stave-height-px)
                       (* (- num-staves 1) stave-gap-px)))
       (* (- num-lines 1) row-gap-px)
       bottom-margin-px)))

;; Draw a border for the document
(define (draw-border w h dc)
  (send dc draw-rectangle 0 0 w h))

;; Decide which bar the key signature icon goes on, the top bar being 0, first gap being 1, second bar 2, etc.
(define (find-position clef key pitch)
  ;; Line mapper decides the offset for each note if it were natural based on the key signature,
  ;;   C being 0.
  ;;   For instance, if (get-note pitch) is 6, the note is printed on either the F line or the
  ;;   G line, depending on the key signature
  ;;   C->0, D->1, E->2, F->3, G->4, A->5, B->6
  (define (line-mapper is-sharp is-flat n)
    (cond [(= n 0)  0]                 ;; B# or C
          [(= n 1)  (if is-sharp 0 1)] ;; C# or Db
          [(= n 2)  1]                 ;; D
          [(= n 3)  (if is-sharp 1 2)] ;; D# or Eb
          [(= n 4)  (if is-flat  3 2)] ;; E  or Fb
          [(= n 5)  (if is-sharp 2 3)] ;; E# or F
          [(= n 6)  (if is-sharp 3 4)] ;; F# or Gb
          [(= n 7)  4]                 ;; G
          [(= n 8)  (if is-sharp 4 5)] ;; G# or Ab
          [(= n 9)  5]                 ;; A
          [(= n 10) (if is-sharp 5 6)] ;; A# or Bb
          [else     (if is-flat  0 6)] ;; B  or Cb or ERROR
          ))
  ;; Helper function takes the note and octave represented by the topmost bar.
  ;;   This is because drawing will start at that position
  (define (find-position-helper note0 octave0)
    (- (* 7 (- octave0 (get-octave pitch))) (- (line-mapper (sharp? key) (flat? key) (get-note pitch))
                                               (line-mapper #f #f note0))))
  (cond [(equal? clef 'treble) (find-position-helper F 5)]
        [else (find-position-helper A 3)]))

;; See if a note is in the key signature
(define (is-in note sig)
  (if (member note (get-key-notes sig)) #t #f))

;; Similar function, but for the notes
;; There are important subtle differences
;; In the previous case, we used # or b depending on the key sig.
;; Here, we tend to prefer #
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

;; Similar function, but instead of positions returns which accidental to print
;; 0 -> none
;; 1 -> sharp
;; 2 -> natural
(define (decide-acc key pitch)
  (let ([n (get-note pitch)]
        [is-flat (flat? key)]
        [is-sharp (sharp? key)])
    (cond [(= n 0)  (if (and (is-in 'B key) is-sharp) 0 (if (is-in 'C key) 2 0))]               ;; B# or C
          [(= n 1)  (if (and (is-in 'C key) is-sharp) 0 (if (and (is-in 'D key) is-flat) 0 1))] ;; C# or Db
          [(= n 2)  (if (is-in 'D key) 2 0)]                                                    ;; D
          [(= n 3)  (if (and (is-in 'D key) is-sharp) 0 (if (and (is-in 'E key) is-flat) 0 1))] ;; D# or Eb
          [(= n 4)  (if (or (is-in 'E key) (and (is-in 'F key) is-flat)) 2 0)]                  ;; E  or Fb
          [(= n 5)  (if (and (is-in 'E key) is-sharp) 0 (if (is-in 'F key) 2 0))]               ;; E# or F
          [(= n 6)  (if (and (is-in 'F key) is-sharp) 0 (if (and (is-in 'G key) is-flat) 0 1))] ;; F# or Gb
          [(= n 7)  (if (is-in 'G key) 2 0)]                                                    ;; G
          [(= n 8)  (if (and (is-in 'G key) is-sharp) 0 (if (and (is-in 'A key) is-flat) 0 1))] ;; G# or Ab
          [(= n 9)  (if (is-in 'A key) 2 0)]                                                    ;; A
          [(= n 10) (if (and (is-in 'A key) is-sharp) 0 (if (and (is-in 'B key) is-flat) 0 1))] ;; A# or Bb
          [else     (if (or (is-in 'B key) (and (is-in 'C key) is-flat)) 2 0)]                  ;; B  or Cb (or ERROR)
          )))
    

  

;; Drawing the staves ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Draw blank staves, including clef, time sig, key, and measures
;; ***RECURSION
(define (draw-blank-staves score dc)
  ;; Internal proc to draw a set of 5 bars
  (define (draw-bars y)
    (define (draw-bars-helper cnt)
      (if (= cnt 0)
          'done
          (begin (send dc
                       draw-line
                       l-margin-px
                       (+ y (* (- cnt 1) (floor (/ stave-height-px 4))))
                       (- page-width-px r-margin-px)
                       (+ y (* (- cnt 1) (floor (/ stave-height-px 4)))))
                 (draw-bars-helper (- cnt 1)))))
    (draw-bars-helper 5))

  ;; Internal proc to draw a clef
  (define (draw-clef y type)
    (if (equal? type 'treble)
        (send dc draw-bitmap
              (make-object bitmap% "../img/small/treble.png" 'png/alpha #f #f
                (/ clef-img-scale stave-height-px))
              (+ l-margin-px clef-padding-px)
              (- y (/ stave-height-px 8)))
        (send dc draw-bitmap
              (make-object bitmap% "../img/small/bass.png" 'png/alpha #f #f
                (/ clef-img-scale stave-height-px))
              (+ l-margin-px clef-padding-px)
              (+ y (/ stave-height-px 8)))))

  ;; Internal proc to draw a key signature
  (define (draw-key-sig y clef key)
    (define (determine-octave n)
      (if (equal? clef 'treble)
          (if (or (= n A) (= n B)) 4 5)
          (if (or (= n A) (= n B)) 2 3)))
    (define (iter lst x)
      (if (null? lst)
          'done
          (begin (send dc draw-bitmap
                       (make-object bitmap% (if (sharp? key)
                                                "../img/small/sharp.png"
                                                "../img/small/flat.png")
                                                'png/alpha #f #f
                         (/ acc-img-scale stave-height-px))
                         x
                         (+ y (* (find-position clef no-key (make-pitch (eval (car lst) ns)
                                                                        (determine-octave (eval (car lst) ns))))
                                 (/ stave-height-px 8))
                            (- (/ stave-height-px 2.5))))
                 (iter (cdr lst) (+ x (/ (- time-sig-padding-px key-sig-padding-px) (length (get-key-notes key))))))))
    (iter (get-key-notes key) key-sig-padding-px))
        
  ;; Internal proc to draw a set of n staves
  (define (draw-set-of-staves n y)
    (if (= n 0)
        'done
        (let ([pos (+ y (* (- n 1) (+ stave-height-px stave-gap-px)))]
              [current-staff (get-staff score (- n 1))])
          (begin (draw-bars pos)
                 (draw-clef pos (get-clef current-staff))
                 (draw-key-sig pos (get-clef current-staff) (get-key-sig current-staff))
                 (draw-set-of-staves (- n 1) y)))))

  ;; Internal proc to draw the measure bars
  ;; n indicates how many staves
  ;; m indicates how many measures
  (define (draw-measure-bars y n m)
    (define line-height (+ (* n stave-height-px) (* (- n 1) stave-gap-px)))
    (define measure-width (/ (- page-width-px l-margin-px r-margin-px signature-width) m))
    (define (iter x cnt)
      (if (= cnt 0)
          'done
          (begin (send dc draw-line x y x (+ y line-height))
                 (iter (+ x measure-width) (- cnt 1)))))
    (begin
      ;; Draw first line
      (send dc draw-line l-margin-px y l-margin-px (+ y line-height))
      ;; Draw the rest of the lines recursively
      (iter (+ l-margin-px signature-width measure-width) m)))
  
  ;; Internal proc to draw all staves recursively
  ;; It takes the number of staves
  ;;    and the number of rows of staves in the document
  (define (draw-all-staves n rows)
    (if (= rows 0)
           'done
           (let ([y (+ top-margin-px
                       (* (- rows 1) n stave-height-px)
                       (* (- rows 1) (- n 1) stave-gap-px)
                       (* (- rows 1) row-gap-px))])
           (begin
             ;; Draw a set of staves
             (draw-set-of-staves n y)
             ;; Draw measure bars for said set
             (draw-measure-bars y n (/ beats-per-line (get-upper (get-time-sig score))))
             ;; Continue for the next one
             (draw-all-staves n (- rows 1))))))

  ;; Internal proc to draw the time signature
  ;; It takes the number of staves because the first row of
  ;;    each stave always displays the time signature
  (define (draw-time-sig n)
    (define (draw-num m y)
      (send dc
            draw-text
            (number->string m)
            (+ l-margin-px time-sig-padding-px)
            y))
    (define (iter cnt)
      (if (= 0 cnt)
          'done
          (begin
            (send dc set-font time-sig-font)
            (draw-num (get-upper (get-time-sig score)) (+ top-margin-px
                                                          (* (- cnt 1) (+ stave-height-px stave-gap-px))))
            (draw-num (get-lower (get-time-sig score)) (+ top-margin-px
                                                          (/ stave-height-px 2)
                                                          (* (- cnt 1) (+ stave-height-px stave-gap-px))))
            (iter (- cnt 1)))))
    (iter n))

  ;; Driver for this procedure
  (begin (draw-all-staves (length (get-staves score))
                          (ceiling (/ (count-beats score) beats-per-line)))
         (draw-time-sig (length (get-staves score)))))
    
;; Drawing the notes ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; *** RECURSION

(define (draw-notes score dc)
  ;; Handle drawing objects
  ;; An object is a note or a rest
  (define (draw-rest duration x y)
      (send dc draw-bitmap
            (make-object bitmap%
              (let ([lower (get-lower (get-time-sig score))])
                (cond [(= duration (* 0.125 lower)) "../img/small/eighth_rest.png"]
                    [(= duration (* 0.250 lower)) "../img/small/quarter_rest.png"]
                    [(= duration (* 0.500 lower)) "../img/small/half_rest.png"]
                    [(= duration (* 1.000 lower)) "../img/small/whole_rest.png"]))
            'png/alpha #f #f
            (/ note-img-scale stave-height-px))
      (+ x (car (rest-offset-px (/ (* 4 duration) (get-lower (get-time-sig score)))
                                (/ (- page-width-px l-margin-px r-margin-px)
                                   (/ beats-per-line (get-lower (get-time-sig score)))))))
      (+ y (cdr (rest-offset-px (/ (* 4 duration) (get-lower (get-time-sig score)))
                                0)))))
  
  (define (draw-note clef key pitch duration x y)
    (begin
      ;; Note
      (send dc draw-bitmap
          (make-object bitmap%
            (let ([lower (get-lower (get-time-sig score))])
              (cond [(= duration (* 0.125 lower)) "../img/small/eighth.png"]
                    [(= duration (* 0.250 lower)) "../img/small/quarter.png"]
                    [(= duration (* 0.500 lower)) "../img/small/half.png"]
                    [(= duration (* 1.000 lower)) "../img/small/whole.png"]))
            'png/alpha #f #f
            (/ note-img-scale stave-height-px))
          x
          (+ y (* (find-note-position clef key pitch) (/ stave-height-px 8)) note-offset-px))
      ;; Accidental
      (send dc draw-bitmap
          (make-object bitmap%
            (let ([acc (decide-acc key pitch)])
              (cond [(= acc 0) "fakepath"] ;; no path => no image
                    [(= acc 1) "../img/small/sharp.png"]
                    [(= acc 2) "../img/small/natural.png"]))
            'png/alpha #f #f
            (/ acc-img-scale stave-height-px))
          (- x 10)
          (+ y (* (find-note-position clef key pitch) (/ stave-height-px 8)) note-offset-px))))
  
  (define (draw-obj clef key obj x y beat)
    (begin (if (rest? obj)
               (draw-rest (get-duration obj) x y)
               (draw-note clef key (get-pitch obj) (get-duration obj) x y))
           (cons
            (if (> (+ beat (get-duration obj)) beats-per-line)
                (- 0 (* beat-size-px (- beat 1)))
                (* (get-duration obj) beat-size-px))
            (if (> (+ beat (get-duration obj)) beats-per-line)
                (let ([n (length (get-staves score))])
                     (+ (* n stave-height-px)
                     (* (- n 1) stave-gap-px)
                     row-gap-px))
                0))))

  (define (update-beat beat delta)
    (if (> (+ beat delta) beats-per-line)
        1
        (+ beat delta)))

  ;; Draws all musical objects in the list 'objs'
  (define (draw-notes-on-stave stave y)
    (define (iter objs x y beat)
      (if (null? objs)
        'done
        (let* ([deltas (draw-obj (get-clef stave) (get-key-sig stave) (car objs) x y beat)]
               [dx (car deltas)]
               [dy (cdr deltas)])
          (iter (cdr objs) (+ x dx) (+ y dy)
                (update-beat beat (get-duration (car objs)))))))
    (iter (get-notes stave) (+ l-margin-px signature-width (/ beat-size-px 16)) y 1))
  
  ;; Draw all notes
  (define (draw-all-notes score)
    (define (iter staves y)
      (if (null? staves)
          'done
          (begin (draw-notes-on-stave (car staves) y)
                 (iter (cdr staves) (+ y stave-height-px stave-gap-px)))))
    (iter (get-staves score) top-margin-px))
  
  ;; Driver
  (draw-all-notes score))

;; Main driver ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (draw score dc)
  ;; Local definitions
  (define page-height-px (decide-height score))
  ;; Each of the following procedures are modular
  ;;   except render, so they can be called in any
  ;;   order and will not damage each other
  (begin
    ;; Draw a border for the document
    (draw-border page-width-px page-height-px dc)
    ;; Draw all the empty staves
    (draw-blank-staves score dc)
    ;; Draw notes onto the staves
    (draw-notes score dc)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide (all-defined-out))