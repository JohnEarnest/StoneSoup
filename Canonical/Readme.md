Canonical
=========

This game is a classic artillery duel in the style of Scorched Earth. It introduces some ideas about physics and movement in addition to state machines. We start with target practice gameplay and use approaches that make destructible terrain and hotseat multiplyer easy to add.

Tutorial
--------

We will begin by defining `setup()` and `draw()` procedures. In `setup` we will initialize the size of our window and in `draw()` we clear the screen with a sky-blue background color.

	void setup() {
		size(640, 480);
	}
	
	void draw() {
		background(128, 255, 255);
	}

Our first task is generating and drawing a set of rolling hills which will serve as terrain for the game. Since this game views the 2d hills from the side, we can describe them as a series of discrete heights (stored in an array) and render the terrain by drawing pixel-wide lines side by side. Let's create our array, initialize the values with a constant height and draw the result in green:

	int[] ground = new int[640];
	
	void setup() {
		size(640, 480);
		for(int x = 0; x < 640; x++) {
			ground[x] = 200;
		}
	}
	
	void draw() {
		background(128, 255, 255);
		stroke(0, 255, 0);
		for(int x = 0; x < 640; x++) {
			line(x, 480, x, ground[x]);
		}
	}

This is boring, but works as expected. It would be more illustrative if we initialized `ground` with a more interesting series of values:

	for(int x = 0; x < 640; x++) {
		ground[x] = (int)random(200, 400);
	}

The result is spiky and illustrates that our height-map is working, but it is not very natural looking. Processing provides a generator for something called "Perlin Noise", which is a way of generating a random distribution with patterns that are well-suited to creating organic, natural forms. `noise()` takes an index into this distribution and returns a value within 0 and 1. By scaling the index and the result we can vary the bumpiness of the hills- experiment with it!

	for(int x = 0; x < 640; x++) {
		ground[x] = 430 - (int)(100 * noise(x / 75.0));
	}

Next, we'll need to make the player's cannon. Like in Scorched Earth, the player will be able to adjust the angle of the cannon and the force it imparts to projectiles. Once the cannon is fired, the projectile will have a position and velocity. First let's declare some variables to keep track of this information:

	float vx, vy, px, py;  // projectile x/y velocity and x/y position
	float angle = -PI / 4; // angle of the cannon (45 degrees up and to the right)
	float force = 5;       // force of the cannon (pixels/frame)
	int player = 100;      // position of the cannon

We only need an x-position for the player, as `ground` will provide the y-position of the terrain at any given point. To indicate the direction the cannon is pointing in, we can calculate the x and y velocity components of the projectile from the cannon angle and force by using the definition of a circle, scale the components to make the result more visible and draw a line showing the resulting vector:

	void draw() {
		// ...
		stroke(255, 0, 0);
		rectMode(CENTER);
		rect(player, ground[player], 30, 15); // the cannon
		vx = force * cos(angle);
		vy = force * sin(angle);
		px = player;
		py = ground[player];
		line(px, py, px + (5 * vx), py + (5 * py)); // the cannon's barrel
	}

Of course, this isn't very useful unless we can actually aim. Let's write a `keyReleased()` procedure which alters the angle when the left and right cursor keys are released and alters the force of the cannon in response to the up and down keys:

	void keyReleased() {
		if (keyCode == LEFT ) { angle -= .1; }
		if (keyCode == RIGHT) { angle += .1; }
		if (keyCode == DOWN ) { force -= .5; }
		if (keyCode == UP   ) { force += .5; }
	}

Now we have a cannon on a hill and the ability to aim. Allowing us to fire a projectile will require restructuring our code slightly. We want to be able to aim, press a button to fire the projectile, and then watch the projectile sail through the air. After the projectile goes offscreen or hits the ground, we want to be able to aim again. When the projectile is moving, we don't want to be able to change the angle and force of the projectile, and when we're aiming we don't want to draw or move the projectile.

We have two kinds of exclusive behavior we want to take place during the execution of our program. By organizing our logic into "states" which are controlled by some sort of variable, we create something called a State Machine. This is a very simple but powerful idea that can be applied in many ways when writing video games, from menu systems to RPG-style turn-based combat systems.

Here, state 0 will represent aiming (our initial state) while state 1 will represent moving the projectile through the air. To move the projectile we will add (or integrate, if you prefer) the projectile's velocity to the projectile's position. We'll additionally add a small acceleration to the vertical component of the projectile's velocity to represent gravity pulling the projectile downward.

	int state = 0;

	void draw() {
		// draw terrain
		// draw cannon
		if (state == 0) {
			// calculate projectile vx/vy/px/py
			// draw cannon barrel
		}
		if (state == 1) {
			px += vx;
			py += vy;
			vy += .1;
			ellipse(px, py, 10, 10); // projectile
		}
	}

We'll also have to alter `keyPressed()`. We should only be able to aim during state 0, and when space is pressed we should fire the cannon, which means we will transition to state 1.

	void keyPressed() {
		if (state == 0) {
			if (key == ' ') { state = 1; }
			if (keyCode == LEFT ) { angle -= .1; }
			if (keyCode == RIGHT) { angle += .1; }
			if (keyCode == DOWN ) { force -= .5; }
			if (keyCode == UP   ) { force += .5; }
		}
	}

When using state machines, first plan out the exclusive behaviors comprising your game and figure out how to split things up. Then consider the conditions that will cause a transition from one state to another. Drawing a picture can be a good way to organize your thoughts.

We can aim and fire, and the projectile moves through the air, but it never stops- we aren't detecting collisions and transitioning back to state 0. If we had a procedure called `checkHit()` which returned true when the projectile collided with the terrain, we could update `draw()` to look something like this:
	
	void draw() {
		// ...
		if (state == 1) {
			px += vx;
			py += vy;
			vy += .1;
			ellipse(px, py, 10, 10);
			if (checkHit()) { state = 0; }
		}
	}

So how should `checkHit()` work? We can write it by "shaving off" a simple case at a time until the remaining problem is trivial. If the projectile is off the screen horizontally, we know it won't come back, so we can assume it hit the ground. If the projectile's y-position is less than the height of the corresponding `ground` slice, we know it's still in the air. If neither of those are the case, it must have hit the ground.

	boolean checkHit() {
		if (px < 0 || px >= 640) { return true; }
		if (py < ground[(int)px]) { return false; }
		return true;
	}

(Note that if the projectile is moving fast enough it will "skip" colliding with some `ground` slices, allowing it appear to move through hills occasionally. One solution to this problem is to always update the projectile's position in single-pixel increments, checking for collisions each time. This makes things a bit more complicated, so for the sake of simplicity we'll ignore this imperfection for now.)

The core of our aim-and-shoot gameplay is ready. Now we just need something to shoot. Let's have a target somewhere on another hill which gives us points every time we hit it. We'll need to keep track of our score and the horizontal position of the target:

	int score = 0;
	int goal  = 600;

Updating `draw()` to draw the target and score is easy:

	void draw() {
		// ...
		rect(goal, ground[goal], 30, 5);
		fill(0, 128, 255);
		text("score: " + score, 10, 20);

		if (state == 0) {
			// ...
		}
		if (state == 1) {
			// ...
		}
	}

To score a target hit, we just need to add a bit of logic to `checkHit()`. After we've shaved off the first two cases, we know we hit _something_. By checking to see whether the horizontal position of the projectile is within half the width of the target of the target's horizontal position we can detect a collision. To keep things interesting we can set the target's position to a new random location when the player scores:

	if (px < goal + 15 && px > goal - 15) {
		goal = (int)random(150, 600);
		score += 1;
	}

And we've got a game!

Future Directions
-----------------

A feature that is just begging to be included in this game is destructible terrain. To make the projectile create a divot in the hill, we just need to add a little code to `checkHit()` which alters the values in `ground` when the projectile hits the ground.

To create a semicircular divot, consider all the terrain slices within a given radius of the collision point (both to the left and right). So long as those slices are actually within the boundaries of the screen, we can calculate depth of a point on the semicircle by applying the Pythagorean Theorem. We'll take the maximum of that depth and the depth of the ground at the given location already so that if the divot extends over lower terrain we don't reset that terrain to a higher value.

	int radius = 20;
	for(int x = (int)(px - radius) + 1; x < (int)(px + radius); x++) {
		if (x < 0 || x >= 640) { continue; }
		float d = px - x;
		ground[x] = max(ground[x], (int)(py + sqrt(radius*radius - d*d)));
	}

With some minor modifications, this code could also be used to create a "dirt gun", which produces new hills when it collides with terrain.

To make firing the cannon even more gratifying, a simple explosion animation can be fun. To add this, we'll create an additional state (2) which is transitioned to after the projectile hits the ground. This state uses a countdown timer to produce an animation for a few moments and then switches back to state 0. After creating a new global int called `timer` and rewiring existing state transitions as described, add something like this to `draw()`:

	if (state == 2) {
		fill(255, random(255), 0);
		ellipse(px, py, timer * 2, timer * 2);
		fill(255, 255, 255);
		timer++;
		if (timer > 30) {
			timer = 0;
			state = 0;
		}
	}

Note how this uses a random fill color to produce an easy flickering color effect. There are many ways to combine primitives, gradients and alpha transparency to produce "juicy" explosion animations- try it out!

Adding a second player would make this game much more like Scorched Earth. Doing so is largely a matter of replicating the existing code and making some small changes. The biggest change is the expansion of the state machine- create new states for the second player's aiming and firing and modify the state transitions so that when the first player's projectile collides with something, the second player has a chance to aim, and so on. There are many ways to organize the logic of this turn-taking behavior to make it more compact and make it easier to add additional players- experiment and see what you can come up with!