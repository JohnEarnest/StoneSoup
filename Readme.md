Stone Soup Games
================

In July of 2012 I taught a week-long summer youth program for Michigan Technological University on the subject of introductory video game programming, aimed at kids aged 11 to 18. I used the [Processing](http://processing.org) programming language, and organized the class primarily as a hands-on workshop. After some basic programming exercises, students were provided with "template" programs which provide a bare-bones implementation of a game. Once they managed to get the template working, they could add features and customize the game to their heart's content.

Organization
------------

This project will serve as a repository of my course materials for that class and materials that could be applicable to similar classses. Everything is made available under the [WTFPL](http://sam.zoy.org/wtfpl/).

Every example will include a `.pde` file containing the source of the template program and a readme file discussing the program, the ideas it seeks to teach, a step-by-step tutorial on how the pieces fit together, and discussion of possible improvements to the template. If the program requires any external resources (graphics, etc), placeholders are provided- all the examples are "ready to run".

A suggested course order might be:

- [Icebreaker Activities](Icebreakers.md)

- [Canonical](Canonical/)

- [Dungine](Dungine/)

- [Austereoids](Austereoids/)

Rationale
---------

The template programs provided here were designed with a number of criteria in mind:

- __Fit on a Page.__
	Rather than giving students the templates as a digital file, they were always distributed as a printout. Typing in the program provides useful experience debugging typos and encourages the students to read every line and consider what it does. All the templates are designed to roughly fit on a printed page to keep this process from being excrutiating.

- __Simple.__
	The span of a week (or however long your introductory class may be) is not enough time to create perfect programmers. Sophisticated code organization, inheritance and "generic" or "reusable" systems can easily introduce more complexity than is necessary for beginners- we're trying to get them to the fun parts as quickly as possible. The templates are not written to do things the "right" way, they are written to do things in the _simplest_ way possible. I hope you like global variables.

- __Practical.__
	Don't introduce new language features unless the problem they solve is larger than the intellectual load of understanding the feature. If students already know how to use a `for` loop, don't throw a foreach at them when you could just extract elements from a list by index. Don't use an `enum` to keep track of cardinal directions when you could just use an `int`. This is basically an extension of the previous concept.

- __Extensible.__
	The first thing that will happen to templates is being run. The second thing that will happen is modification. By anticipating this, templates can be designed to make common tweaks and extensions easy. This rule is the counterpoint to striving for extreme simplicity- there is a delicate balance.