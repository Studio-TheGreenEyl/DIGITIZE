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

void initControllers() {
  for (int i = 0; i < values.size(); i++) {
    JSONObject node = values.getJSONObject(i);
    String ip = node.getString("ip");
    PVector pos = new PVector(node.getInt("x"), node.getInt("y"), node.getInt("z"));
    JSONArray segments = node.getJSONArray("segments");
    controller.add(new Controller(ip, pos.x, pos.y, pos.z));
    int latest = controller.size()-1;
    for (int j = 0; j < segments.size(); j++) {
      JSONObject segment = segments.getJSONObject(j);
      int[] start = segment.getJSONArray("start").getIntArray();
      int[] end = segment.getJSONArray("end").getIntArray();
      controller.get(latest).setCoordinates(j, start[0], start[1], start[2], end[0], end[1], end[2]);  
    }
  }   
}
