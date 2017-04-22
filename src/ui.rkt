#lang racket/gui

(require "core.rkt")
(require racket/gui/base)

;; MAIN PANEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define frame (new frame%
                   [label "Racket Sheet Music Editor - Toolbar"]
                   [width 400]
                   [height 400]
                   [alignment '(left top)]))

(define staves-score-panel (new vertical-panel%
                                [parent frame]))
                                   
(define note-panel (new vertical-panel%
                        [parent frame]))
                        

;; EDIT-INFO PANEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define edit-info-panel (new group-box-panel%
                             [parent frame]
                             [label "Navigation"]
                             [horiz-margin 25]
                             [vert-margin 25]
                             [border 25]
                             [alignment '(center top)]))

(define edit-info-instructions
  (string-append "How to move the cursor:\n"
                 "Left one note: LEFT ARROW\n"
                 "Right one note: RIGHT ARROW\n"
                 "Up one staff: PAGE UP\n"
                 "Down one staff: PAGE DOWN"))

(define edit-info-msg (new message% [parent edit-info-panel]
                          [label edit-info-instructions]))

;(new button% [parent frame]
;             [label quarter-note]
;             [callback (lambda (button event)
;                         (send msg set-label "Quarter Note"))])


;; TRANSPOSITION PANEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define transposition-panel (new group-box-panel%
                                 [label "Transposition"]
                                 [horiz-margin 25]
                                 [vert-margin 25]
                                 [parent frame]
                                 [alignment '(center top)]
                                 [border 2]))

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
(define natural (read-bitmap "../img/small/natural.png"
                               'png #f #t
                               #:backing-scale 3.0))

(define flat (read-bitmap "../img/small/flat.png"
                               'png #f #t
                               #:backing-scale 3.0))
(define sharp (read-bitmap "../img/small/sharp.png"
                               'png #f #t
                               #:backing-scale 3.0))


(send frame show #t)