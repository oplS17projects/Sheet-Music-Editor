#lang racket

(require rsound)
(require "core.rkt")
(require "modify.rkt")

;; UTILITY FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define frames-per-second 25000)

(define (seconds-to-frames seconds)
  (* seconds frames-per-second))

(define (calculate-frames duration tempo)
  (ceiling (seconds-to-frames (* 60 (/ duration tempo)))))

(define (midi-to-freq num)
  (* (/ 440 32) (expt 2 (/ (- num 9) 12))))

(define (pitch-to-freq pitch)
  (midi-to-freq (pitch-to-midi pitch)))


;; PLAY FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (play-staff score staff-index)
  (let ([notes (get-notes (get-staff score staff-index))])
    (define (play-iter notes)
      (if (null? notes)
          #t
          (begin (play (make-tone (pitch-to-freq (get-pitch (car notes)))
                                  10
                                  (calculate-frames (get-duration (car notes))
                                                   (get-tempo score))))
                 (sleep (* 60 (/ (get-duration (car notes)) (get-tempo score))))
                 (play-iter (cdr notes)))))
    (play-iter notes)))


(provide (all-defined-out))