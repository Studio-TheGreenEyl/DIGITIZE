import ch.bildspur.artnet.*;

ArtNetClient artnet;

// ArtNet Node
class Controller {
  PVector pos;
  int howManyLEDsPerSegment = 600;
  String ip = "";
  Port[] ports = new Port[2];
  int limitLEDs = 100; // how many LEDs can be on per port? 100 LEDs * 60mA = 6A
  
  public Controller(String _ip, float x, float y, float z) {
    pos = new PVector(x, y, z);
    println(pos);
    ip = _ip;
    println("Created Controller with the IP= " + ip);
    for(int i = 0; i<ports.length; i++) ports[i] = new Port(i);
  }
  
  void send() {
    ports[0].send();
    ports[1].send();
    ports[0].segment.reset();
    ports[1].segment.reset();
  }
  
  
    void setCoordinates(int segmentNr, float x1, float y1, float z1, float x2, float y2, float z2) {
      if(segmentNr >= 0 && segmentNr <= 1) {
        ports[segmentNr].setCoordinates(x1, y1, z1, x2, y2, z2);
        //println("setting coordinates["+segmentNr+"]= (" + x1 + " / " + y1 + " / " + z1 + "), (" + x2 + " / " + y2 + " / " + z2 +")");
      } else println("error= segmentNr " + segmentNr + " doesn't exist");
    }
  
  void setPixels(int pixel, color c) {
    if(pixel <= howManyLEDsPerSegment) ports[0].segment.setPixels(pixel, c);
    else ports[1].segment.setPixels(pixel, c);
  }
  
  void black() {
    for(int i = 0; i<2; i++) {
      for(int j = 0; j<howManyLEDsPerSegment; j++) {
        ports[i].ledsLit = 0;
        ports[i].segment.setPixels(j);
      }
    }
  }
  
  void update() {
  }
  
  void display() {
    // draw the nebula controller
    push();
      translate(pos.x, pos.y, pos.z);
      noFill();
      stroke(white);
      strokeWeight(1);
      box(7, 5, 10);
    pop();
    
    ports[0].segment.display();
    ports[1].segment.display();
  }
  
  // Ethernet Port
  class Port {
    int nr = 0;
    Segment segment;
    int ledsLit = 0; // naive approach where it doesn't matter how dim/light one led is. the moment brightness is > 0 = it is ON
    
    public Port(int i) {
      nr = i;
      println(">> Created Port= " + nr);
      segment = new Segment();
    }
    
    void send() {
      segment.send();
    }

    void setCoordinates(float x1, float y1, float z1, float x2, float y2, float z2) {
      segment.setPos(x1, y1, z1, x2, y2, z2);
    }
    
    // A Segment is a longer strip of LEDs, possibly going over two long strips
    class Segment {
      PVector startPos;
      PVector endPos;
      Universe[] universes = new Universe[4];
      int LEDperSegment = 150;
      float pitch = 1.6666666667;
      float segmentLength = LEDperSegment*pitch;
      color[] segColor = new color[4];
      
      public Segment() {
        
        println(">> >> Created Segment");
        println(segmentLength);
        for(int i = 0; i<universes.length; i++) universes[i] = new Universe(i);
        segColor[0] = color(int(random(60, 255)), int(random(60, 255)), int(random(60, 255)));
        segColor[1] = color(int(random(60, 255)), int(random(60, 255)), int(random(60, 255)));
        segColor[2] = color(int(random(60, 255)), int(random(60, 255)), int(random(60, 255)));
        segColor[3] = color(int(random(60, 255)), int(random(60, 255)), int(random(60, 255)));
        //pos = new PVector(0, 0, 0);
      }
      
      void setPos(float x1, float y1, float z1, float x2, float y2, float z2) {
        println(">> >> setting coordinates["+nr+"]= (" + x1 + " / " + y1 + " / " + z1 + "), (" + x2 + " / " + y2 + " / " + z2 +")");
        startPos = new PVector(x1, y1, z1);
        endPos = new PVector(x2, y2, z2);
      }
      int pixel2universe(int c) {
        return int(c/LEDperSegment);
      }

      void setPixels(int pixel, color c) {
        float b = brightness(c);
        //println("b = " + b);
        if(b > 0) ledsLit++;
        else if(b == 0) ledsLit--;
        if(ledsLit < limitLEDs) universes[pixel2universe(pixel)%4].setPixels(pixel, c); // OutOfBounds: 4
        else println(">> >> limit of leds in this port[" + nr +"] has been reached");
      }
      
      void setPixels(int pixel) {
        universes[pixel2universe(pixel)].setPixels(pixel); // OutOfBounds: 4
      }
      
      void send() {
        for(int u = 0; u<universes.length; u++) {
          if(online) {
            //println(">> >> Send data to u= "+ universes[u].getUniverseName());
            artnet.unicastDmx(ip, 0, universes[u].getUniverseName(), universes[u].getData());
          }
        }
      }
      
      void reset() {
        for(int u = 0; u<universes.length; u++) {
            universes[u].reset();
        }
      }
      
      void display() {
        
        for(int i = 0; i<universes.length; i++) {
          if(i == 0)  {
            push();
            strokeWeight(4);
            stroke(color(255, 255, 0));
            //line(startPos.x, startPos.y, startPos.z, endPos.x, endPos.y, endPos.z);
            pop();
          }
          strokeWeight(1);
          stroke(white);
          noFill();
          noStroke();
          for(int j = 0; j<LEDperSegment; j++) {
            push();
            PVector newPos = PVector.sub(endPos, startPos);
            float ccc = map(j+(LEDperSegment*i), 0, LEDperSegment*4, 0.0f, 1.0f);
            newPos.mult(ccc);
            translate(startPos.x, startPos.y, startPos.z);
            translate(newPos.x, newPos.y, newPos.z);
            color c = color(universes[i].getIntData()[(j*3)+0], universes[i].getIntData()[(j*3)+1], universes[i].getIntData()[(j*3)+2]);
            fill(c);
            box(0.5);
            pop();
          }
        }
        //println("lit= " + ledsLit);
      }
      
      // Universe holds 170 LED Values
      // aka a full ArtNet Frame
      class Universe {
        int u = 0;
        int universeName = 0;
        byte[] values = new byte[(LEDperSegment*3)];
        int[] intValues = new int[(LEDperSegment*3)];
        boolean changed = false;
        
        public Universe(int i) {
          u = i;
          universeName = ((nr*4)+i);
          println(">> >> >> >> Created Universe= "+ u);
        }
        
        void setPixels(int pixel, color c) {          
          //, saturation(cc), brightness(cc));
          //println(saturation(c));
          
          //print(">> >> >> >> >> >> >> >> setPixel(" + pixel + ") in universe= "+ u +" on port= ("+ nr +")");
          pixel %= howManyLEDsPerSegment;
          changed = true;
          int[] nr = {
            ((pixel*3)+0)%(values.length),
            ((pixel*3)+1)%(values.length),
            ((pixel*3)+2)%(values.length)
          };
          
          int[] clean = {
            ((pixel*3)+0),
            ((pixel*3)+1),
            ((pixel*3)+2)
          };
          //println(" :: " + nr[0] +"("+clean[0]+")" + " :: " + nr[1] +"("+clean[1]+")" + " :: " + nr[2] +"("+clean[2]+")" ) ;
          values[nr[0]] = (byte)(c >> 16 & 0xFF);
          values[nr[1]] = (byte)(c >> 8 & 0xFF);
          values[nr[2]] = (byte)(c & 0xFF);
          
          intValues[nr[0]] = (c >> 16 & 0xFF);
          intValues[nr[1]] = (c >> 8 & 0xFF);
          intValues[nr[2]] = (c & 0xFF);
          
        }
        
        void setPixels(int pixel) {
          pixel %= howManyLEDsPerSegment;
          int[] nr = {
            ((pixel*3)+0)%(values.length),
            ((pixel*3)+1)%(values.length),
            ((pixel*3)+2)%(values.length)
          };
          values[nr[0]] = (byte)0;
          values[nr[1]] = (byte)0;
          values[nr[2]] = (byte)0;
          
          intValues[nr[0]] = 0;
          intValues[nr[1]] = 0;
          intValues[nr[2]] = 0;
        }
        
        byte[] getData() {
          return values;
        }
        
        int[] getIntData() {
          return intValues;
        }
        
        void reset() {
          changed = false;
        }
        
        boolean hasChanged() {
          return changed;
        }
        
        int getUniverseName() {
          return universeName;
        }
        
      } // End Class: Universe
      
    } // End Class: Segment
    
  } // End Class: Port

} // End Class: Controller
