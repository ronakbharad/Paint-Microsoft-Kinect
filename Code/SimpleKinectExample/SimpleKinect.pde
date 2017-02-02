import SimpleOpenNI.*;

Kinect initializeKinect() {
  Kinect context = new Kinect(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return null;  
  }   
  return context;
}


class Kinect extends SimpleOpenNI {
  Kinect(processing.core.PApplet parent) {
    super(parent);
  }
}


class PointT {
  PVector p;
  color c;
  int handId;
  
  PointT(PVector p, color c, int handId) {
    this.p = p;
    this.c = c;
    this.handId = handId;
  }
}


class Hand {
  float x;
  float y;
  float z;
  ArrayList<PointT> path;
  int currColor;
  boolean isPainting;
  boolean isLostHand;
  boolean isChangingColor;
  int dontPaintCount;
  int showClick;
  
  Hand() {
    
  }
  
  Hand(ArrayList<PointT> path, Integer currColor, boolean isPainting) {
    this.path = path;
    this.currColor = currColor;
    this.isPainting = isPainting;
    isLostHand = false;
  }
  
  boolean canRecord() {
    dontPaintCount = max(0, dontPaintCount - 1);
    return dontPaintCount == 0;
  }
  
  void startPainting() {
     isPainting = true; 
  }
  
  void stopPainting() {
    isPainting = false;  
  }
  
  boolean isPainting() {
    return isPainting; 
  }
  
  void setHandAsLost() {
     isLostHand = true; 
  }
  
  boolean isLostHand() {
     return isLostHand; 
  }
}
