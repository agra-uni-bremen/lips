# lips IDE for Natural Language Processing

## Standalone Version

### Installation

1. Download a recent version of [Eclipse](http://www.eclipse.org/downloads/packages/eclipse-classic-422/junosr2)
2. Install an EMF legacy package using *Help* > *Install New Software...*
3. As installation URL (*Work with:*) enter: <http://download.eclipse.org/ecoretools/updates/releases/2.0.0/luna/>
4. Install lips using *Help* > *Install New Software...*
5. As installation URL (*Work with:*) enter: <http://www.informatik.uni-bremen.de/agra/lips>
6. Follow the installation instructions
7. At the end of the installation, Eclipse needs to be restarted

### Optional Requirements

*lips* uses the dot tool of the [graphviz package][1] to display the phrase structure tree and the dependency graph
of sentences.
On Linux there will be a package called *graphviz* or similar to install from your distribution's repository.
Users of other operating systems can download graphviz [here][2]. The path to the graphviz executables must
be specified in the path environment variable. On Linux systems this is usually done automatically at the installation
process, UNIX systems work similar, and Windows users might have to set it manually (see, for example, [this documentation][3]).

### First Steps

1. In Eclipse click *File* > *New* > *Other...*
2. Choose *Lips\New lips Project*
3. In the project add a new *Lips\New lips Specification*
4. Enter some text, one sentence per line. In the background a model will be generated.
   When keeping the *Ctrl* button pressed, clicking on a detected noun will open the
   generated model with the the extracted class focused.
5. Look out for the *NLP* menu for some further functionality (see Optional Requirements)

## Development Version

1. Load all four projects into Eclipse with a recent [Xtext](http://www.eclipse.org/Xtext/) plug-in installed.
2. Ensure that everything compiles
3. Start the file *de.agra.lips.editor/META-INF/MANIFEST.MF* as an Eclipse application


[1]: http://www.graphviz.org/
[2]: http://www.graphviz.org/Download.php
[3]: http://www.computerhope.com/issues/ch000549.htm
