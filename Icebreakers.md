Icebreakers
===========

Before you can make games in Processing, it's necessary to lay down some basic concepts- variables, graphics commands, animation, the draw loop, etc. Here are a few short example programs to play with which illustrate these ideas and help build familiarity with the Processing environment.

Spirographics
-------------

	float r = 0.0;

	void setup() {
	  size(500, 500);
	  colorMode(HSB);
	}

	void draw() {
	  translate(width/2, height/2);
	  rotate(r);
	  fill(r*10%255, 255, 255);
	  rect(30 + 3*r, 10, 90, 30);
	  r += 0.1;
	}

This program features mesmerizing animation and rainbow colors- try customizing it! You can try adding more objects, objects spinning in different directions or moving in different ways, different color gradients and much more.

The statement `colorMode(HSB)` is the basis of the rainbow colors. [HSB](https://en.wikipedia.org/wiki/HSL_and_HSV) stands for "Hue, Saturation, Brightness". When we later use `fill()`, the first number we provide is the Hue. We multiply the rotation variable `r` by 10 to make the colors cycle more quickly and take that number modulo 255 (`%255`) to keep the hue in a 0-255 range.

The functions `translate()` and `rotate()` are extremely important here as well. Used in the given order they allow us to draw objects rotated around the center of the display. The functions `pushMatrix()` or `popMatrix()` can be used to back up or restore the position, rotation and scale of the drawing context- especially helpful if you're drawing several objects centered on different points or moving in different patterns.

Finally, note that old graphics remain on the screen when we draw each successive frame. If you add the line `background(255, 0, 255);` to the beginning of `draw()` you will erase the display and get a single animated object instead of a trail. Try it!

Paintbrush
----------

	float b = 0.0;

	void setup() {
	  size(500, 500);
	  fill(0, 0, 0);
	}

	void draw() {
	  ellipse(mouseX, mouseY, b, b);
	  ellipse(width-mouseX, mouseY, b, b);
	  if (mousePressed) { b += 0.1; }
	  else { b = 0.0; }
	}

A minimalist symmetrical drawing program which demonstrates mouse input. Click and drag to draw slowly widening lines, like a Sumi brush. Try adding features like the ability to erase or toggle symmetrical drawing mode.

There are many interesting drawing tools which can be built from simple programs like this- consider creating a pen which narrows as you move the mouse more quickly and pools ink when you stay in one spot, or perhaps a pen which uses `get()` to smear around existing colors in the image.

Hit the Spot
------------

	float x, y;

	void setup() {
	  size(500, 500);
	}

	void draw() {
	  background(255, 255, 255);
	  fill(255, 0, 0);
	  ellipse(x, y, 20, 20);
	}

	void mouseClicked() {
	  if (dist(mouseX, mouseY, x, y) < 20) {
		x = random(width);
		y = random(height);
	  }
	}

The beginnings of a target shooting game. Click on the red spot and it'll run away to another part of the screen. If you miss, it will wait patiently for you to try again.

This program demonstrates point-circle collision. The mouse coordinates are within the circle if the distance between the mouse position and the circle position is less than the circle's radius. We could use the [Pythagorean Theorem](https://en.wikipedia.org/wiki/Pythagorean_theorem) to solve this problem, but the built in `dist()` function is even easier.

To make something more like a game, consider making the dot move on its own in `draw()`. Can you make it run away from the mouse cursor? How would you ensure that the dot always stays on screen? Could you add a score counter to keep track of how many times you've hit the spot? (Hint: you'll want to use `text()` and perhaps `textSize()`.)

