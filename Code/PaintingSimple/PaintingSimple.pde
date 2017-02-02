/*
 * Simple Paint Program utilizing Kinect.
 * Jessica Wong, Lucie Hustin, Ronak Bharad, Vivek ParamasivamEa
 */


 // erase by deleting points from end of list. after erase, reset color to default color.
 // make cursor a different color
 


import java.util.Map;
import java.util.Iterator;

Kinect kinect;



// The arraylist which holds all points in painting
ArrayList<PointT> painting = new ArrayList<PointT>();

// A Map from hand ids to corresponding Hand objects
Map<Integer, Hand> handIdToHand = new HashMap<Integer, Hand>();

// constants for size of window
int HEIGHT = 480;
int WIDTH = 640;


// constants for color pallette
int PAL_BOX_HEIGHT = 100;
int PAL_Y = HEIGHT - PAL_BOX_HEIGHT;
int PAL_STROKE_WEIGHT = 5;
int MAX_COLOR_RANGE = WIDTH;
int PAL_SATURATION = (int) (0.85 * MAX_COLOR_RANGE);
int PAL_BOX_OPACITY = MAX_COLOR_RANGE / 2;

color DEFAULT_COLOR = color(128, 128, 128);    
color BLANK_COLOR = color(128, 128, 0, 0);
color BLACK_COLOR = color(0, 0, 0);
color WHITE_COLOR = color(255,255,255);

//constants for erase box
int ERASE_BOX_X = 0;
int ERASE_BOX_Y = 0;
int ERASE_BOX_HEIGHT = 80;
int ERASE_BOX_WIDTH = 80;

// constants for painting
int BRUSH_SIZE = 10;
int CURSOR_COLOR = color(255, 255, 255, 170); 
int CURSOR_WEIGHT = 10;
int CURSOR_SIZE = 60;


                                   
// Called once at the beginning of the program. Sets up the program.                             
void setup()
{
  //set window size
  size(WIDTH, HEIGHT);
  
  //Initialize the kinect device
  kinect = initializeKinect();
 
  // Tell kinect to enable depthMap generation 
  kinect.enableDepth();
  
  //Tell kinect to enable RGB
  kinect.enableRGB();
  
  // Tell kinect to enable/disable mirrorring
  kinect.setMirror(true);

  // Tell kinect to enable hands + gesture generation
  kinect.enableHand();
  kinect.startGesture(SimpleOpenNI.GESTURE_WAVE);
  kinect.startGesture(SimpleOpenNI.GESTURE_CLICK);

 }

// Called over and over until the program is stopped. 
// Used to draw in the frame.
void draw()
{
  // Tell Kinect to refresh with the newest image
  kinect.update();
  
  // use the newest image from the kinect as the background
  image(kinect.rgbImage(),0,0);
  
  // Draw the Pallette
  drawPalette();
  
  // draw erase box
  drawEraseBox();
  
  
  PVector p; // This will store the current point we want to draw
  PVector p2d = new PVector(); // This will be the current point converted to 2D coords
  PVector pOld = null; // This will store the old point in 2D converted form. We will draw a line from p2d to pOld
  
  // This map will store the most recently drawn point from each hand, so we can properly
  // draw lines.
  Map<Integer, PVector> handIdToOldPoint = new HashMap<Integer, PVector>(); 
  
  // The current point, with color stored as well
  PointT currPointT;
  
  // Get an iterator over all points in the painting. 
  // We use an iterator because as we are drawing, there could be event handlers
  // Which are modifying the painting.  
  Iterator itrVec = painting.iterator(); 
  
  // For each Point in the painting, draw a line from that point to
  // the previous paint from the same hand.
  while( itrVec.hasNext() ) 
  { 
    // Get the current point we want to draw (with its color information).
    currPointT = (PointT) itrVec.next(); 
    
    // Extract the part of this point that contains its location information
    p = currPointT.p;
    
    // Set pOld to the previous point from the same hand (if there was a previous point).
    pOld = null;
    if (handIdToOldPoint.size() > 0) {
      pOld = handIdToOldPoint.get(currPointT.handId);
      handIdToOldPoint.remove(currPointT.handId);
    }
    
    // convert the 3D point (p) to a 2D point (p2d)
    kinect.convertRealWorldToProjective(p,p2d);

    // Make sure we are drawing with this point's particular color
    stroke(currPointT.c);
    fill(currPointT.c);
    
    // If there was a previous point from this hand, draw a line between the current
    // point and the old one.
    if (pOld != null) {
     strokeWeight(BRUSH_SIZE); 
     line(pOld.x,pOld.y, p2d.x, p2d.y);
    }
    
    // remember the old point from this hand
    handIdToOldPoint.put(currPointT.handId, new PVector(p2d.x, p2d.y));

  }
    
    // Draw the cursor on each hand
   drawCursors();
      
}

// Draws the color Palette.
// When a user moves a tracked Hand into the location of this box, the
// color of that hand is changed to the color that they are hovering over.
void drawPalette() {
  strokeWeight(3);
  colorMode(HSB, MAX_COLOR_RANGE);
  for (int i = 0; i < MAX_COLOR_RANGE; i++) {
    colorMode(HSB, MAX_COLOR_RANGE);
    stroke(i, PAL_SATURATION, MAX_COLOR_RANGE, PAL_BOX_OPACITY);
    line(i, PAL_Y, i, PAL_Y + PAL_BOX_HEIGHT);
  }
  colorMode(RGB, 256); 
}

// Draws the erase box. While a tracked hand is in
// this box, the most recently drawn points by this hand are deleted.
void drawEraseBox() {
  stroke(255,255,255);
  strokeWeight(5);
  rect(ERASE_BOX_X, ERASE_BOX_Y, ERASE_BOX_WIDTH, ERASE_BOX_HEIGHT); 
}

// Draws the awesome cursors for each hand.
// The color of the cursor is the color the hand is currently drawing with.
void drawCursors() {
    noFill();
   
    PVector p; 
    PVector p2d = new PVector();
    for(Hand hand: handIdToHand.values()) {
       if(!hand.isLostHand()) {  
          p = new PVector(hand.x, hand.y, hand.z);
          p2d = new PVector();
          kinect.convertRealWorldToProjective(p,p2d);
          stroke(CURSOR_COLOR);
          if(hand.showClick > 0) {
            stroke(BLACK_COLOR);
            hand.showClick--;
          }  
          strokeWeight(CURSOR_WEIGHT / 2);
          ellipse(p2d.x, p2d.y, CURSOR_SIZE + CURSOR_WEIGHT * 2, CURSOR_SIZE + CURSOR_WEIGHT * 2);
          ellipse(p2d.x, p2d.y, CURSOR_SIZE - CURSOR_WEIGHT * 2, CURSOR_SIZE - CURSOR_WEIGHT * 2);
          color handColor = hand.currColor;
          stroke(color(handColor, 128));
          strokeWeight(CURSOR_WEIGHT);
          ellipse(p2d.x, p2d.y, CURSOR_SIZE, CURSOR_SIZE);
       }
    } 
}

// Creates a hand with the given handId at the given position, and stores it in
// handIdToHand.
void createHand(int handId, PVector pos) {
  ArrayList<PointT> vecList = new ArrayList<PointT>();
  Hand hand = new Hand(vecList, DEFAULT_COLOR, false);
  hand.x = pos.x;
  hand.y = pos.y;
  handIdToHand.put(handId, hand);
}

// Returns true if the passed-in position is inside the erase box, false otherwise.
boolean isErasing(PVector pos) { 
   // check if erasing
   return handIsInCoord(pos, ERASE_BOX_X, ERASE_BOX_X + ERASE_BOX_WIDTH, ERASE_BOX_Y + ERASE_BOX_HEIGHT, ERASE_BOX_Y);
}

// Checks to see if the passed-in location is within the color box. If so, changes the color of the hand
// with the passed-in handId to the color associated with this location.
void checkIfHandChangeColor(int handId, PVector pos) {  
  // check if color box
  //for(int i = 0; i < NUM_COLORS; i++) {
    // check if hand is in one of color boxes
    PVector p2d = new PVector();
    kinect.convertRealWorldToProjective(pos, p2d);
      Hand hand = handIdToHand.get(handId);
    if (p2d.y >= PAL_Y) {
          println("Hand is in colorbox: " + p2d.y + " is less than or equal to " + PAL_Y);
        
          colorMode(HSB, MAX_COLOR_RANGE);
          hand.currColor = color(p2d.x, PAL_SATURATION, MAX_COLOR_RANGE);
          colorMode(RGB, 256);
          hand.isChangingColor = true;
    } else {
        hand.isChangingColor = false;  
    }    
}

// Returns true if the passed-in PVector is located within the specified bounds, false otherwise.
boolean handIsInCoord(PVector pos, int left, int right, int bot, int top) {
   return pos.x > left && pos.x <= right
        && pos.y >= top && pos.y < bot;
}

// -----------------------------------------------------------------
// hand event handlers

// Called each time the Kinect detects a new hand.
void onNewHand(SimpleOpenNI curContext,int handId,PVector pos)
{
  println("onNewHand - handId: " + handId + ", pos: " + pos);
  // make a new hand at position with default color.
  createHand(handId, pos);
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
  
  // Get the Hand object
  Hand hand = handIdToHand.get(handId);
  ArrayList<PointT> vecList = hand.path;
  
  // Store this hand's current position so we can draw the cursor in
  // the draw method
  hand.x = pos.x;
  hand.y = pos.y;
  hand.z = pos.z;
  
  // Check to see if this hand is changing colors.
  checkIfHandChangeColor(handId, pos);
  
  // if the hand is not changing color, enter the statement
  if (!hand.isChangingColor) {
    // If the hand is not erasing, store its current location as a painted point in
    // the painting. This is the equivalent of drawing a single point on the painting.
    if (!isErasing(p2d) && true == true) {
       color handColor = hand.currColor;
       if(!hand.isPainting()) {
         handColor = BLANK_COLOR;
       }
       vecList.add(vecList.size(), new PointT(pos, handColor, handId));
       painting.add(painting.size(), new PointT(pos, handColor, handId));
    } else { // if erasing, delete the most recent point from this hand.
      boolean eraseAnother = true;
      while(eraseAnother) {
        PointT current = painting.get(painting.size() - 1);
        int count = 1;
        while(current.handId != handId) {
          current = painting.get(painting.size() - 1 - count);
          count ++;
        }
        eraseAnother = current.c == BLANK_COLOR;
        // current is now holding most recent point from this hand
        painting.remove(painting.size() - count);
      }
    }
  }
}

// Called by the Kinect whenever it loses track of a hand. Passes in the handId of
// the lost hand so you can deal with it.
void onLostHand(SimpleOpenNI curContext,int handId)
{
  Hand hand = handIdToHand.get(handId);
  hand.setHandAsLost();
  hand.stopPainting();
  println("onLostHand - handId: " + handId);
}

// -----------------------------------------------------------------
// gesture event handler

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
  } else if (gestureType == SimpleOpenNI.GESTURE_CLICK) { // if gesture was a click, switch between painting/not painting.
      
    
    
    
    println("[click]onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);
    //figure out which hand it is
    for(int i : handIdToHand.keySet()) {
       println("Checking hand: " + i);
       Hand hand = handIdToHand.get(i);  
       float xDiff = abs(hand.x - pos.x);
       println("xDiff: " + xDiff);
       float yDiff = abs(hand.y - pos.y);
       println("yDiff: " + yDiff);
       println("Hand is at: [" + hand.x + ", " + hand.y + "]");
       if(xDiff < 100 && yDiff < 100) {
         // found hand at location, so tell opennni to lose current hand, and make a new one.
         hand.showClick = 4;
         if(hand.isPainting()) {
           hand.stopPainting();
         } else {
           hand.startPainting();
         }
         return;
       }
     }
     println("ERROR: Couldnt not find hand at position: " + pos);
  }
}

// -----------------------------------------------------------------
// Keyboard event handlers
void keyPressed()
{

  switch(key)
  {
  case ' ':
    kinect.setMirror(!kinect.mirror());
    break;
  case '1':
    kinect.setMirror(true);
    break;
  case '2':
    kinect.setMirror(false);
    break;
  }
}
