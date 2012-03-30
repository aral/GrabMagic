// normalize the size of the person
Pose normalizeSize(Pose pose) {
  // define the size of the normalized person
  float scaleFactor = 1.0;
  float normalShoulderWidth = 370*scaleFactor;
  
  float normalLeftUpperArmLength = 320*scaleFactor;
  float normalRightUpperArmLength = 320*scaleFactor;
  
  float normalLeftLowerArmLength = 300*scaleFactor;
  float normalRightLowerArmLength = 300*scaleFactor;

  // normalize shoulder width
  PVector shoulderVector = new PVector();
  
  shoulderVector.x = pose.jointLeftShoulderRelative.x - pose.jointRightShoulderRelative.x;
  shoulderVector.y = pose.jointLeftShoulderRelative.y - pose.jointRightShoulderRelative.y;
  shoulderVector.z = pose.jointLeftShoulderRelative.z - pose.jointRightShoulderRelative.z;

  float shoulderWidth = shoulderVector.mag();  
  float shoulderNormalizationFactor = normalShoulderWidth/shoulderWidth;
  
  pose.jointLeftShoulderRelative.x *= shoulderNormalizationFactor;
  pose.jointLeftShoulderRelative.y *= shoulderNormalizationFactor;
  pose.jointLeftShoulderRelative.z *= shoulderNormalizationFactor;
  
  pose.jointLeftElbowRelative.x *= shoulderNormalizationFactor;
  pose.jointLeftElbowRelative.y *= shoulderNormalizationFactor;
  pose.jointLeftElbowRelative.z *= shoulderNormalizationFactor;
  
  pose.jointLeftHandRelative.x *= shoulderNormalizationFactor;
  pose.jointLeftHandRelative.y *= shoulderNormalizationFactor;
  pose.jointLeftHandRelative.z *= shoulderNormalizationFactor;
  
  pose.jointRightShoulderRelative.x *= shoulderNormalizationFactor;
  pose.jointRightShoulderRelative.y *= shoulderNormalizationFactor;
  pose.jointRightShoulderRelative.z *= shoulderNormalizationFactor;
  
  pose.jointRightElbowRelative.x *= shoulderNormalizationFactor;
  pose.jointRightElbowRelative.y *= shoulderNormalizationFactor;
  pose.jointRightElbowRelative.z *= shoulderNormalizationFactor;
  
  pose.jointRightHandRelative.x *= shoulderNormalizationFactor;
  pose.jointRightHandRelative.y *= shoulderNormalizationFactor;
  pose.jointRightHandRelative.z *= shoulderNormalizationFactor;
  
  // normalize upper arms length
  PVector leftUpperArmVector = new PVector();
  PVector rightUpperArmVector = new PVector();

  leftUpperArmVector.x = pose.jointLeftElbowRelative.x - pose.jointLeftShoulderRelative.x;
  leftUpperArmVector.y = pose.jointLeftElbowRelative.y - pose.jointLeftShoulderRelative.y;
  leftUpperArmVector.z = pose.jointLeftElbowRelative.z - pose.jointLeftShoulderRelative.z;

  rightUpperArmVector.x = pose.jointRightElbowRelative.x - pose.jointRightShoulderRelative.x;
  rightUpperArmVector.y = pose.jointRightElbowRelative.y - pose.jointRightShoulderRelative.y;
  rightUpperArmVector.z = pose.jointRightElbowRelative.z - pose.jointRightShoulderRelative.z;
    
  float leftUpperArmLength = leftUpperArmVector.mag();
  float rightUpperArmLength = rightUpperArmVector.mag();
  
  float leftUpperArmNormalizationFactor = normalLeftUpperArmLength/leftUpperArmLength;
  float rightUpperArmNormalizationFactor = normalRightUpperArmLength/rightUpperArmLength;
  
  PVector oldLeftElbow = new PVector(pose.jointLeftElbowRelative.x, pose.jointLeftElbowRelative.y, pose.jointLeftElbowRelative.z);
  PVector oldRightElbow = new PVector(pose.jointRightElbowRelative.x, pose.jointRightElbowRelative.y, pose.jointRightElbowRelative.z);
    
  pose.jointLeftElbowRelative.mult(leftUpperArmNormalizationFactor);
  pose.jointRightElbowRelative.mult(rightUpperArmNormalizationFactor);
  
  PVector leftHandMoveVector = new PVector(pose.jointLeftElbowRelative.x, pose.jointLeftElbowRelative.y, pose.jointLeftElbowRelative.z);
  leftHandMoveVector.sub(oldLeftElbow);
  PVector rightHandMoveVector = new PVector(pose.jointRightElbowRelative.x, pose.jointRightElbowRelative.y, pose.jointRightElbowRelative.z);
  rightHandMoveVector.sub(oldRightElbow);
  
  pose.jointLeftHandRelative.add(leftHandMoveVector);
  
  pose.jointRightHandRelative.add(rightHandMoveVector);
   
  // normalize lower arms length
  PVector leftLowerArmVector = new PVector();
  PVector rightLowerArmVector = new PVector();

  leftLowerArmVector.x = pose.jointLeftElbowRelative.x - pose.jointLeftHandRelative.x;
  leftLowerArmVector.y = pose.jointLeftElbowRelative.y - pose.jointLeftHandRelative.y;
  leftLowerArmVector.z = pose.jointLeftElbowRelative.z - pose.jointLeftHandRelative.z;

  rightLowerArmVector.x = pose.jointRightElbowRelative.x - pose.jointRightHandRelative.x;
  rightLowerArmVector.y = pose.jointRightElbowRelative.y - pose.jointRightHandRelative.y;
  rightLowerArmVector.z = pose.jointRightElbowRelative.z - pose.jointRightHandRelative.z;
  
  float leftLowerArmLength = leftLowerArmVector.mag();
  float rightLowerArmLength = rightLowerArmVector.mag();
  
  float leftLowerArmNormalizationFactor = normalLeftLowerArmLength/leftLowerArmLength;
  float rightLowerArmNormalizationFactor = normalRightLowerArmLength/rightLowerArmLength;
  
  leftLowerArmVector.mult(leftLowerArmNormalizationFactor);
  rightLowerArmVector.mult(rightLowerArmNormalizationFactor);
  
  PVector newLeftHandPosition = new PVector(pose.jointLeftElbowRelative.x, pose.jointLeftElbowRelative.y, pose.jointLeftElbowRelative.z);   
  PVector newRightHandPosition = new PVector(pose.jointRightElbowRelative.x, pose.jointRightElbowRelative.y, pose.jointRightElbowRelative.z);   
  
  newLeftHandPosition.sub(leftLowerArmVector);
  newRightHandPosition.sub(rightLowerArmVector);
  
  pose.jointLeftHandRelative = newLeftHandPosition;
  pose.jointRightHandRelative = newRightHandPosition;
  
  return pose;
}

// all the poses will be rotatet. need neck-relative position (as origin)
Pose normalizeRotation(Pose pose) {
  Pose poseNormalized;
  poseNormalized = new Pose();
  
  // get vector between shoulders and computer the normal in the middle of the way
  // only 2d vector, as angle between only computes one angle (x,y component)
  PVector leftToRight = new PVector();
  leftToRight.x = pose.jointRightShoulderRelative.x - pose.jointLeftShoulderRelative.x;
  leftToRight.y = pose.jointRightShoulderRelative.z - pose.jointLeftShoulderRelative.z;

  // normalize
  leftToRight.normalize();
  
  // the orientation in the view from the kinect sensor
  PVector facingV = new PVector(1, 0); //use the normal to the z-direction (facing of the k.sensor) //0,1);

  // 0 -> front face to sensor face
  // 90 -> turned front to right
  // -90 -> turned front to left
  float fradians = PVector.angleBetween(leftToRight, facingV);
  float angle = degrees( fradians );

  if (leftToRight.y < 0)
  {
    angle = -angle;
    fradians = -fradians;
  } 
  
  // TODO compute back-facing vector (test sign )
  // negative x is with face to the kinect device,   

  // rotate all bones by this angle, so that the recognisable   
  float fcos = cos(-fradians);
  float fsin = sin(-fradians);

  poseNormalized.jointLeftShoulderRelative.x = fcos *   pose.jointLeftShoulderRelative.x  - fsin *   pose.jointLeftShoulderRelative.z;
  poseNormalized.jointLeftShoulderRelative.z = fsin *   pose.jointLeftShoulderRelative.x  + fcos *   pose.jointLeftShoulderRelative.z;

  PVector leftER = new PVector();
  poseNormalized.jointLeftElbowRelative.x = fcos * pose.jointLeftElbowRelative.x  - fsin * pose.jointLeftElbowRelative.z;
  poseNormalized.jointLeftElbowRelative.z = fsin * pose.jointLeftElbowRelative.x  + fcos * pose.jointLeftElbowRelative.z;

  PVector leftHR = new PVector();
  poseNormalized.jointLeftHandRelative.x = fcos * pose.jointLeftHandRelative.x  - fsin * pose.jointLeftHandRelative.z;
  poseNormalized.jointLeftHandRelative.z = fsin * pose.jointLeftHandRelative.x  + fcos * pose.jointLeftHandRelative.z;

  PVector rightSR = new PVector();
  poseNormalized.jointRightShoulderRelative.x = fcos * pose.jointRightShoulderRelative.x  - fsin * pose.jointRightShoulderRelative.z;
  poseNormalized.jointRightShoulderRelative.z = fsin * pose.jointRightShoulderRelative.x  + fcos * pose.jointRightShoulderRelative.z;

  PVector rightER = new PVector();
  poseNormalized.jointRightElbowRelative.x = fcos * pose.jointRightElbowRelative.x  - fsin * pose.jointRightElbowRelative.z;
  poseNormalized.jointRightElbowRelative.z = fsin * pose.jointRightElbowRelative.x  + fcos * pose.jointRightElbowRelative.z;

  PVector rightHR = new PVector();
  poseNormalized.jointRightHandRelative.x = fcos * pose.jointRightHandRelative.x  - fsin * pose.jointRightHandRelative.z;
  poseNormalized.jointRightHandRelative.z = fsin * pose.jointRightHandRelative.x  + fcos * pose.jointRightHandRelative.z;
  
  return poseNormalized;
}

