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
boolean isOrtho = true;
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
  if(orientationOn) {
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
}

void keyPressed() {
  if (key=='c') {
    if (isOrtho) {
      toPerspetive();
    } else {
      toOrtho();
    }
  } else if (key=='q') {
    orientationOn = !orientationOn;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();

  zoomRatio += e/20;
  if (zoomRatio>1.2) {
    zoomRatio =1.2;
  }
  if (zoomRatio < 0.1) {
    zoomRatio = 0.1;
  }
}

void toPerspetive() {
  cam.setDistance(map(zoomRatio, 0.1, 1.2, 50, 500));
  isOrtho = !isOrtho;
  println("perspective mode");
}

void toOrtho() {
  zoomRatio = map((float)cam.getDistance(), 50, 500, 0.1, 1.2);
  isOrtho = !isOrtho;
  println("ortho mode");
}
