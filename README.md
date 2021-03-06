# Notes

A simple script that creates commit messages from lists
of todos. It also has support for saving your todos in
a dropbox folder.

When I have to operate under a strict deadline I tend to break down
everything into todos and then complete and commit them. This is a nifty little
script that automates creation of commit messages from those todos.

## Installation

The script is written in bash, so you'll need a terminal
running bash. To install, clone this repo somewhere and add
the path to it in the `PATH` variable.

## Usage

Run `notes init` to setup the notes folder for the current project.
The notes  folder will be created in `~/Dropbox/work/notes` location if
you have Dropbox desktop client installed on your system otherwise the
location is `~/notes`. The notes directory for the project is then symlinked
into the project directory so that you can edit your todos from your editor.
I use Plain Tasks plugin in Sublime Text. Now tick off your todos stage your
changes and run `notes commit`.
