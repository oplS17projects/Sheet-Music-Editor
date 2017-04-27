#lang racket

; Note names
(define R -1) ; rest
(define B# 0)
(define C 0)
(define C# 1)
(define Db 1)
(define D 2)
(define D# 3)
(define Eb 3)
(define E 4)
(define Fb 4)
(define E# 5)
(define F 5)
(define F# 6)
(define Gb 6)
(define G 7)
(define G# 8)
(define Ab 8)
(define A 9)
(define A# 10)
(define Bb 10)
(define B 11)
(define Cb 11)

; A pitch stores the note name and octave number
(define (make-pitch note octave)
  (cons note octave))
(define get-note car)
(define get-octave cdr)

; A note stores a pitch and its duration in beats
(define (make-note pitch duration)
  (cons pitch duration))
(define get-pitch car)
(define get-duration cdr)
(define (rest? note)
  (= (get-note (get-pitch note)) R))

; Key Signature
(define (make-key-sig note-name)
  (cond [(= note-name G) (cons 'sharp '(F))]
        [(= note-name D) (cons 'sharp '(F C))]
        [(= note-name A) (cons 'sharp '(F C G))]
        [(= note-name E) (cons 'sharp '(F C G D))]
        [(= note-name B) (cons 'sharp '(F C G D A))]
        [(= note-name F#) (cons 'sharp '(F C G D A E))]
        [(= note-name C#) (cons 'sharp '(F C G D A E B))]
        [(= note-name F) (cons 'flat '(B))]
        [(= note-name Bb) (cons 'flat '(B E))]
        [(= note-name Eb) (cons 'flat '(B E A))]
        [(= note-name Ab) (cons 'flat '(B E A D))]
        [(= note-name Db) (cons 'flat '(B E A D G))]
        [(= note-name Gb) (cons 'flat '(B E A D G C))]
        [(= note-name Cb) (cons 'flat '(B E A D G C F))]
        [else (cons 'CMajor '())]))
(define get-key-type car)
(define get-key-notes cdr)
(define (sharp? key-sig) (equal? (get-key-type key-sig) 'sharp))
(define (flat? key-sig) (equal? (get-key-type key-sig) 'flat))

; A staff is a list of notes
; Clef is either 'Treble or 'Bass
(define (make-staff clef key-sig notes)
  (list clef key-sig notes))
(define get-clef car)
(define get-key-sig cadr)
(define get-notes caddr)

; Time signature
; Lower should be powers of 2
(define (make-time-sig upper lower)
  (cons upper lower))
(define get-upper car)
(define get-num-beats get-upper)
(define get-lower cdr)
(define get-beat-unit get-lower)

; A score is list of staves
; Tempo is defined in beats per minute
(define (make-score time-sig tempo staves)
  (list time-sig tempo staves))
(define get-time-sig car)
(define get-tempo cadr)
(define get-staves caddr)
; ***RECURSION
(define (get-staff score index)
  (define (get-staff-helper staves index)
    (if (> index 0)
        (get-staff-helper (cdr staves) (- index 1))
        (car staves)))
  (get-staff-helper (get-staves score) index))
; Number of beats in the score
; ***FOLD&MAP
(define (count-beats score)
  (foldl + 0 (map get-duration (get-notes (get-staff score 0)))))

; Stores info on current editing status
; Index indicates which element of the list of notes is being edited
(define (make-edit-info staff index)
  (cons staff index))
(define get-current-staff car)
(define get-current-index cdr)
(define (inc-current-index obj) (make-edit-info (get-current-staff obj)
                                                (+ (get-current-index obj) 1)))

; Lets us unit test
(provide (all-defined-out))