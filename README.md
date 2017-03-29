# Sheet Music Editor

### Statement
We'll be creating an application for creating, editting, exporting, and playing sheet music. We plan on beginning with basic functionality, and as we proceed, intend to add features of increasing complexity.

Both of us like music, so it made sense to chose a project idea based on interests outside of computer science. For both of us, this is our first big project that'll we'll need to complete from start to finish (planning to ui). Additionally, this project will require us to use a wide range of concepts that we've learned so far.

### Analysis
OPL concepts we plan to use:
- Abstraction/Object Orientation. We'll be representing different music primitives as objects (ie. note, scale). We'll need to write functions to create and interact with these primitives.
- Recursion. We'll have lists of music primitives that we'll need to operate on (playing lists of notes, transposing, exporting, etc).
- Map/Filter/Reduce. Because we'll be storing music primitives in lists, map/filter/reduce will be very important for operating on these lists. For example, Map will be useful for writing transposition functions.
- Functional Approaches. We'll be using lots of recursion, and through the use of recursion, will be able to create this application without modifying state.

### External Technologies
We plan on using rsound to generate music from the sheet music. We'd also like to be able to export the sheet music as a pdf file and the audio as a sound file.

### Data Sets or other Source Materials
In terms of data/source materials, we'll need to keep a list of the notes names. Nothing other than that.

### Deliverable and Demonstration
The final product will have a gui that the user will interact with. The user will be able to input information via the keyboard and buttons in the application. The user should be able to create, edit, save, and export sheet music. In the application, the user should also be able to play the audio associated with the sheet music.

Since our application will be interactive, the demonstration will be a visual tour of the features.

### Evaluation of Results
We will know if we are successful if we successfully implement the features we propose. This will be a qualitative evaluation. Additionally, we hope to write a few unit tests to assess core functionality.

## Architecture Diagram
Upload the architecture diagram you made for your slide presentation to your repository, and include it in-line here.

Create several paragraphs of narrative to explain the pieces and how they interoperate.

## Schedule and Group Responsibilities

### First Milestone (Sun Apr 9)
All of the core should be implemented by the first milestone. This will be the underlying code-based representation of the sheet music. At this point we will be interacting with the program using unit tests & the repl (no main driver yet). This will be a joint effort.

### Second Milestone (Sun Apr 16)
The two main driver components should be finished by the second milestone. Doug will implement the draw function to create a visual representation of the sheet music. Matt will create a user-input system with buttons and keyboard input to modify the sheet music (adding, removing, modifying notes). By this milestone, the visual aspect of the program will be complete.

### Public Presentation (Mon Apr 24, Wed Apr 26, or Fri Apr 28 [your date to be determined later])
The final stage will see the implementation of the final two main features. Matt will write the play function(s) and Doug will write the various export functions.


### Doug Salvati @doug-salvati
Will work on Core, Draw, Export

### Matthew DiBello @mdibello
Will work on Core, Play, User Input/Modification Functions
