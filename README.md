# Sheet Music Editor

### Statement & Authors
Sheet Music Editor is an application for writing, editing, playing, and exporting sheet music.

Both of the authors, [Matthew DiBello](https://github.com/mdibello) and [Doug Salvati](https://github.com/doug-salvati) like music, so it made sense to chose a project idea based on interests outside of computer science. This is the first major project that'll we've completed from start to finish (planning stages to full user interface). Additionally, this project incorporated a wide range of concepts that we've learned so far in COMP.3100.

## Architecture

![architecture](/img/architecture.png)

The **Core** of the project is a code-based representation of all the musical "primitives" that we implemented in our application. This entails objects like a "note" which may have a pitch and a duration. Then these notes are collectedo into staves and scores.

The next major chunk is **Draw**. This takes the internal code-based representation of sheet music and draws it to the screen so the user can see it. Though it can be used standalone, it is currently configured to use some global variables to highlight the current note being edited. Draw is the segment that takes data from the Core and translates it to the UI using `racket/draw`.

The **Modifying Functions**, of course, allow the user to modify the sheet music. Through a series of buttons (`racket/gui`), the user triggers modifiers that change the internal representation of the sheet music. Changes to the Core trigger the Draw procedure to update what's visible to the user.

![panel](/img/sample_panel.png)

Another key component is **Play**. This is similar to Draw in that it receives data from Core and translates it to another representation. But instead of drawing it to the screen, Play generates audio that the user can listen to. Play uses `rsound`.

The final major part is **Export**, which takes the data stored in Core and does yet another transformation. Export translates the data into a PDF.  The representation is very similar to Draw, but it does provide the title at the top of the document.

![export](/img/sample_output.png)

All of these modules work with the data stored in Core, and create different representations so that the user can interact with the data. This modular system is beneficial, in that it allows for flexibility. Modularity in developing applications is important, as it allows the developers to add or remove modules as necessary.

## Schedule and Group Responsibilities

### External Technologies
This application uses Racket's `RSound` library to generate audio from the sheet music. You can also export the sheet music as a PDF.

### Data Sets or other Source Materials
We used a set of high-quality [images](/img/large) to render the musical notation, sourced for free from [this site](http://midnightmusic.com.au/2013/06/the-big-free-music-notation-image-library/).

### Deliverables and Demonstration
The final product has a GUI with which the user can interact. The user can be able to input information via the buttons in the application. The user is able to create, edit, save, or export sheet music. In the application, the user can also play the audio associated with the sheet music.

Since our application is interactive, the demonstration will be a visual tour of the features. We have [sample songs](/demo) ready to load which the users can edit and play to see what their edits do to the music.

### First Milestone (Sun Apr 9)
All of the core was implemented by the first milestone. This is be the underlying code-based representation of the sheet music. At this point we will were interacting with the program using unit tests & the repl (no main driver yet). This was be a joint effort.

### Second Milestone (Sun Apr 16)
The majority of the two main driver components was finished by the second milestone. Doug implemented the draw function to create a visual representation of the sheet music, leaving a few details for the next milestone. Matt began creating a user-input system with buttons and keyboard input to modify the sheet music (adding, removing, modifying notes). By this milestone, the visual aspect of the program was mostly established.

### Public Presentation (Fri Apr 28 @ Tsongas Arena)
The final stage saw the implementation of the final two main features. Matt wrote the Play function(s) and Doug wrote the input/output/export functions.

### Evaluation of Results
Based on a qualitative evaluation of the sound and visual quality, we conclude that our results are positive. Additionally, we have a set of unit tests for the core of the application because creating and accessing data objects can be tested numerically without a GUI.  There are some musical rules not observed by this code: (1) If an accidental is applied to a note, it does *not* take effect for the remainder of the measure, (2) Ledger Lines are not rendered by Draw.

### Doug Salvati @doug-salvati
Worked on Core, Draw, Export

### Matthew DiBello @mdibello
Worked on Core, Play, User Input/Modification Functions
