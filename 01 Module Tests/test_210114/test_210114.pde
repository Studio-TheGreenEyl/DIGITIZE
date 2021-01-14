/*
  controller gets an X,Y,Z coordinate
  and the segments, too. this coordinate defines their start and end-points so wen can draw a line in space
  
  300 = 5m | 500cm
  
  250cm = 150leds
  500cm = 300leds
  462cm = 246leds
  
  (cm*300)/500
  
  ++ todo
  [ ] svg als path importieren
  [ ] controller mit cm länge als parameter
  [ ] segmente splitten
  
*/
import peasy.*;

PeasyCam cam;
ArrayList<Controller> controller;
JSONArray values;
boolean online = false;
int c = 0;

color black;
color white;
color blue;
color what;

int volume = 1;

boolean rotate = false;
boolean isOrtho = false;
boolean orientationOn = false;
float rotationSpeed = 0.001;
float zoomRatio = 1.0;


void setup() {
  size(1200, 600, P3D);
  surface.setLocation(0,0);
  frameRate(60);
  
  
  
  ortho(-width/2,width/2,-height/2,height/2,1,1000000000);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(0);
  cam.setMaximumDistance(1000000000);
  cam.setWheelScale(0.1);
  //cam.setYawRotationMode();
  //cam.setRollRotationMode();
  //cam.setSuppressRollRotationMode();
  //perspective(PI/3.0,(float)width/height,1,1000000000);
  
  controller = new ArrayList<Controller>();
  values = loadJSONArray("nodes.json");
  initControllers();

  
  
  
  black = color(0, 0, 0);
  white = color(255, 255, 255);
  blue = color(0, 0, 255);
  what = color(255, 0, 255);
  
  artnet = new ArtNetClient(null);
  artnet.start();
  
  for(int i = 0; i<controller.size(); i++) {
    controller.get(i).black();
    controller.get(i).send();
  }
  
  rectMode(CENTER);
}

void draw() {
  if (isOrtho) {
    ortho(-width / 2*zoomRatio, width / 2*zoomRatio, -height / 2*zoomRatio, height / 2*zoomRatio, 0, 1000000000);
    //rotateX(-.5);
    //rotateY(rotationSpeed);
    //rotationSpeed+=0.001;
  } else {
    //perspective();
    perspective(PI/3.0,(float)width/height,1,1000000000);
  }
  
  
  background(20);
  if(rotate) cam.rotateY(rotationSpeed);
  for(int i = 0; i<controller.size(); i++) {
    controller.get(i).black();
  }
  
  for(int i = 0; i<controller.size(); i++) {
    for(int j = 0; j<volume; j++) controller.get(i).setPixels(c+j, white);
  }
  
  for(int i = 0; i<controller.size(); i++) {
    controller.get(i).update();
    controller.get(i).display();
  }
  
  drawOrientation();
  c+=volume;
  c %= 1200;
  
  for(int i = 0; i<controller.size(); i++) {
    controller.get(i).send();
  }
  
  
}
