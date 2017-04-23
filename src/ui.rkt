#lang racket/gui

(require "core.rkt")
(require racket/gui/base)

;; LOADING IMAGES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define eighth-note (read-bitmap "../img/small/eighth.png"
                                  'png #f #t
                                  #:backing-scale 3.0))
(define quarter-note (read-bitmap "../img/small/quarter.png"
                                  'png #f #t
                                  #:backing-scale 3.0))
(define half-note (read-bitmap "../img/small/half.png"
                               'png #f #t
                               #:backing-scale 3.0))
(define whole-note (read-bitmap "../img/small/whole.png"
                               'png #f #t
                               #:backing-scale 3.0))
(define eighth-rest (read-bitmap "../img/small/eighth_rest.png"
                                  'png #f #t
                                  #:backing-scale 3.0))
(define quarter-rest (read-bitmap "../img/small/quarter_rest.png"
                                  'png #f #t
                                  #:backing-scale 3.0))
(define half-rest (read-bitmap "../img/small/half_rest.png"
                               'png #f #t
                               #:backing-scale 3.0))
(define whole-rest (read-bitmap "../img/small/whole_rest.png"
                               'png #f #t
                               #:backing-scale 3.0))
(define treble (read-bitmap "../img/small/treble.png"
                               'png #f #t
                               #:backing-scale 3.0))
(define bass (read-bitmap "../img/small/bass.png"
                               'png #f #t
                               #:backing-scale 3.0))

(define natural-file (read-bitmap "../img/small/natural.png"
                               'png #f #t
                               #:backing-scale 8.0))
(define natural (make-bitmap 30 50))
(define dc-nat (new bitmap-dc% [bitmap natural]))
(send dc-nat draw-bitmap natural-file 0 0)

(define flat-file (read-bitmap "../img/small/flat.png"
                               'png #f #t
                               #:backing-scale 8.0))
(define flat (make-bitmap 30 50))
(define dc-fla (new bitmap-dc% [bitmap flat]))
(send dc-fla draw-bitmap flat-file 0 0)

(define sharp-file (read-bitmap "../img/small/sharp.png"
                               'png #f #t
                               #:backing-scale 8.0))
(define sharp (make-bitmap 30 50))
(define dc-sha (new bitmap-dc% [bitmap sharp]))
(send dc-sha draw-bitmap sharp-file 0 0)


;; MAIN PANEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define frame (new frame%
                   [label "Racket Sheet Music Editor - Toolbar"]
                   [width 400]
                   [height 400]
                   [alignment '(left top)]))

(define staves-score-panel (new vertical-panel%
                                [parent frame]))


;; NOTES PANEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define notes-panel (new group-box-panel%
                        [parent frame]
                        [label "Notes"]
                        [alignment '(center top)]
                        [horiz-margin 10]
                        [vert-margin 10]
                        [border 10]))

(define notes-options-panel (new horizontal-panel%
                                 [parent notes-panel]
                                 [alignment '(center top)]))

(define pitch-panel (new vertical-panel%
                         [parent notes-options-panel]
                         [alignment '(left top)]))

(define note-name-selector (new choice%
                                [parent pitch-panel]
                                [label "Note Name "]
                                [choices '("A" "B" "C" "D" "E" "F" "G")]
                                [horiz-margin 10]
                                [vert-margin 10]))

(define accidental-selector (new radio-box%
                                 [parent pitch-panel]
                                 [label "Accidentals "]
                                 [choices (list natural sharp flat)]))
                                
                        

;; EDIT-INFO PANEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define edit-info-panel (new group-box-panel%
                             [parent frame]
                             [label "Navigation"]
                             [horiz-margin 10]
                             [vert-margin 10]
                             [border 10]
                             [alignment '(center top)]))

(define edit-info-instructions
  (string-append "How to move the cursor:\n"
                 "Left one note: LEFT ARROW\n"
                 "Right one note: RIGHT ARROW\n"
                 "Up one staff: PAGE UP\n"
                 "Down one staff: PAGE DOWN"))

(define edit-info-msg (new message% [parent edit-info-panel]
                          [label edit-info-instructions]))


;; TRANSPOSITION PANEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define transposition-panel (new group-box-panel%
                                 [label "Transposition"]
                                 [horiz-margin 10]
                                 [vert-margin 10]
                                 [border 10]
                                 [parent frame]
                                 [alignment '(center top)]))

(define transposition-sub-panel (new vertical-panel%
                                     [parent transposition-panel]
                                     [alignment '(center bottom)]))

(define transposition-slider (new slider% [parent transposition-sub-panel]
                                  [label "Half-steps"]
                                  [min-value 1]
                                  [max-value 12]))

(define transposition-up-down (new radio-box% [parent transposition-sub-panel]
                                   [label "Direction of Transposition"]
                                   [choices '("Up" "Down")]))

(define transposition-btn-panel (new horizontal-panel%
                                     [parent transposition-panel]
                                     [alignment '(center bottom)]))

(define transpose-staff-btn (new button% [parent transposition-btn-panel]
                                 [label "Transpose Staff"]
                                 [callback (lambda (button event)
                                             "Transpose Staff")]))
(define transpose-score-btn (new button% [parent transposition-btn-panel]
                                 [label "Transpose Score"]
                                 [callback (lambda (button event)
                                             "Transpose Score")]))





(send frame show #t)