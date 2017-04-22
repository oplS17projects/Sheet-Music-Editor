#lang racket

(require "core.rkt")

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

; Change current staff
; Will be selected from drop-down
(define (change-current-staff edit-info staff-index)
  (make-edit-info staff-index (get-current-index edit-info)))


; ***MAP***
; Map procedure that keeps track of index
(define (indexed-map proc lst)
  (define (imap-helper lst result index)
    (if (null? lst)
        result
        (imap-helper (cdr lst) (append result (list (proc (car lst) index))) (+ index 1))))
  (imap-helper lst '() 0))

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

; Converts a pitch to a midi number
(define (pitch-to-midi pitch)
  (+ (get-note pitch) (* (- (get-octave pitch) 1) 12)))

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