int px = 3;
int py = 2;
int gems = 0;
PImage[] tiles = new PImage[6];

int[][] grid = {
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 2, 2, 2, 2, 2, 2, 2, 0, 0 },
  { 0, 2, 4, 1, 4, 2, 1, 2, 2, 0 },
  { 0, 2, 1, 1, 1, 2, 1, 4, 2, 0 },
  { 0, 2, 1, 1, 1, 2, 1, 2, 2, 0 },
  { 0, 2, 1, 1, 1, 1, 1, 2, 0, 0 },
  { 0, 2, 2, 2, 2, 5, 2, 2, 0, 0 },
  { 0, 0, 0, 0, 2, 1, 2, 0, 0, 0 },
  { 0, 0, 0, 0, 2, 2, 2, 0, 0, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
};

void setup() {
  size(640, 640);
  tiles[0] = loadImage("background.png");
  tiles[1] = loadImage("ground.png");
  tiles[2] = loadImage("wall.png");
  tiles[3] = loadImage("player.png");
  tiles[4] = loadImage("gem.png");
  tiles[5] = loadImage("lock.png");
}

void draw() {
  for(int y = 0; y < 10; y++) {
    for(int x = 0; x < 10; x++) {
      image(tiles[grid[y][x]], x * 64, y * 64);
    }
  }
  image(tiles[3], px * 64, py * 64);
  text("gems: " + gems, 10, 20);
}

void move(int nx, int ny) {
  int tile = grid[ny][nx];
  if (tile == 0 || tile == 2) { return; }
  if (tile == 5 && gems < 3)  { return; }
  px = nx;
  py = ny;
  if (grid[py][px] == 4) {
    gems += 1;
    grid[py][px] = 1;
  }
  if (grid[py][px] == 5) {
    gems -= 3;
    grid[py][px] = 1;
  }
}

void keyReleased() {
  if (keyCode == UP   ) { move(px    , py - 1); }
  if (keyCode == DOWN ) { move(px    , py + 1); }
  if (keyCode == LEFT ) { move(px - 1, py    ); }
  if (keyCode == RIGHT) { move(px + 1, py    ); }
}
