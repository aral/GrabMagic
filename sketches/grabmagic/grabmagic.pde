/* 
  MIPBoatHack - Grab Magic. 
  A hack by Aral Balkan. 
  http://aralbalkan.com
  Using the excellent SimpleOpenNI.
*/

import fullscreen.*;

// GSVideo has better performance
import codeanticode.gsvideo.*;

// Web socket support.
import org.webbitserver.*;
import muthesius.net.WebSocketP5;

FullScreen fs;
GSMovie theMovie;
WebSocketP5 socket;

void setup() {
  size(1280,720);
  background(0);
  
  fs = new FullScreen(this);
  fs.enter();
 
  // Start playing the movie
  theMovie = new GSMovie(this, "trailer_720p.mov");
  theMovie.frameRate(30);
  theMovie.loop();
  
  // Get the socket ready 
  socket = new WebSocketP5(this, 8080); 

  
}

// Movie 
void movieEvent(GSMovie theMovie) {
 theMovie.read(); 
}

void draw(){
  image(theMovie, 0,0);
  
  String json = "{\"frame\": 42}";
  socket.broadcast(json);
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
