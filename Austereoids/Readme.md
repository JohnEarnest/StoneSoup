Austereoids
===========

This game is a one-screen space shooter with 2d "newtonian flight", similar to the arcade classic "Asteroids". This example provides a gentle introduction to inheritance and using object-oriented programming. Unlike previous examples which required new global variables every time we added an interactive game element, we can now explain an Object once and produce as many instances as we like.

Tutorial
--------

Our game will have several kinds of objects which obey the same laws of motion. Let's describe a class called `Mobile` representing something with a position and velocity. A `Mobile` can be asked to `move()`, which it does by adding its velocity to its position. If a `Mobile` object moves off the edge of the screen (here assumed as 480x480), it will appear on the opposite edge- this means space is shaped like a torus:

	class Mobile {
	  float px, py, vx, vy;
	  void move() {
		px += vx;
		py += vy;
		if (px <   0) { px = 480; }
		if (px > 480) { px =   0; }
		if (py <   0) { py = 480; }
		if (py > 480) { py =   0; }
	  }
	}

`Mobile` provides an abstract description of a kind of thing, including its properties (position and velocity) and the actions it can perform (`move()`). If I wanted to add some rocks that float through space, following a random initial velocity, I could create a more specialized version of `Mobile` by _subclassing_. We indicate that a class subclasses another class by using the `extends` keyword:

	class Rock extends Mobile {
	  Rock() {
		px = random(480);
		py = random(480);
		vx = random(-2, 2);
		vy = random(-2, 2);
	  }
	  void move() {
		super.move();
		rect(px, py, 20, 20);
	  }
	}

`Rock()` is a _constructor_- that is, a procedure which is called when a new `Rock` is created. Here, we initialize the position and velocity of the rock randomly. Notice that we're able to reference variables like `px` and `vx` which were defined in `Mobile`- when you subclass, all the properties and procedures defined in the parent class remain available in the child class.

In `Rock`'s definition of `move()`, we call `super.move()`. This means that when a `Rock` moves, it does whatever the parent class did- in this case, update the position of the `Rock` with respect to toroidal space. `Rock`s then additionally draw a rectangle at their position.

Now that we've described what a `Rock` is, we can create some. Let's begin by writing `setup()` and `draw()` procedures:

	void setup() {
		size(480, 480);
		rectMode(CENTER);
	}

	void draw() {
		background(0, 0, 0);
	}

We want to support having an arbitrary number of `Rock`s in the game. To do this, we'll create an `ArrayList`. `ArrayList`s are like arrays, except they can grow and shrink as we add and remove items. Let's create an `ArrayList` to store rocks:

	ArrayList<Rock> rocks = new ArrayList<Rock>();

The name in `<>` specifies the type of Object the `ArrayList` will contain- in this case, `Rock` Objects. when we create the `ArrayList` we say `new ArrayList<Rock>()`.

Now that we have a place to store our rocks, let's create some:

	void setup() {
		size(480, 480);
		rectMode(CENTER);
		for(int x = 0; x < 10; x++) {
			rocks.add(new Rock());
		}
	}

Here we use a `for` loop to perform the same action 10 times. We call the `add()` procedure on our `List` and insert a new `Rock` Object each time. Every time the `new` keyword is used, we're creating a new Object (and calling that Object's constructor) which is an _instance_ of a particular type, as defined in a `class`. `Rock` contains properties like position and velocity, so every `Rock` instance has a distinct position and velocity.

Now we'd like to make those rocks show up on the screen and do something. An individual `Rock` knows how to move itself and draw itself via the `move()` procedure, so all we need to do is go through the elements stored in `rocks` and tell them to `move()`:

	void draw() {
		background(0, 0, 0);
		for(int x = 0; x < rocks.size(); x++) {
			Rock r = rocks.get(x);
			r.move();
		}
	}

Notice that we use the `size()` of our `ArrayList` to determine the upper bound of this loop- this way, as `rocks` grows and shrinks we'll always `move()` every `Rock`. We then use `x` to access elements of `rocks` by index via the `get()` procedure. Indices for `get()`, just like array indices, count from 0.

The next thing we need for a proper "Asteroids" clone is a spaceship. Since a Ship is a thing that moves through space, we can begin by subclassing `Mobile` again. A Ship works like a `Mobile`, except that it has a rotation, it starts in the center of the screen and it draws itself as a triangle, rotated by some amount:

	class Ship extends Mobile {
		float r = -PI / 2; // initially facing straight up

		Ship() {
			px = 240;
			py = 240;
		}

		void move() {
			super.move();
			pushMatrix();
			translate(px, py);
			rotate(r);
			triangle(5, 0, -5, 10, -5, -10);
			popMatrix();
		}
	}

We can put one of these into the game by declaring a variable to store an instance and telling that instance to `move()` every time `draw()` is called:

	Ship player = new Ship();

	// ...

	void draw() {
		// ...
		player.move();
	}

Next we want to make the player move in response to keyboard keys being pressed. We could do this by writing global `keyPressed()` and/or `keyReleased()` procedures, but it would help keep everything more organized if we put logic that has to do with the `Ship` inside the `Ship` class. Let's just expand `Ship.move()` to rotate when the right and left keys are pressed and to impart an acceleration to the `Ship`'s velocity when the up key is pressed:

	void move() {
		super.move();
		if (keyPressed) {
			if (keyCode == LEFT ) { r -= .125; }
			if (keyCode == RIGHT) { r += .125; }
			if (keyCode == UP) {
				vx += .125 * cos(r);
				vy += .125 * sin(r);
			}
		}
		// draw the Ship...
	}

Spiffy. This is starting to feel like a game! To add an element of danger, let's make it so that the `Ship` can be destroyed by collding with `Rock`s. As we move the `Rock`s, we'll check to see if the `player` is within a small radius. If that's the case, we'll replace the `player` with a new instance of `Ship`. Since new `Ship`s start out in the center of the screen, this will have the effect of resetting the game.

	void draw() {
		background(0, 0, 0);
		for(int x = 0; x < rocks.size(); x++) {
			Rock r = rocks.get(x);
			r.move();
			if (dist(player.px, player.py, r.px, r.py) < 15) {
				player = new Ship();
			}
		}
		player.move();
	}

Easy! There are a lot of different directions you could take the game in now. Perhaps you could add enemies that attempt to chase the player, valuable objects the player can pick up or some kind of scoring system that rewards the player for surviving in this asteroid field. Try it out!

Future Directions
-----------------

This game would be much more like "Asteroids" if it was possible to fire bullets from our Ship and destroy the rocks floating around in space. It sounds like a simple feature, but we'll need to make a number of small additions to build up to this point.

To begin with, let's define a class to represent bullets. Like everything else so far, they are `Mobile` objects with a position and velocity. We'll write a constructor so that when we create a new bullet it begins with the player's position and velocity, plus a small impulse determined by the direction in which the player is facing. We'll draw bullets as a small ellipse.

	class Bullet extends Mobile {
		Bullet() {
			px = player.px;
			py = player.py;
			vx = player.vx + 2 * cos(player.r);
			vy = player.vy + 2 * sin(player.r);
		}

		void move() {
			super.move();
			ellipse(px, py, 10, 10);
		}
	}

Next, we'll make it so that the player can create new bullets when the spacebar is pressed. Just like our `ArrayList` which keeps track of all the rocks in space, we'll make a new `ArrayList` of `Bullet`s, and then extend `Ship.move()` to spawn new `Bullet`s:

	ArrayList<Bullet> bullets = new ArrayList<Bullet>();

	class Ship {
		// ...

		void move() {
			// ...
			if (keyPressed) {
				// ...
				if (key == ' ') {
					bullets.add(new Bullet());
				}
			}
			// ...
		}
	}

This compiles fine, but nothing new seems to happen. That's because we never walk over the elements of `bullets` and tell them to move:

	void draw() {
		// ...
		for(int x = 0; x < bullets.size(); x++) {
			Bullet b = bullets.get(x);
			b.move();
		}
	}

Wonderful. You'll notice that bullets seem to appear as long chains- this is because we're spawning a new bullet every time `Ship.move()` is called, which happens 60 times per second! See if you can figure out how to add a time delay to regulate your `Ship`'s firing rate.

The last thing we need to do is make `Bullet`s destroy `Rock`s. This will work similarly to the collision code we already have in place. Expand our code which instructs each `Bullet` to move, so that for each `Bullet` we consider every `Rock`. If a `Rock` is sufficiently close to the given `Bullet`, we'll remove both from their respective `ArrayList`s:

	void draw() {
		for(int x = 0; x < bullets.size(); x++) {
			Bullet b = bullets.get(x);
			b.move();
			for(int y = 0; y < rocks.size(); y++) {
				Rock r = rocks.get(y);
				if (dist(b.px, b.py, r.px, r.py) < 15) {
					bullets.remove(b);
					rocks.remove(r);
				}
			}
		}
	}

Now we have a fully-functional asteroid blaster. Try working on a scoring system or making the `Rock`s respawn over time!
