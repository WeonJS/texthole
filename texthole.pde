/*
TODO:
- make initial velocity tangent to circle to make spiral effect
- when hole gets as big as screen, gameover screen with big text particle explosion and "gameover" text
- make particles that include text for player to type with double-text effect
- remove unnecessary this.
- increase rate of letters spawning as time goes on
- give letters more tangentially spin than particals so that they last longer before hitting the center
- cleanup code
*/


ArrayList<TextParticle> particles = new ArrayList<TextParticle>();
ArrayList<Letter> letters = new ArrayList<Letter>();

int particlesSpawnedPerFrame = 1;
final float G = 3;
float texthole = 50;
float textholeIncrement = 0.02f;
int particleLimit = 5000;

boolean gameRunning = false;
boolean gameOver = false;

int framesBeforeDifficultyIncrease = 300;
int score = 0;
int framesBeforeLetterSpawn = 60;
int globalFramesShown = 0;
final String[] chars = {"a", "s", "c", "i", "-", ":", "`", "\"", "'", "^", "#"};
final String[] letterChars = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"};
int framesBeforeChange = 20;
PVector backCl = new PVector(0,0,0);

PFont scoreFont;
PFont defaultFont;

void setup() {
  size(800, 800);
  scoreFont = createFont("INVASION2000.TTF", 32);
  defaultFont = createFont("Lucida Sans Regular.ttf", 18);
  //frameRate(40);
}

class Letter {
  PVector pos, vel = new PVector(0, 0);
  int framesShown;
  int framesBeforeChange = 10;
  String letter;
  int size = 28;
  PVector backFill = new PVector(0, 0, 0);
  int fill = 80;
  float mass = random(2,  5);
  
  public Letter(float x, float y) {
    this.pos = new PVector(x, y);
    this.vel = new PVector(0, 0);
    this.letter = letterChars[(int)random(0, letterChars.length)];
  }
  
  private void showText() {
    int textJiggle = 1;
    textSize(this.size);
    textFont(scoreFont);
    
    if (framesShown % framesBeforeChange == 0) {
      backFill = new PVector(map(random(255), 0, 255, 51, 180), map(random(255), 0, 255, 51, 180),map(random(255), 0, 255, 51, 180));
    }
    
    textAlign(CENTER, CENTER);
    
    fill(this.backFill.x, this.backFill.y, this.backFill.z);
    text(this.letter, this.pos.x + random(-textJiggle, textJiggle) - 3, this.pos.y + random(-textJiggle, textJiggle) + 3);
    fill(this.fill);
    text(this.letter, this.pos.x + random(-textJiggle, textJiggle), this.pos.y + random(-textJiggle, textJiggle));
  }
  
  public void show() {
    showText();
    
    // Get consumed by texthole
    if (dist(this.pos.x, this.pos.y, width/2, height/2) < texthole / 2 + 10) {
       letters.remove(letters.indexOf(this)); 
       texthole += textholeIncrement * 1000;
    }
    
    PVector force = PVector.sub(new PVector(width/2, height/2), this.pos);
    float d = force.mag();
    d = constrain(d, 5, 25);
    force.normalize();
    
    float strength = (G * mass * mass) / (d * d);
    force.mult(strength);
    
    this.vel.add(force);
    this.pos.add(this.vel);
    
    this.framesShown++;
  }
}

class TextParticle {
  PVector pos, vel = new PVector(0, 0);
  float size;
  String character;
  int framesShown;
  float mass = random(5, 10);
  
  public TextParticle(float x, float y, float size) {
    this.pos = new PVector(x, y);
    this.size = size;
    this.character = chars[(int)random(0, chars.length)];
  }
  
  private void showText() {
    int textJiggle = 1;
    textSize(this.size);
    textFont(defaultFont);
    fill(map(random(255), 0, 255, 51, 100), map(random(255), 0, 255, 51, 100),map(random(255), 0, 255, 51, 100));
    textAlign(CENTER, CENTER);
    text(this.character, this.pos.x + random(-textJiggle, textJiggle), this.pos.y + random(-textJiggle, textJiggle));
  }
  
  public void show() {
    showText();
    
    // Get consumed by texthole
    if (dist(this.pos.x, this.pos.y, width/2, height/2) < texthole / 2 + 10) {
       particles.remove(particles.indexOf(this)); 
       texthole += textholeIncrement;
    }
    
    // Changes character every framesBeforeChange frames
    if (this.framesShown % framesBeforeChange == 0) {
       this.character = chars[(int)random(0, chars.length)];
    }
    
    PVector force = PVector.sub(new PVector(width/2, height/2), this.pos);
    float d = force.mag();
    d = constrain(d, 5, 25);
    force.normalize();
    
    float strength = (G * mass * mass) / (d * d);
    force.mult(strength);
    
    this.vel.add(force);
    this.pos.add(this.vel);
    
    this.framesShown++;
  }
}

void draw() {
  
  // kinda shitty state machine
  if (!gameRunning && !gameOver) {
    background(51);
    textFont(scoreFont);
    textSize(48);
    textAlign(CENTER, CENTER);
    
    if (globalFramesShown % 10 == 0) {
      backCl = new PVector(random(255), random(255), random(255));
    }
    
    fill(backCl.x, backCl.y, backCl.z);
    text("texthole", width / 2 - 3, height / 2 - 200 + 3);
    
    fill(255);
    text("texthole", width / 2, height / 2 - 200);
    
    textSize(22);
    text("PRESS 'SPACE' TO START", width / 2, height / 2 - 100);
    
    
    globalFramesShown++;
    return; 
  } else if (gameOver) {
    background(51);
    textFont(scoreFont);
    fill(120,0,0);
    textSize(50);
    text("GAME OVER", width/2 - 5, height/2 - 200 + 5);
    fill(255,0,0);
    text("GAME OVER", width/2, height/2 - 200);
    fill(255);
    text("Score: " + score, width/2, height/2 - 100);
    text("'SPACE' to continue", width/2, height/2);
    gameRunning = false;
    return;
  }
  
  background(51);
  fill(220);
  textFont(scoreFont);
  text(frameRate, 100, 30);
  ellipse(width/2, height/2, width, height);
  stroke(0);
  fill(255);
  ellipse(width/2, height/2, texthole, texthole);
  
  fill(0);
  textFont(scoreFont);
  textSize(texthole/6);
  text("Score: "+score, width/2, height/2);
  
  // Increase difficulty
  if (globalFramesShown % framesBeforeDifficultyIncrease == 0) {
     particlesSpawnedPerFrame += 4;
     framesBeforeLetterSpawn = constrain(framesBeforeLetterSpawn - 5, 10, 100);
  }
  
  // Spawn particles with particleLimit as limiting factor
  if (particles.size() < particleLimit) {
    for (int i = 0; i < particlesSpawnedPerFrame; i++) {
      float ang = random(PI * 2);
      TextParticle tp = new TextParticle((width / 2) * sin(ang) + (width / 2), (height / 2) * cos(ang) + (height / 2), 12);
      tp.vel = new PVector(random(-1, 1), random(-1, 1));
      particles.add(tp);
    }
  }
  
  // Spawn letters
  if (globalFramesShown % framesBeforeLetterSpawn == 0) {
     float ang = random(PI * 2);
     letters.add(new Letter((width / 2) * sin(ang) + (width / 2), (height / 2) * cos(ang) + (height / 2)));
  }
  
  for (int i = 0; i < particles.size(); i++) {
    particles.get(i).show();
  }
  
  for (int i = 0; i < letters.size(); i++) {
    letters.get(i).show();
  }
  
  // gameover
  if (texthole >= width + 8) {
    gameOver = true;
  }
  
  globalFramesShown++;
}

// debug code
void keyPressed() {
  String chr = Character.toString(key).toLowerCase();
  
  if (chr.equals(" ") && !gameRunning && !gameOver) {
    gameRunning = true;
  } 
  if (chr.equals(" ") && gameOver) {
    particles = new ArrayList<TextParticle>();
    letters = new ArrayList<Letter>();
    texthole = 50;
    globalFramesShown = 0;
    score = 0;
    gameOver = false;
    particlesSpawnedPerFrame = 1;
    framesBeforeLetterSpawn = 60;
  }
  
  for (int i = 0; i < letters.size(); i++) {
     if (letters.get(i).letter.equals(chr)) {
        letters.remove(i);
        texthole *= 0.90;
        score++;
     }
  }
}
