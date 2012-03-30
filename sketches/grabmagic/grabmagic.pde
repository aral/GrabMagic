/* 
  MIPBoatHack - Grab Magic. 
  A hack by Aral Balkan. 
  http://aralbalkan.com
  Using the excellent SimpleOpenNI.
*/

import fullscreen.*;

// GSVideo has better performance
//import codeanticode.gsvideo.*;
import processing.video.*;

// Web socket support.
import org.webbitserver.*;
import muthesius.net.WebSocketP5;

// Kinect (SimpleOpenNI and NITE)
import SimpleOpenNI.*;

// Visual hints
boolean isCalibrated = false; 
boolean hasGrabbed = false;

FullScreen fs;
//GSMovie theMovie;
Movie theMovie;

WebSocketP5 socket;

////
SimpleOpenNI          context;

// NITE
XnVSessionManager     sessionManager;
XnVSelectableSlider2D trackPad;

int gridX = 7;
int gridY = 5;

Trackpad   trackPadViz;
////

int screenWidth = 1280;
int screenHeight = 720;

boolean showKinectOverlay = false;

void setup() {
  size(screenWidth, screenHeight);
  background(0);
  
  //fs = new FullScreen(this);
  //fs.enter();
 
  // Start playing the movie
  //theMovie = new GSMovie(this, "trailer_720p.mov");
  theMovie = new Movie(this, "trailer_720p.mov");
  theMovie.frameRate(12);
  theMovie.loop();
  
  // Get the socket ready 
  socket = new WebSocketP5(this, 8080); 

  // Kinect
  context = new SimpleOpenNI(this,SimpleOpenNI.RUN_MODE_MULTI_THREADED);
   
  // mirror is by default enabled
  context.setMirror(true);
  
  // enable depthMap generation 
  if(context.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }
  
  // enable the hands + gesture
  context.enableGesture();
  context.enableHands();
 
  // setup NITE 
  sessionManager = context.createSessionManager("Click,Wave", "RaiseHand");

  trackPad = new XnVSelectableSlider2D(gridX,gridY);
  sessionManager.AddListener(trackPad);

  trackPad.RegisterItemHover(this);
  trackPad.RegisterValueChange(this);
  trackPad.RegisterItemSelect(this);
  
  trackPad.RegisterPrimaryPointCreate(this);
  trackPad.RegisterPrimaryPointDestroy(this);

  // create gui viz
  //trackPadViz = new Trackpad(new PVector(context.depthWidth()/2, context.depthHeight()/2,0),
  //                                       gridX,gridY,50,50,15);
//  Trackpad(PVector center,int xRes,int yRes,int width,int height,int space)
  
  trackPadViz = new Trackpad(new PVector(screenWidth/2, screenHeight/2,0),
                                         gridX,gridY,50,50,15);
  // Setting to size of movie not Kinect context
  //size(context.depthWidth(), context.depthHeight()); 
  smooth();
  
   // info text
  println("-------------------------------");  
  println("1. Wave till the tiles get green");  
  println("2. The relative hand movement will select the tiles");  
  println("-------------------------------");    
}

// Movie 
//void movieEvent(GSMovie theMovie) {
void movieEvent(Movie theMovie) {
 theMovie.read();
}

void draw(){
  image(theMovie, 0,0);
  
  // TODO: Do broadcast only when a frame is grabbed.
  //String json = "{\"frame\": 42}";
  //socket.broadcast(json);
  
  //
  // Kinect
  //
  
  // update the cam
  context.update();
  
  // update nite
  context.update(sessionManager);
  
  
  if (showKinectOverlay) {
    // draw depthImageMap
    image(context.depthImage(),0,0, context.depthWidth()/2, context.depthHeight()/2);
    trackPadViz.draw();
  }
}

//
// Websocket handlers
//

void websocketOnMessage(WebSocketConnection con, String msg){
  println(msg);
}

void websocketOnOpen(WebSocketConnection con){
  println("A client joined");
}

void websocketOnClosed(WebSocketConnection con){
  println("A client left");
}

void stop(){
	socket.stop();
}

// 
// Key handlers
//
void keyPressed()
{
  switch(key)
  {
  case 'o':
    showKinectOverlay = !showKinectOverlay;
    println("Toggling overlay…");
    break;
    
  case 'e':
    // end sessions
    sessionManager.EndSession();
    println("end session");
    break;
  }
}

//
// Kinect handlers
//

/////////////////////////////////////////////////////////////////////////////////////////////////////
// session callbacks

void onStartSession(PVector pos)
{
  println("onStartSession: " + pos);
}

void onEndSession()
{
  println("onEndSession: ");
}

void onFocusSession(String strFocus,PVector pos,float progress)
{
  println("onFocusSession: focus=" + strFocus + ",pos=" + pos + ",progress=" + progress);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
// XnVSelectableSlider2D callbacks

void onItemHover(int nXIndex,int nYIndex)
{
  println("onItemHover: nXIndex=" + nXIndex +" nYIndex=" + nYIndex);
  
  trackPadViz.update(nXIndex,nYIndex);
}

void onValueChange(float fXValue,float fYValue)
{
 // println("onValueChange: fXValue=" + fXValue +" fYValue=" + fYValue);
}

void onItemSelect(int nXIndex,int nYIndex,int eDir)
{
  println("onItemSelect: nXIndex=" + nXIndex + " nYIndex=" + nYIndex + " eDir=" + eDir);
  trackPadViz.push(nXIndex,nYIndex,eDir);
  
  // Get the time from the video and broadcast it (The MPMoviePlayerController is time based)
  float movieTime = theMovie.time();
  socket.broadcast(""+movieTime);
  
  println("Movie time: " + movieTime);
   
}

void onPrimaryPointCreate(XnVHandPointContext pContext,XnPoint3D ptFocus)
{
  println("onPrimaryPointCreate");
  
  trackPadViz.enable();
  
  
}

void onPrimaryPointDestroy(int nID)
{
  println("onPrimaryPointDestroy");
  
  trackPadViz.disable();
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Trackpad

class Trackpad
{
  int     xRes;
  int     yRes;
  int     width;
  int     height;
  
  boolean active;
  PVector center;
  PVector offset;
  
  int      space;
  
  int      focusX;
  int      focusY;
  int      selX;
  int      selY;
  int      dir;
  
  
  Trackpad(PVector center,int xRes,int yRes,int width,int height,int space)
  {
    this.xRes     = xRes;
    this.yRes     = yRes;
    this.width    = width;
    this.height   = height;
    active        = false;
    
    this.center = center.get();
    offset = new PVector();
    offset.set(-(float)(xRes * width + (xRes -1) * space) * .5f,
               -(float)(yRes * height + (yRes -1) * space) * .5f,
               0.0f);
    offset.add(this.center);
    
    this.space = space;
  }
  
  void enable()
  {
    active = true;
    
    focusX = -1;
    focusY = -1;
    selX = -1;
    selY = -1;
  }
  
  void update(int indexX,int indexY)
  {
    focusX = indexX;
    focusY = (yRes-1) - indexY;
  }
  
  void push(int indexX,int indexY,int dir)
  {
    selX = indexX;
    selY =  (yRes-1) - indexY;
    this.dir = dir;
  }
  
  void disable()
  {
    active = false;
  }
  
  void draw()
  {    
    pushStyle();
    pushMatrix();
    
      translate(offset.x,offset.y);
    
      for(int y=0;y < yRes;y++)
      {
        for(int x=0;x < xRes;x++)
        {
          if(active && (selX == x) && (selY == y))
          { // selected object 
            fill(100,100,220,190);
            strokeWeight(3);
            stroke(100,200,100,220);
          }
          else if(active && (focusX == x) && (focusY == y))
          { // focus object 
            fill(100,255,100,220);
            strokeWeight(3);
            stroke(100,200,100,220);
          }
          else if(active)
          {  // normal
            strokeWeight(3);
            stroke(100,200,100,190);
            noFill();
          }
          else
          {
            strokeWeight(2);
            stroke(200,100,100,60);
            noFill();
          }
           rect(x * (width + space),y * (width + space),width,height);  
        }
      }
    popMatrix();
    popStyle();  
  }
}
