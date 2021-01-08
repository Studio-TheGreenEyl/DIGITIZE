/*
  controller gets an X,Y,Z coordinate
  and the segments, too. this coordinate defines their start and end-points so wen can draw a line in space
*/
import peasy.*;

PeasyCam cam;
ArrayList<Controller> controller;
JSONArray values;
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
  
  controller = new ArrayList<Controller>();
  values = loadJSONArray("nodes.json");
  for (int i = 0; i < values.size(); i++) {
    JSONObject node = values.getJSONObject(i);
    String ip = node.getString("ip");
    PVector pos = new PVector(node.getInt("x"), node.getInt("y"), node.getInt("z"));
    JSONArray segments = node.getJSONArray("segments");
    controller.add(new Controller(ip, node.getInt("x"), node.getInt("y"), node.getInt("z")));
    int latest = controller.size()-1;
    for (int j = 0; j < segments.size(); j++) {
      JSONObject segment = segments.getJSONObject(j);
      int[] start = segment.getJSONArray("start").getIntArray();
      int[] end = segment.getJSONArray("end").getIntArray();
      controller.get(latest).setCoordinates(j, start[0], start[1], start[2], end[0], end[1], end[2]);  
    } 
    
    //println(values.get
    //String species = node.getString("species");
    //String name = node.getString("name");

    //println(ip);
  }
  
  
  
  black = color(0, 0, 0);
  white = color(255, 255, 255);
  blue = color(0, 0, 255);
  what = color(255, 0, 255);
  
  artnet = new ArtNetClient(null);
  artnet.start();
  
  /*controller = new Controller("10.77.88.243", 0, 0, 0);
  controller.setCoordinates(0, 0, 0, 0, 1000, 0, 0);
  controller.setCoordinates(1, 1000, 0, 0, 1000, 0, 1000);
  */
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
