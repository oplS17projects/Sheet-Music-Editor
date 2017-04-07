#lang racket

(require rackunit)
(require "../src/core.rkt")

"Running UNIT TESTS. Errors will be shown below (if any):"

(define my-staff-treble (make-staff 'treble (make-key-sig C)
                                         (make-note (make-pitch C 4) 1)
                                         (make-note (make-pitch D 4) 1)))
(define my-staff-bass (make-staff 'bass (make-key-sig C)
                                         (make-note (make-pitch C 4) 1)
                                         (make-note (make-pitch D 4) 1)))

; Time signatures
(test-case
 "Creating a time signature of 2/4 time"
 (let ([my-time-sig (make-time-sig 2 4)])
   (begin (check-equal? (get-num-beats my-time-sig) 2)
          (check-equal? (get-beat-unit my-time-sig) 4))))

; Scores
(test-case
 "Create a basic score: 2/4 time, 60bpm, two notes"
 (let ([my-score (make-score (make-time-sig 2 4)
                             60
                             my-staff-treble)])
   (begin (check-equal? (get-num-beats (get-time-sig my-score)) 2)
          (check-equal? (get-beat-unit (get-time-sig my-score)) 4)
          (check-equal? (get-tempo my-score) 60)
          (check-pred list? (get-staves my-score))
          (check-equal? (length (get-staves my-score)) 1))))

(test-case
 "Create a score consisting of multiple staves"
 (let ([my-score (make-score (make-time-sig 2 4)
                             60
                             my-staff-treble
                             my-staff-bass)])
   (begin (check-equal? (get-num-beats (get-time-sig my-score)) 2)
          (check-equal? (get-beat-unit (get-time-sig my-score)) 4)
          (check-equal? (get-tempo my-score) 60)
          (check-pred list? (get-staves my-score))
          (check-equal? (length (get-staves my-score)) 2))))

(test-case
 "Accessing a staff recursively using get-staff"
 (let ([my-score (make-score (make-time-sig 2 4)
                             60
                             my-staff-treble
                             my-staff-bass)])
   (begin (check-equal? (get-staff my-score 0) (make-staff 'treble (make-key-sig C)
                                                           (make-note (make-pitch C 4) 1)
                                                           (make-note (make-pitch D 4) 1)))
          (check-equal? (get-clef (get-staff my-score 1)) 'bass))))

; Edit info
(test-case
 "Creating some editing info"
 (let ([my-edit-info (make-edit-info my-staff-bass 0)])
   (begin (check-equal? (get-current-index my-edit-info) 0)
          (check-equal? (get-clef (get-current-staff my-edit-info)) 'bass)
          (check-equal? (get-current-index (inc-current-index my-edit-info)) 1)
          (check-equal? (get-current-staff (inc-current-index my-edit-info)) my-staff-bass))))

"UNIT TESTS finished."
                             

