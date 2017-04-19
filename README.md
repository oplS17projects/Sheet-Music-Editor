# Sheet Music Editor

### Statement
We'll be creating an application for writing, editing, exporting, and playing sheet music. We plan on beginning with basic functionality, and as we proceed, intend to add features of increasing complexity.

Both of us like music, so it made sense to chose a project idea based on interests outside of computer science. For both of us, this is our first big project that'll we'll need to complete from start to finish (planning stages to full user interface). Additionally, this project will require us to use a wide range of concepts that we've learned so far.  Our goal is to successfully complete the experience so that we can apply these skills to future endeavors (e.g. honors project).

### Analysis
OPL concepts we plan to use:
- Abstraction/Object Orientation. We'll be representing different music primitives as objects (ie. note, scale). We'll need to write functions to create and interact with these primitives.
- Recursion. We'll have lists of music primitives that we'll need to operate on (playing lists of notes, transposing, exporting, etc).
- Map/Filter/Reduce. Because we'll be storing music primitives in lists, map/filter/reduce will be very important for operating on these lists. For example, Map will be useful for writing transposition functions.
- Functional Approaches. We'll be using lots of recursion, and through the use of recursion, will be able to create this application without modifying state.  When lists are "modified", we will have them reconstructed using functions.  For instance, as a simple example, creating a note will take the current list of notes and return one which is a copy of the original with the new note appended.

### External Technologies
We plan on using rsound to generate music from the sheet music. We'd also like to be able to export the sheet music as a PDF and the audio as a sound file.

### Data Sets or other Source Materials
We plan to import a set of high-quality [images](/img/large) to render the musical notation, sourced for free from [this site](http://midnightmusic.com.au/2013/06/the-big-free-music-notation-image-library/).
In terms of data/source materials, we'll need to keep a list of the notes names. Nothing other than that.

### Deliverables and Demonstration
The final product will have a GUI with which the user will interact. The user will be able to input information via the keyboard and buttons in the application. The user should be able to create, edit, save, and export sheet music. In the application, the user should also be able to play the audio associated with the sheet music.

Since our application will be interactive, the demonstration will be a visual tour of the features. We will have sample songs pre-loaded which the users can edit and play to see what their edits do to the music.

### Evaluation of Results
Whether we successfully implement the features we propose will mainly be a qualitative evaluation of the sound and visual quality. Additionally, we will write unit tests for the "state modifying functions" which create new lists based on the change the user requested.  For instance, transposition can be tested numerically without a GUI.

## Architecture Diagram
![architecture](/img/architecture.png)

The core of the project will be a code-based representation of sheet music. It is indicated in blue above. All the musical "primitives" that we will be implementing in our application will need to be represented by code. This will entail objects like a "note" which may have a pitch and a duration. Then these notes will have to be collected. In essence we'll need a way to represent music as objects that we create. That is the goal of the "core".

The next major chunk is Draw. This will handle taking the internal code-based representation of sheet music (aka the Core) and drawing it to the screen so the user can see it. Draw is the segment that takes data from the Core and translates it to the UI. Draw will use `racket/draw`.

The modifying functions allow the user to modify the sheet music. Through a series of buttons (`racket/gui`) and keyboard inputs, the user will be able to trigger modifiers that change the internal representation of the sheet music. The Event Listener will take any detected input from either the keyboard or buttons on the UI, and trigger the appropriate mutator, which will change the code-based information stored in the core. Changes to the Core will then trigger the Draw function to update what's visible to the user.

Another key component is Play. This is similar to Draw in that it receives data from Core and translates it to another representation. But instead of drawing it to the screen, Play generates audio that the user can listen to. Play will use `rsound`.

The final major part is Export, which takes the data stored in Core and does yet another transformation. Export will translate the data into a filetype that can be opened by other applications. For example, Export might save the sheet music as a PDF, which can then be opened by another application.

All of these modules work with the data stored in Core, and creates different representations so that the user can interact with the data. This modular system is beneficial, in that it allows for flexibility. Modularity in developing applications is important, as it allows the developers to add or remove modules as necessary.

## Schedule and Group Responsibilities

### First Milestone (Sun Apr 9)
All of the core was be implemented by the first milestone. This is be the underlying code-based representation of the sheet music. At this point we will were interacting with the program using unit tests & the repl (no main driver yet). This was be a joint effort.

### Second Milestone (Sun Apr 16)
The majority of the two main driver components were be finished by the second milestone. Doug implemented the draw function to create a visual representation of the sheet music, leaving a few details for the next milestone. Matt began creating a user-input system with buttons and keyboard input to modify the sheet music (adding, removing, modifying notes). By this milestone, the visual aspect of the program is mostly established.

### Public Presentation (Fri Apr 28 @ Tsongas Arena)
The final stage will see the implementation of the final two main features. Matt will write the play function(s) and Doug will write the various export functions.

### Doug Salvati @doug-salvati
Will work on Core, Draw, Export

### Matthew DiBello @mdibello
Will work on Core, Play, User Input/Modification Functions
