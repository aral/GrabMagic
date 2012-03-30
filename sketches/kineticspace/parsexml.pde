void parseXML()
{
  // set all variable to their basic values
  for (int i = 0; i<numberOfPoses; i++)
  {
    weightX[i] = 1.0;
    weightY[i] = 1.0;
    weightZ[i] = 1.0;
    weightLeftOrRight[i] = 0.0;
    framesGesture[i] = framesGestureMax;
    normRotation[i] = true;
  }
  
  XMLElement xml;

  File f = new File(dataPath("setup.xml"));
  if (!f.exists()) 
  {  
    println("File " + dataPath("setup.xml") + " does not exist");
  } 
  else 
  {     
    println("File " + dataPath("setup.xml") + " does exist");
    
    xml = new XMLElement(this, dataPath("setup.xml"));
    int numcontents = xml.getChildCount();
    for (int i = 0; i < numcontents; i++) 
    {
      XMLElement subxml1 = xml.getChild(i);
      String str1 = subxml1.getName();      
      String content1 = subxml1.getContent();
      
      // println(id + "->" + str1 +  " : " + url + " : " + content1);    

      if (foundString(str1, "autodetection")) 
      {
        if (foundString(content1, "yes") || foundString(content1, "true") || foundString(content1, "on")) 
        {
          autoPoseDetection = true;
          println("autodetection = on");
        }
        if (foundString(content1, "no") || foundString(content1, "false") || foundString(content1, "off")) 
        {
          autoPoseDetection = false;
          println("autodetection = off");
        }
      }

      if (foundString(str1, "usemultithreading")) 
      {
        if (foundString(content1, "yes") || foundString(content1, "true") || foundString(content1, "on")) 
        {
          useMultiThreading = true;
          println("usemultithreading = on");
        }
        if (foundString(content1, "no") || foundString(content1, "false") || foundString(content1, "off")) 
        {
          useMultiThreading = false;
          println("usemultithreading = off");
        }
      }

      if (foundString(str1, "normalize")) 
      {        
        int numsubxml1 = subxml1.getChildCount();
        for (int j = 0; j < numsubxml1; j++) 
        {
          XMLElement subxml2 = subxml1.getChild(j);
          String str2 = subxml2.getName();
          String content2 = subxml2.getContent();

          // println(str1 + "->" + str2 +  " : " + content2);

          if (foundString(str2, "size")) 
          {
            if (foundString(content2, "yes") || foundString(content2, "true") || foundString(content2, "on")) 
            {
              NORMALIZE_SIZE = true;
              println("normalize size = on");
            }
            if (foundString(content2, "no") || foundString(content2, "false") || foundString(content2, "off")) 
            {
              NORMALIZE_SIZE = false;
              println("normalize size = off");
            }
          }

          if (foundString(str2, "rotation")) 
          {
            if (foundString(content2, "yes") || foundString(content2, "true") || foundString(content2, "on")) 
            {
              for (int k = 0; k<numberOfPoses; k++)
              {
                normRotation[k] = true;
              }
            }
            if (foundString(content2, "no") || foundString(content2, "false") || foundString(content2, "off")) 
            {
              for (int k = 0; k<numberOfPoses; k++)
              {
                normRotation[k] = false;
              }
            }
          }
        }
      }
      
      if (foundString(str1, "weight")) 
      {        
        int numsubxml1 = subxml1.getChildCount();
        for (int j = 0; j < numsubxml1; j++) 
        {
          XMLElement subxml2 = subxml1.getChild(j);
          String str2 = subxml2.getName();
          String content2 = subxml2.getContent();

          if (foundString(str2, "x")) 
          {
            float x = Float.valueOf(content2).floatValue();
            for (int k = 0; k<numberOfPoses; k++)
            {
              weightX[k] = x;
            }
          }
          if (foundString(str2, "y"))
          {
            float y = Float.valueOf(content2).floatValue();
            for (int k = 0; k<numberOfPoses; k++)
            {
              weightY[k] = y;
            }
          }
          if (foundString(str2, "z"))
          {
            float z = Float.valueOf(content2).floatValue();
            for (int k = 0; k<numberOfPoses; k++)
            {
              weightZ[k] = z;
            }            
          }
        }
      }

      if (foundString(str1, "bodypart")) 
      {
        if (foundString(content1, "leftarm")) 
        {
          for (int k = 0; k<numberOfPoses; k++)
          {
            weightLeftOrRight[k] = -1.0;
          }
        }
        if (foundString(content1, "rightarm")) 
        {
          for (int k = 0; k<numberOfPoses; k++)
          {
            weightLeftOrRight[k] = 1.0;
          }
        }
        if (foundString(content1, "botharms")) 
        {
          for (int k = 0; k<numberOfPoses; k++)
          {
            weightLeftOrRight[k] = 0.0;
          }
        }
      }

      if (foundString(str1, "frames")) 
      {
        int frames = Integer.parseInt(content1);
        for (int k = 0; k<numberOfPoses; k++)
        {
          if (frames > framesGestureMax)
          {
            frames = framesGestureMax;
          }
          framesGesture[k] = frames;
        }
      }

      if (foundString(str1, "gesture")) 
      {  
        int numsubxml1 = subxml1.getChildCount();
        
        // remember values
        int id = -1;
        int frames = -1;
        int nr = -1; 
        float lr = sqrt(-1);
        float x = -1.0;        
        float y = -1.0;        
        float z = -1.0;
        
        for (int j = 0; j < numsubxml1; j++) 
        {
          XMLElement subxml2 = subxml1.getChild(j);
          String str2 = subxml2.getName();
          String content2 = subxml2.getContent();

          if (foundString(str2, "id")) {
            id = Integer.parseInt(content2);
          }

          if (foundString(str2, "frames")) {
            frames = Integer.parseInt(content2);
          }

          if (foundString(str2, "normalize_rotation")) {
            if (foundString(content2, "yes") || foundString(content2, "true") || foundString(content2, "on")) 
            {
              nr = 1;
            }
            if (foundString(content2, "no") || foundString(content2, "false") || foundString(content2, "off")) 
            {
              nr = 0;
            }
          }

          if (foundString(str2, "bodypart")) {
            if (foundString(content2, "leftarm")) 
            {
              lr = -1.0;
            }
            if (foundString(content2, "rightarm")) 
            {
              lr = 1.0;
            }
            if (foundString(content2, "botharms")) 
            {
              lr = 0.0;
            }
          }

          if (foundString(str2, "weight")) 
          {
            int numsubxml2 = subxml2.getChildCount();
            for (int k = 0; k < numsubxml2; k++) 
            {
              XMLElement subxml3 = subxml2.getChild(k);
              String str3 = subxml3.getName();
              String content3 = subxml3.getContent();
              
              if (foundString(str3, "x")) 
              {
                x = Float.valueOf(content3).floatValue();
              }
              if (foundString(str3, "y"))
              {
                y = Float.valueOf(content3).floatValue();
              }
              if (foundString(str3, "z"))
              {
                z = Float.valueOf(content3).floatValue();
              }
            }
          }
        }
        
        if ((id >=0) && (id<numberOfPoses))
        {
          if (frames>=0) framesGesture[id] = frames;
          if (x>=0) weightX[id] = x;
          if (y>=0) weightY[id] = y;
          if (z>=0) weightZ[id] = z;
          if (nr==0) normRotation[id] = false;
          if (nr==1) normRotation[id] = true;
          if ((lr>=1) && (lr<=1)) weightLeftOrRight[id] = lr;
        }
      }    
    }
  }
  
  for (int id=0; id<numberOfPoses ; id++)
  {
    String strlr = "both arms";
    if (weightLeftOrRight[id]<0) strlr = "left arm";
    if (weightLeftOrRight[id]>0) strlr = "right arm";
    String rotnorm = "rotation normalized";
    if (!normRotation[id]) rotnorm = "rotation not normalized";
    println("gesture #" + id + ") = weights(x,y,z) " + weightX[id] + ", " + weightY[id] + ", " + weightZ[id] + "; frames " + framesGesture[id] + "; " + strlr + "; " + rotnorm);
  }
}

boolean foundString(String str1, String str2)
{
  boolean found = false;
  
  if ((str1 == null) || (str2 == null)) return false;
  
  String[] m1 = match(str1, str2);
  if (m1 != null) {
    found = true;
  }  
  
  m1 = match(str2, str1);
  if (m1 != null) {
    found = true;
  }
  
  return found;
}
