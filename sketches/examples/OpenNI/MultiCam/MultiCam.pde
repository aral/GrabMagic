/* --------------------------------------------------------------------------
 * SimpleOpenNI Multi Camera Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
 * date:  11/08/2011 (m/d/y)
 * ----------------------------------------------------------------------------
 * Be aware that you shouln't put the cameras at the same usb bus(usb performance!).
 * On linux/OSX  you can use 'lsusb' to see on which bus the camera is
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;

SimpleOpenNI  cam1;
SimpleOpenNI  cam2;

void setup()
{
  size(640 * 2 + 10,480 * 2 + 10); 

  // start OpenNI, loads the library
  SimpleOpenNI.start();
  
  // print all the cams 
  StrVector strList = new StrVector();
  SimpleOpenNI.deviceNames(strList);
  for(int i=0;i<strList.size();i++)
    println(i + ":" + strList.get(i));

  // init the cameras
  cam1 = new SimpleOpenNI(0,this);
  cam2 = new SimpleOpenNI(1,this);

  // set the camera generators
  // enable depthMap generation 
  if(cam1.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }
  cam1.enableIR();
 
  // enable depthMap generation 
  if(cam2.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }
  cam2.enableIR();
 
  background(10,200,20);
}

void draw()
{
  // update the cam
  SimpleOpenNI.updateAll();
  
  // draw depthImageMap
  image(cam1.depthImage(),0,0);
  image(cam1.irImage(),0,480 + 10);
  
  image(cam2.depthImage(),640 + 10,0);
  image(cam2.irImage(),640 + 10,480 + 10);
  
}
