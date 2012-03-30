class Data {
    ArrayList datalist;
    String filename,data[];
    int datalineId;
 
    // begin data saving
    void beginSave() {
        datalist=new ArrayList();
    }
 
    void add(String s) {
        datalist.add(s);
    }
 
    void add(float val) {
        datalist.add(""+val);
    }
 
    void add(int val) {
        datalist.add(""+val);
    }
 
    void add(boolean val) {
        datalist.add(""+val);
    }
 
    void endSave(String _filename) {
        filename=_filename;
 
        data=new String[datalist.size()];
        data=(String [])datalist.toArray(data);
     
        saveStrings(filename, data);
        println("Saved data to '"+filename+"', "+data.length+" lines.");
    }
 
    void load(String _filename) {
        filename=_filename;
     
        datalineId=0;
        data=loadStrings(filename);
        println("Loaded data from '"+filename+"', "+data.length+" lines.");
    }
 
    float readFloat() {
        return float(data[datalineId++]);
    }
 
    int readInt() {
      return int(data[datalineId++]);
    }
 
    boolean readBoolean() {
        return boolean(data[datalineId++]);
    }
 
    String readString() {
        return data[datalineId++];
    }
}

void saveData(int moveID) { 
    data.beginSave();
    for (int j=1; j < framesGestureMax; j++)
    {
        data.add(move[moveID][j].jointLeftShoulderRelative.x);
        data.add(move[moveID][j].jointLeftShoulderRelative.y);
        data.add(move[moveID][j].jointLeftShoulderRelative.z);
        
        data.add(move[moveID][j].jointLeftElbowRelative.x);
        data.add(move[moveID][j].jointLeftElbowRelative.y);
        data.add(move[moveID][j].jointLeftElbowRelative.z);
        
        data.add(move[moveID][j].jointLeftHandRelative.x);
        data.add(move[moveID][j].jointLeftHandRelative.y);
        data.add(move[moveID][j].jointLeftHandRelative.z);
        
        data.add(move[moveID][j].jointRightShoulderRelative.x);
        data.add(move[moveID][j].jointRightShoulderRelative.y);
        data.add(move[moveID][j].jointRightShoulderRelative.z);
        
        data.add(move[moveID][j].jointRightElbowRelative.x);
        data.add(move[moveID][j].jointRightElbowRelative.y);
        data.add(move[moveID][j].jointRightElbowRelative.z);
        
        data.add(move[moveID][j].jointRightHandRelative.x);
        data.add(move[moveID][j].jointRightHandRelative.y);
        data.add(move[moveID][j].jointRightHandRelative.z);
    }
    String str = Integer.toString(moveID);    
    data.endSave(dataPath("pose" + str + ".data"));
}

void loadData(int moveID) {
    // LOADING
    String str = Integer.toString(moveID);
    data.load(dataPath("pose" + str + ".data"));
    for (int j=1; j < framesGestureMax; j++)
    {
        move[moveID][j].jointLeftShoulderRelative.x = data.readFloat();
        move[moveID][j].jointLeftShoulderRelative.y = data.readFloat();
        move[moveID][j].jointLeftShoulderRelative.z = data.readFloat();
        
        move[moveID][j].jointLeftElbowRelative.x = data.readFloat();
        move[moveID][j].jointLeftElbowRelative.y = data.readFloat();
        move[moveID][j].jointLeftElbowRelative.z = data.readFloat();
        
        move[moveID][j].jointLeftHandRelative.x = data.readFloat();
        move[moveID][j].jointLeftHandRelative.y = data.readFloat();
        move[moveID][j].jointLeftHandRelative.z = data.readFloat();
        
        move[moveID][j].jointRightShoulderRelative.x = data.readFloat();
        move[moveID][j].jointRightShoulderRelative.y = data.readFloat();
        move[moveID][j].jointRightShoulderRelative.z = data.readFloat();
        
        move[moveID][j].jointRightElbowRelative.x = data.readFloat();
        move[moveID][j].jointRightElbowRelative.y = data.readFloat();
        move[moveID][j].jointRightElbowRelative.z = data.readFloat();
        
        move[moveID][j].jointRightHandRelative.x = data.readFloat();
        move[moveID][j].jointRightHandRelative.y = data.readFloat();
        move[moveID][j].jointRightHandRelative.z = data.readFloat();
        
        if (NORMALIZE_SIZE) move[moveID][j] = normalizeSize( move[moveID][j] );
        if (normRotation[moveID]) move[moveID][j] = normalizeRotation( move[moveID][j] );
    } 
}
