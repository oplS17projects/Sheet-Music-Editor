# Sheet Music Editor

## Matthew DiBello
### April 30, 2017

# Overview
For this project, we created a program that allows a user to write, edit, save/load/export, and play sheet music. It it a basic version of software similar Sibelius, Finale and MuseScore.

Since a sheet music editor can easily contain hundreds of features, we chose to only implement the most basic features in an attempt to create a fully-functional program, but one that can be wrtitten in a matter of weeks.

The implementation of this project utilizes many of the core concepts that we've studied throughout the course.

**Authorship note:** All of the code described here was written by myself.

# Libraries Used
The code uses four libraries:

```
(require racket/draw)
(require racket/gui)
(require rsound)
```

* The ```draw``` library was used to display the sheet music graphically.
* The ```gui``` library was used to provide a ui to the interface for interacting/modifying the data.
* the ```rsound``` library was used to generate an audio representation of the sheet music and play it for the user.

# Key Code Excerpts

Here is a discussion of the most essential procedures, including a description of how they embody ideas from 
UMass Lowell's COMP.3010 Organization of Programming languages course.

Five examples are shown and they are individually numbered. 

## Recursion to Rebuild Lists

The most important concept in the modifying functions is the use of recursion to rebuild lists. In order to mutate the data that internally represents the sheet music, the code I wrote rebuild the data object and then saves the new object as the global-object.

This concpet it used by over a dozen of my modifying functions, but provided below is one example:

```
;; Add a staff to the score
(define (add-staff score clef key-name)
  (if (< (length (get-staves score)) max-staves)
      (make-score (get-time-sig score)
                  (get-tempo score)
                  (append (get-staves score)
                          (list (make-staff clef
                                            (make-key-sig key-name)
                                            '()))))
```

This procedure adds a new staff to the score, but to do so, it build a new score from scratch, using information such as the previous score and parameters for building the new staff.


## Map and Filter
