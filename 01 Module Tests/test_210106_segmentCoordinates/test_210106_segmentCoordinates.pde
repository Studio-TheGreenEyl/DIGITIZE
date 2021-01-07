/*
  controller gets an X,Y,Z coordinate
  and the segments, too. this coordinate defines their start and end-points so wen can draw a line in space
*/
import peasy.*;

PeasyCam cam;
Controller controller;
boolean online = true;
int c = 0;

color black;
color white;
color blue;
color what;

int volume = 1;

boolean rotate = false;
float rotationSpeed = 0.001;


void setup() {
  size(1200, 600, P3D);
  surface.setLocation(0,0);
  frameRate(60);
  
  ortho(-width/2,width/2,-height/2,height/2,1,1000000000);
  cam = new PeasyCam(this, 200);
  cam.setMinimumDistance(0);
  cam.setMaximumDistance(1000000000);
  
  //perspective(PI/3.0,(float)width/height,1,1000000000);
  

  //cam.setYawRotationMode();
  
  black = color(0, 0, 0);
  white = color(255, 255, 255);
  blue = color(0, 0, 255);
  what = color(255, 0, 255);
  
  artnet = new ArtNetClient(null);
  artnet.start();
  
  controller = new Controller("10.77.88.243", 0, 0, 0);
  controller.setCoordinates(0, 0, 0, 0, 1000, 0, 0);
  controller.setCoordinates(1, 1000, 0, 0, 1000, 0, 1000);
  controller.black();
  controller.send();
  
  rectMode(CENTER);
}

void draw() {
  background(0, 255, 255);
  if(rotate) cam.rotateY(rotationSpeed);
  
  controller.black();
  for(int i = 0; i<volume; i++) controller.setPixels(c+i, white);
  
  controller.update();
  controller.display();
  drawOrientation();
  c+=volume;
  c %= 1200;
  controller.send();
  
  
}

void drawOrientation() {
  push();
    translate(0, 0, 0);
    strokeWeight(3);
    stroke(#ff0000);
    line(0, 0, 0, 100, 0, 0);
    stroke(#00ff00);
    line(0, 0, 0, 0, -100, 0);
    stroke(#0000ff);
    line(0, 0, 0, 0, 0, 100);
    noFill();
    box(2, 2, 2);
  pop();
}
