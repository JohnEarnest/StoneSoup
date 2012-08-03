float vx, vy, px, py;
float angle = -PI / 4, force = 5;
int player = 100, goal = 600;
int score = 0;
int state = 0;
int[] ground = new int[640];

void setup() {
	size(640, 480);
	for(int x = 0; x < 640; x++) {
		ground[x] = 430 - (int)(100 * noise(x / 75.0));
	}
}

boolean checkHit() {
	if (px < 0 || px >= 640) { return true; }
	if (py < ground[(int)px]) { return false; }
	if (px < goal + 15 && px > goal - 15) {
		goal = (int)random(150, 600);
		score += 1;
	}
	return true;
}

void draw() {
	background(128, 255, 255);
	stroke(0, 255, 0);
	for(int x = 0; x < 640; x++) {
		line(x, 480, x, ground[x]);
	}
	stroke(255, 0, 0);
	rectMode(CENTER);
	rect(player, ground[player], 30, 15);
	rect(goal,   ground[goal],   30,  5);
	fill(0, 128, 255);
	text("score: " + score, 10, 20);
	fill(255, 255, 255);

	if (state == 0) {
		vx = force * cos(angle);
		vy = force * sin(angle);
		px = player;
		py = ground[player];
		line(px, py, px + (5 * vx), py + (5 * vy));
	}
	if (state == 1) {
		px += vx;
		py += vy;
		vy += .1;
		ellipse(px, py, 10, 10);
		if (checkHit()) { state = 0; }
	}
}

void keyReleased() {
	if (state == 0) {
		if (key == ' ') { state = 1; }
		if (keyCode == LEFT ) { angle -= .1; }
		if (keyCode == RIGHT) { angle += .1; }
		if (keyCode == DOWN ) { force -= .5; }
		if (keyCode == UP   ) { force += .5; }
	}
}
