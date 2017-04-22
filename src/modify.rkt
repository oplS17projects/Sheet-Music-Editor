#lang racket

(require "core.rkt")

(define max-staves 3)

; EDIT INFO MODIFIERS

; Change the current note index
; Change is the number of notes to move it
;   Negative is left, positive is right
;   Typically, this will be +1 or -1
(define (change-current-note-index score edit-info change)
  (if (or (< (+ (get-current-index edit-info) change) 0)
          (> (+ (get-current-index edit-info) change)
             (+ 1 (length (get-notes (get-staff score (get-current-staff edit-info)))))))
      edit-info
      (make-edit-info (get-current-staff edit-info)
                      (+ (get-current-index edit-info) change))))
; Some short-hand procedures
(define (move-to-next-note score edit-info)
  (change-current-note-index score edit-info 1))
(define (move-to-previous-note score edit-info)
  (change-current-note-index score edit-info -1))

; Change current staff
; Will be selected from drop-down
(define (change-current-staff edit-info staff-index)
  (make-edit-info staff-index (get-current-index edit-info)))


; NOTE MODIFIERS

; Shifts note up or down
; shift is the number of half-steps to shift
; A negative value represents down and positive value up
(define (shift-note note shift)
  (if (= R (get-note (get-pitch note)))
      note
      (make-note (midi-to-pitch (+ shift (pitch-to-midi (get-pitch note))))
                 (get-duration note))))

; ***MAP***
; Adds note to end of staff
(define (add-note score staff-index note-length note-name)
  (make-score (get-time-sig score)
              (get-tempo score)
              (indexed-map (lambda (s i)
                             (if (equal? staff-index i)
                                 (make-staff (get-clef s)
                                             (get-key-sig s)
                                             (append (get-notes s)
                                                     (list (make-note
                                                            (make-pitch note-name
                                                                        (get-nearest-octave
                                                                         (last (get-notes s))
                                                                         note-name))
                                                            (calculate-duration
                                                             (get-time-sig score)
                                                             note-length)))))
                                 s))
                           (get-staves score))))


; TRANSPOSITION PROCEDURES

; Transpose staff
; Shift is the number of half-steps to shift
(define (transpose-staff score staff-index shift)
  (make-score (get-time-sig score)
              (get-tempo score)
              (indexed-map (lambda (s i)
                             (if (equal? staff-index i)
                                 (make-staff (get-clef s)
                                             (get-key-sig s)
                                             (map (lambda (n) (shift-note n shift))
                                                  (get-notes s)))
                                 s))
                             (get-staves score))))


; STAFF/SCORE MODIFIERS

; ***MAP***
; Change key signature of a staff
(define (change-key-signature score staff-index note-name)
  (make-score (get-time-sig score)
              (get-tempo score)
              (indexed-map (lambda (s i)
                             (if (equal? staff-index i)
                                 (make-staff (get-clef s)
                                             (make-key-sig note-name)
                                             (get-notes s))
                                 s))
                           (get-staves score))))

; Change time signature of a score
(define (change-time-signature score upper lower)
  (make-score (make-time-sig upper lower)
              (get-tempo score)
              (get-staves score)))

; Change tempo of a score
(define (change-tempo score tempo)
  (make-score (get-time-sig score)
              tempo
              (get-staves score)))

; Add a staff to the score
(define (add-staff score clef key-name)
  (if (< (length (get-staves score)) max-staves)
      (make-score (get-time-sig score)
                  (get-tempo score)
                  (append (get-staves score)
                          (list (make-staff clef
                                            (make-key-sig key-name)
                                            '()))))
      score))


; UTILITY PROCEDURES

; ***MAP***
; Map procedure that keeps track of index
(define (indexed-map proc lst)
  (define (imap-helper lst result index)
    (if (null? lst)
        result
        (imap-helper (cdr lst) (append result (list (proc (car lst) index))) (+ index 1))))
  (imap-helper lst '() 0))

; Converts a pitch to a midi number
(define (pitch-to-midi pitch)
  (+ (get-note pitch) (* (- (get-octave pitch) 1) 12)))
; Converts a midi number to a pitch
(define (midi-to-pitch midi)
  (make-pitch (modulo midi 12) (+ 1 (floor (/ midi 12)))))

; For adding a new note, finds best octave for new note based on previous note
(define (get-nearest-octave previous-note note-name)
  (let ([previous-octave (get-octave (get-pitch previous-note))]
        [base-score (pitch-to-midi (get-pitch previous-note))])
    (let ([same-octave-score (abs (- (pitch-to-midi (make-pitch note-name previous-octave))
                                     base-score))]
          [up-octave-score (abs (- (pitch-to-midi (make-pitch note-name (+ previous-octave 1)))
                                   base-score))]
          [down-octave-score (abs ( - (pitch-to-midi (make-pitch note-name (- previous-octave 1)))
                                      base-score))])
      (cond [(and (< same-octave-score up-octave-score) (< same-octave-score down-octave-score))
             previous-octave]
            [(and (< up-octave-score same-octave-score) (< up-octave-score down-octave-score))
             (+ previous-octave 1)]
            [else (- previous-octave 1)]))))

; Calculates duration of new note based on note-length and time signature
(define (calculate-duration time-sig note-length)
  (* note-length (get-lower time-sig)))


(define n (make-note (make-pitch C 4) 4))
(define st (make-staff 'Treble (make-key-sig F) (list n n n n n)))
(define sc (make-score (make-time-sig 4 4) 100 (list st st)))