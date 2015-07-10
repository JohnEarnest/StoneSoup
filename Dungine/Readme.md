Dungeon Engine
==============

This game is a top-down tile based adventure game. It introduces 2D arrays and working with images in Processing, and can be extended to produce games in the vein of Chip's Challenge, Zelda or even a simple version of Pacman.

Tutorial
--------

Like every game we write in Processing, we will begin by defining `setup()` and `draw()` procedures. In `setup` we will initialize the size of our window.

	void setup() {
		size(640, 640);
	}
	
	void draw() {
		// more here later.
	}

For this program, we will be working with bitmapped images. Let's make an image of a player and display it onscreen. Save your program, draw a player image in your favorite graphics editor, and then save your image as a 64x64 PNG in a directory called `data`, inside the directory where your program is saved. Images you wish to use in your program will always reside in this `data` directory. To use images in our program, we must do three things.

Declare a (global) variable of type `PImage` for storing the image:

	PImage player;

Somewhere during `setup()`, initialize the `PImage` by using `loadImage()`:

	void setup() {
		size(640, 640);
		player = loadImage("player.png");
	}

Somewhere during `draw()`, call `image()`, to draw a `PImage` to the screen:

	void draw() {
		background(0, 0, 0);
		image(player, 100, 100);
	}

In our game, we're going to use a grid of 64x64 images- "tiles"- to make up the world. Since we're going to use many different tiles to represent walls, doors, items and so on, let's use an array to load up our images, allowing us to reference them by a numeric index.

Begin by creating 64x64 graphics for a background texture, a floor texture, and a solid wall. As before, we'll declare variables to store our images and load the images before we can display them.

	PImage[] tiles = new PImage[3];

	void setup() {
		tiles[0] = loadImage("background.png");
		tiles[1] = loadImage("ground.png");
		tiles[2] = loadImage("wall.png");
	}

Since our window is 640x640 and our tiles are 64x64, we can fit a 10x10 grid of tiles on the screen at once. We can use another array to store a grid of tile indices to draw. First, declare your 10x10 grid as a literal:

	int[][] grid = {
	  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	  { 0, 2, 2, 2, 2, 2, 2, 2, 0, 0 },
	  { 0, 2, 1, 1, 1, 2, 1, 2, 2, 0 },
	  { 0, 2, 1, 1, 1, 2, 1, 2, 2, 0 },
	  { 0, 2, 1, 1, 1, 2, 1, 2, 2, 0 },
	  { 0, 2, 1, 1, 1, 1, 1, 2, 0, 0 },
	  { 0, 2, 2, 2, 2, 1, 2, 2, 0, 0 },
	  { 0, 0, 0, 0, 2, 1, 2, 0, 0, 0 },
	  { 0, 0, 0, 0, 2, 2, 2, 0, 0, 0 },
	  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	};

Since we'd like this literal representation of the array to map directly to how things are oriented on the screen, the outer subscript of the array will represent the y-axis while the inner subscript will represent the x-axis. Make sure you don't mix this up later!

Now we want to use that array to draw appropriate tiles to the screen. We'll use a pair of nested loops to keep track of the x and y coordinates of the tile we wish to draw, look up an element of the grid array and then use the resulting value as an index into our array of tiles.

	void draw() {
		for(int y = 0; y < 10; y++) {
			for(int x = 0; x < 10; x++) {
				image(tiles[grid[y][x]], x * 64, y * 64);
			}
		}
	}

Notice that we're multiplying x and y by 64 before we draw the image. This is because x and y represent a position counted in _tiles_, whereas `image()` takes coordinates counted in _pixels_. One tile is 64 pixels, so to convert units we just multiply. When you're working on this program, remember to consider the units that a value represents- _tiles_ or _pixels_?

The next step in making this into a game is to add a player we can control. The player should move in response to the cursor keys and it shouldn't be able to move through walls.

We'll need variables to keep track of the player's position (in _tiles_, since we want the player to move in discrete steps):

	int px = 3;
	int py = 2;

We'll need to load the image for the player, and since we'll store it as a tile we need to bump up the size of our tiles array:

	void setup() {
		// ...
		tiles[3] = loadImage("player.png");
	}

And naturally we'll need code in `draw()` to diplay the player after the grid is drawn:

	void draw() {
		// ...
		image(tiles[3], px * 64, py * 64);
	}

Next, getting the player to move. I'm going to write a procedure for moving the player to a particular position which I will call `move()`. We will provide a pair of coordinates for the player's new position, and this procedure will either update the player's position or, if these coordinates are impassible, leave the player's position unchanged. Based on our code so far, we know that a tile is impassible if it is part of the background (0) or a wall (2).

	void move(int nx, int ny) {
		int tile = grid[ny][nx];
		if (tile == 0 || tile == 2) { return; }

		// we now must be on a passable tile.
		px = nx;
		py = ny;
	}

Making the player move in response to cursor keys is straightforward. We'll write a `keyReleased()` procedure and check `keyCode` to identify the cursor keys. When one is pressed, we'll call our `move()` procedure with an appropriate new position based on the player's current position.

	void keyReleased() {
		if (keyCode == UP   ) { move(px    , py - 1); }
		if (keyCode == DOWN ) { move(px    , py + 1); }
		if (keyCode == LEFT ) { move(px - 1, py    ); }
		if (keyCode == RIGHT) { move(px + 1, py    ); }
	}

The player should be able to move around, but should not be able to move through walls. Let's extend the functionality we developed so that we can have items to pick up. I'd like to add some precious gems that can be collected when the player walks over them.

As before, we need to load a new graphic for the gems, which will be represented by tile 4. We can place gems by simply modifying the numbers in `grid`. To keep track of how many gems the player has picked up, we'll need a variable:

	int gems = 0;

And we can use the `text()` procedure in `draw()` to display a gem counter onscreen:

	void draw() {
		// ...
		text("gems: " + gems, 10, 10);
	}

To allow the player to pick the gems up, we'll extend `move()`. When the player successfully moves onto a location which has tile 4 we should add one to `gems` and then change the tile the player is standing on to ground (1), making the gem disappear.

	void move(int nx, int ny) {
		int tile = grid[ny][nx];
		if (tile == 0 || tile == 2) { return; }
		px = nx;
		py = ny;
		if (grid[py][px] == 4) {
			gems += 1;
			grid[py][px] = 1;
		}
	}

Now that we can collect gems, it makes sense to add a simple puzzle element which relies on them. I'll add a tile which represents a door (tile 5) which is impassible unless you have 3 or more gems. When you walk onto the door tile with enough gems, it takes 3 away and disappears. Once you've added the appropriate door tile to the game, we just have to make some small additions to `move()`.

Before we update the player's position, we check if they're trying to move onto a door without enough gems and bail out if that's the case:

	if (tile == 5 && gems < 3) { return; }

If we manage to update the player's position, we can then take away the gems and change the tile into normal ground:

	if (grid[py][px] == 5) {
		gems -= 3;
		grid[py][px] = 1;
	}

Success! We have a tile grid, a player, collision and objects in the world which can be interacted with by walking on them.

Future Directions
-----------------

One of the first things many students wish to add to their game is multiple levels. To begin, we need to add a degree of indirection to `grid`. Rather than directly initializing `grid` with the map, make several named arrays with levels and point `grid` to one of them:

	int[][] level1 = {
		// ...
	};
	int[][] level2 = {
		// ...
	};
	int[][] grid = level1;

Now we can determine what level we're on by comparing grid with one of those other arrays using `==` and we can redirect grid to a different level by reassigning it. Imagine we wanted to make it so that standing on tile type 7 while on level 1 teleports us to tile (3, 5) on level 2. We could add the following logic to `move()` before repositioning the player:

	if (tile == 7 && grid == level1) {
		grid = level2;
		px = 3;
		py = 5;
		return;
	}

The `return` ensures that after changing the level no other teleporters are activated and the player position is not changed afterwards. In this example we made any tile 7 work as a teleporter but if we have several which go to different locations we might check the player's position rather than the tile the player is standing on.

You could also change levels when the player walks off the edge of one board, creating the appearance that the player has walked onto the new level from the opposite edge:

	if (py < 0 && grid == level1) {
		grid = level2;
		py = 9;
		return;
	}

It's important to do this type of check _before_ you look up the current tile, since the new player coordinates will be outside the bounds of the `grid` array.

If you wanted to create a more linear series of levels with less repeated logic, you could instead create a variable to keep track of the level index and make `grid` a three dimensional array, where the outermost index of the array is used to select the current level. In this case you could easily write logic for tile types that send the player to the next or previous level by adding to or subtracting from the level index. Try it!

Another addition many students ask about is some type of mobile game entity, like an enemy that chases the player or obstacles that move. Adding a combat system is beyond the scope of this tutorial, but let's add a bothersome blob which follows the character around. We'll need to load the blob's image, keep track of its position and we will need an additional variable which will be used to regulate the speed of the blob's movement:

	PImage blob;
	int timer = 0;
	int bx = 6;
	int by = 2;

In a direct parallel to how we defined `move()` for the player's movement, we'll define a `moveBlob()` procedure for the blob. `moveBlob` will be much simpler than `move()` because the blob doesn't need to be able to open doors or pick up gems:

	void moveBlob(int nx, int ny) {
	  int tile = grid[ny][nx];
	  if (tile == 0 || tile == 2 || tile == 5) { return; }
	  bx = nx;
	  by = ny;
	}

Note that since we have separate code defining tiles which are "solid" to the player and the blob, we might create tiles which act differently for them. This is a simple idea that can be the basis of interesting puzzles. (Or bugs, if done accidentally!)

In `draw`, add some logic to draw the blob on the screen and increment `timer`. If the timer is high enough, move the blob once and reset the timer. By adjusting the timer cutoff you can alter the speed at which the blob appears to move.

	void draw() {
		// ...
		image(blob, bx * 64, by * 64);
		timer++;
		if (timer >= 50) {
			timer = 0;
			if      (px > bx) { moveBlob(bx + 1, by    ); }
			else if (px < bx) { moveBlob(bx - 1, by    ); }
			else if (py > by) { moveBlob(bx    , by + 1); }
			else if (py < by) { moveBlob(bx    , by - 1); }
		}
	}

The chain of `if...else if...` statements determines the correct direction in which to move the blob at each step. We use `else if` because we only wish to have the blob move _once_, orthogonally, per "turn". As an alternative to this timer-based approach, you could place the logic that calls `moveBlob()` in the player's `move()` method where it is triggered when the player moves rather than in `draw()` where it is triggered 60 times per second- the former may be more appropriate for turn-based puzzle games.