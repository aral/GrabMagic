/* 
  MIPBoatHack - Grab Magic. 
  A hack by Aral Balkan. 
  http://aralbalkan.com
  Using the excellent SimpleOpenNI.
*/

import fullscreen.*;

// GSVideo has better performance - trying out OpenGL version
import codeanticode.gsvideo.*;
//import processing.video.*;
import processing.opengl.*;
import codeanticode.glgraphics.*;

// Web socket support.
import org.webbitserver.*;
import muthesius.net.WebSocketP5;

// Kinect (SimpleOpenNI and NITE)
import SimpleOpenNI.*;

// Sound
import ddf.minim.*;



// Visual hints
boolean isCalibrated = false; 
boolean hasGrabbed = false;

FullScreen fs;
GSMovie theMovie;
//Movie theMovie;
GLTexture tex;

WebSocketP5 socket;

// OpenNI
SimpleOpenNI          context;

// NITE
XnVSessionManager     sessionManager;
XnVSelectableSlider2D trackPad;

int gridX = 7;
int gridY = 5;

Trackpad   trackPadViz;

// Audio
Minim minim;
AudioSample shutterSoundSample;

// GSMovie/GLGraphics OpenGL stuff
int fcount, lastm;
float frate;
int fint = 3;

int screenWidth = 1280;
int screenHeight = 800;

boolean showKinectOverlay = false;

void setup() {
  size(screenWidth, screenHeight, GLConstants.GLGRAPHICS);
  frameRate(90);
  background(0);

  // Sound
  minim = new Minim(this);
  shutterSoundSample = minim.loadSample("shutter.wav", 2048);
  
  //fs = new FullScreen(this);
  //fs.enter();
 
  // Start playing the movie
  theMovie = new GSMovie(this, "trailer_720p.mov");
  //theMovie = new Movie(this, "trailer_720p.mov");
  //theMovie = new Movie(this, "trailer_mid.mp4");

 // Use texture tex as the destination for the movie pixels.
  tex = new GLTexture(this);
  theMovie.setPixelDest(tex);

  // This is the size of the buffer where frames are stored
  // when they are not rendered quickly enough.
  tex.setPixelBufferSize(10);
  // New frames put into the texture when the buffer is full
  // are deleted forever, so this could lead dropeed frames:
  tex.delPixelsWhenBufferFull(false);
  // Otherwise, they are kept by gstreamer and will be sent
  // again later. This avoids loosing any frames, but increases 
  // the memory used by the application.

  //theMovie.frameRate(12);
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
//void movieEvent(Movie theMovie) {
// theMovie.read();
//}

void draw(){
  //image(theMovie, 0,0);
  
  // Render the movie frame using GLGraphics
    // Using the available() method and reading the new frame inside draw()
  // instead of movieEvent() is the most effective way to keep the 
  // audio and video synchronization.
  if (theMovie.available()) {
    theMovie.read();
    // putPixelsIntoTexture() copies the frame pixels to the OpenGL texture
    // encapsulated by the tex object. 
    if (tex.putPixelsIntoTexture()) {
      
      // Calculating height to keep aspect ratio.      
      float h = width * tex.height / tex.width;
      float b = 0.5 * (height - h);

      image(tex, 0, b, width, h);

      /*
        //Debug info      
        String info = "Resolution: " + theMovie.width + "x" + theMovie.height +
                      " , framerate: " + nfc(frate, 2) + 
                      " , number of buffered frames: " + tex.getPixelBufferUse();
          
        fill(0);
        rect(0, 0, textWidth(info), b);
        fill(255);
        text(info, 0, screenHeight-40);
  
      fcount += 1;
      int m = millis();
      if (m - lastm > 1000 * fint) {
        frate = float(fcount) / fint;
        fcount = 0;
        lastm = m; 
      }      
      */
    }
  }
  
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
  
  // Show calibration by color
  if (isCalibrated) {
     stroke(0, 255, 0);
  } else { 
     stroke(255,255,255); 
  }
  
  /*
  if (hasGrabbed) {
     stroke(0, 0, 0);
     hasGrabbed = false; 
  }
  */
  


  // Draw a border around the image to signal calibration
  // Green = OK
  // White = non-calibrated
  strokeWeight(30);
  line(5,40,screenWidth-5,40);
  line(screenWidth-5, 35, screenWidth-5, screenHeight-35);
  line(screenWidth-5, screenHeight-40, 5, screenHeight-40);
  line(5, screenHeight-35, 5, 35);
 
  // If the user has grabbed the screen, flash white  
  if (hasGrabbed) {
    noStroke();
    fill(255,255,255);
    rect(0, 40, screenWidth, screenHeight-80);
    hasGrabbed = false;
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
        shutterSoundSample.close();
        minim.stop();
        
        super.stop();
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
  
  //println("Movie time: " + movieTime);
  
  shutterSoundSample.trigger();
  
  hasGrabbed = true;
   
}

void onPrimaryPointCreate(XnVHandPointContext pContext,XnPoint3D ptFocus)
{
  println("onPrimaryPointCreate");
  
  trackPadViz.enable();
  isCalibrated = true;
  
}

void onPrimaryPointDestroy(int nID)
{
  println("onPrimaryPointDestroy");
  
  trackPadViz.disable();
  isCalibrated = false;
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
