
Kinect kinect;

int WIDTH = 640;
int HEIGHT = 480;
int RECT_WIDTH = 400;
int RECT_HEIGHT = 200;
int RECT_X = 200;
int RECT_Y = 100;

Hand hand = null;
void setup()
{
  size(WIDTH, HEIGHT);
  kinect = initializeKinect();
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.setMirror(true);
  kinect.enableHand();
  kinect.startGesture(SimpleOpenNI.GESTURE_WAVE);
  //kinect.startGesture(SimpleOpenNI.GESTURE_CLICK);
  
   
}

void draw()
{
 kinect.update();
 image(kinect.rgbImage(), 0, 0); 
 if(hand != null) {
    drawBox(hand);
 }

}

void drawBox(Hand hand) 
{
 noFill();
 stroke(255,255,255);
 strokeWeight(2);
 println(hand.z);
 rectMode(CENTER);
 rect(hand.x, hand.y, RECT_WIDTH, RECT_HEIGHT);
 fill(200, 0, 0, 128);
 rect(hand.x, hand.y, 400 - hand.z / 4, 200 - hand.z /8 );
}

// Kinect calls this method whenever it detects that a gesture has been made.
// int gestureType represents the gesture type, which will be one of the following: 
// GESTURE_CLICK
// GESTURE_HAND_RAISE
// GESTURE_WAVE
// The Kinect also will pass-in the location of the hand when the gesture was completed.
void onCompletedGesture(SimpleOpenNI curContext,int gestureType, PVector pos)
{
  // If gesture was a wave, track the hand.
  if (gestureType == SimpleOpenNI.GESTURE_WAVE) {
    println("[wave]onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);
    
    int handId = kinect.startTrackingHand(pos);
    println("hands tracked: " + handId);
  }
}

// Called each time the Kinect detects a new hand.
void onNewHand(SimpleOpenNI curContext,int handId,PVector pos)
{
  println("onNewHand - handId: " + handId + ", pos: " + pos);
  // make a new hand at position with default color.
  createHand(handId, pos);
}

// Creates a hand with the given handId at the given position, and stores it in
// handIdToHand.
void createHand(int handId, PVector pos) {
  ArrayList<PointT> vecList = new ArrayList<PointT>();
  hand = new Hand();
  PVector p2d = new PVector();
  kinect.convertRealWorldToProjective(pos, p2d);
  hand.x = p2d.x;
  hand.y = p2d.y;
  hand.z = p2d.z;
}

// The Kinect calls this method for each hand it is tracking each clock cycle.
// (You can think of this as being called in a loop for each hand).
// The PVector pos is the most recent position of the hand with the passed-in handId.
void onTrackedHand(SimpleOpenNI curContext, int handId, PVector pos)
{
  //println("onTrackedHand - handId: " + handId + ", pos: " + pos );
  
  // Convert the hand's location to 2D coordinates
  PVector p2d = new PVector();
  kinect.convertRealWorldToProjective(pos, p2d);

  // Store this hand's current position so we can draw the cursor in
  // the draw method
  hand.x = p2d.x;
  hand.y = p2d.y;
  hand.z = p2d.z;
}
