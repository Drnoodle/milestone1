











//                                             --------------      PROJECT GAME FOR INTRODUCTION ON VISUAL COMPUTING      --------------


       
       
       
       
                
                //   project's student : 
                
                //                  Omar Boujdaria
                //                  Gustavo Laurie
                //                  Bonnome Hugo
                
                
                
                
                
                
                
                
                //   libraries : 
                
                import java.lang.Math.*;
                import java.util.*;













//__________________________________________________________________________   I./ SETTINGS


  
  

  
        // 1. windows
  
        final int WINDOW_WIDTH  = 800;
        final int WINDOW_HEIGHT = 800;
  



  
        // 2. plate
    
        final int   PLATE_HEIGHT = 12; 
        final int   PLATE_WIDTH  = 500;
        final int   PLATE_DEPTH  = 500; 
        final float DRAG_SENSIBILITY = PI/12;
        final color PLATE_COLOR = color(255,255,255);
  
  
  
  
  
        // 3. ball

        final int   BALL_RADIUS = 20; 
        final color BALL_COLOR = color(255,0,0);
        final float BALL_MASSE = 0.1;
        
        final int SCENE_CENTER_X = WINDOW_WIDTH/2; 
        final int SCENE_CENTER_Y = WINDOW_HEIGHT/2;
        final int SCENE_CENTER_Z = 0; 





        // 4. forces 
        
        final float GRAVITY = 9.81;
        final float BALL_MU = 0.08;
        final float BALL_NORMAL_FORCE = 1;
        final float BALL_FRICTION_MAGNITUDE = BALL_NORMAL_FORCE * BALL_MU; 
        





        // 5. some function(s)
 
        
        float distance(float x1, float y1, float x2, float y2){
        return sqrt( (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)  );
        }
        

        int ramdomBetween(int min, int max){
        return min + (int)(Math.random()*max);
        }
      
      
      
      
      
        // 6. cylinder 
        
        
        final float     CYLINDER_BASE_SIZE = 16;
        final float     CYLINDER_HEIGHT = 400;
        final int       CYLINDER_RESOLUTION = 100;
        final int       CYLINDER_COLOR =  color(255,255,255);      
      
      
      
        
        
        // 8 interfaces
        
        
        interface MyShape {
        public void drawIt();
        }
        
        
        interface MovingConstraint {
        public boolean outOnX(PVector thatPos, float margin);
        public boolean outOnZ(PVector thatPos, float margin);
        public PVector mirroringBounder(PVector thatPos, float margin);
        }
      
      
        interface Observer {
        public void update(Subject subj);
        }
        
        
        interface Subject {
        public void addObs(Observer obs);
        public void callObs();
        }
      
      
      
      


//__________________________________________________________________________   II./ APPLICATION






     // 1. instantiate, cabling and start
     
     
     
      RotationInteract rotationInteract = new RotationInteract(-PI/3, PI/3, -PI/3, PI/3);
      ModeInteract modeInteract = new ModeInteract();
      ActionInteract actionInteract = new ActionInteract();
      Rendering render = new Rendering();
      
      
      
        void setup() { 
        size(WINDOW_WIDTH, WINDOW_HEIGHT, P3D);
        
        actionInteract.addObs(render);
        modeInteract.addObs(render);
        modeInteract.addObs(rotationInteract);
        noStroke();
        }
        
        
        


     // 2. drawing 



        void draw() {  
        background(220, 220, 220, 255);    
        lights();      
        render.drawIt();
        }






//__________________________________________________________________________   III./  BOUND


        public class Bound{
        
        private final float LOWER_BOUND, UPPER_BOUND;
        
        public Bound(float lowerBound, float upperBound){
        this.LOWER_BOUND = lowerBound;
        this.UPPER_BOUND = upperBound;
        }

        public float frame(float value) {
        value = Math.min(value, UPPER_BOUND);  /**  AND  **/  value = Math.max(value, LOWER_BOUND);    /**  THEN  **/    return value;
        }
        
        public float distanceOutOfBound(float value) {
        if(value < LOWER_BOUND) return LOWER_BOUND - value;      else if(value > UPPER_BOUND) return value - UPPER_BOUND;        else return 0.0;
        }  

        public boolean out(float x){    return x < LOWER_BOUND    ||   UPPER_BOUND < x;      }
        
        public float lowerBound()  {    return LOWER_BOUND;      }
        public float upperBound()  {    return UPPER_BOUND;      }
        }



//__________________________________________________________________________   III./  OBSTACLE


      public class InsideSquareConstraint implements MovingConstraint {
      
      private final PVector POSITION;
      private final Bound BOUND_X, BOUND_Z;  
        
      public InsideSquareConstraint(PVector position, Bound boundX, Bound boundZ){
      this.POSITION = position;
      this.BOUND_X = boundX;
      this.BOUND_Z = boundZ;
      }
      
        
      // when thatPos is out of the plate, repositionate thatPos inside the plate at the distance thatPos was out
      public PVector mirroringBounder(PVector thatPos, float margin){
        
      PVector newVect = new PVector();   
      newVect.x = BOUND_X.frame(thatPos.x);   /**  AND  **/      newVect.y = thatPos.y;    /**  AND  **/          newVect.z = BOUND_Z.frame(thatPos.z);
      
      if( thatPos.x - margin < BOUND_X.lowerBound() )          newVect.x +=  BOUND_X.distanceOutOfBound(thatPos.x - margin);
      else if( thatPos.x + margin > BOUND_X.upperBound() )     newVect.x -=  BOUND_X.distanceOutOfBound(thatPos.x + margin); 
      
      if( thatPos.z - margin < BOUND_Z.lowerBound() )          newVect.z +=  BOUND_Z.distanceOutOfBound(thatPos.z - margin);
      else if( thatPos.z + margin > BOUND_Z.upperBound() )     newVect.z -=  BOUND_Z.distanceOutOfBound(thatPos.z - margin);
        
      return newVect;
       
      }

      
      // on range lowerBound/ upperBound of plate ? 
      public boolean outOnX(PVector thatPos, float margin){    return BOUND_X.out(thatPos.x-margin) || BOUND_X.out(thatPos.x+margin);      }
      public boolean outOnZ(PVector thatPos, float margin){    return BOUND_Z.out(thatPos.z-margin) || BOUND_Z.out(thatPos.z+margin);      } 
      
      
      }
      

      public class OutsideCircleConstraint implements MovingConstraint {
        
      private final PVector POSITION;
      private final float DISTANCE_CONSTRAINT;  
        
      public OutsideCircleConstraint(PVector position, float distance){
      this.POSITION = position;
      this.DISTANCE_CONSTRAINT = distance;
      }  
        
      // when thatPos is out of the plate, repositionate thatPos inside the plate at the distance thatPos was out
      public PVector mirroringBounder(PVector thatPos, float margin){
      PVector newVect = new PVector();   
      if(!outOnX(thatPos, margin)) return thatPos;
      else {
      newVect = PVector.sub(POSITION,thatPos);
      newVect.normalize();   /**   AND   **/    newVect.mult(DISTANCE_CONSTRAINT + margin - PVector.dist(thatPos,POSITION));
      return newVect;
      }

      }

      
      //  2 times out : ball will change the two velocity if it's out
      public boolean outOnX(PVector thatPos, float margin){    return PVector.dist(thatPos,POSITION) - margin < DISTANCE_CONSTRAINT;      }
      public boolean outOnZ(PVector thatPos, float margin){    return outOnX(thatPos, margin);       } 
      
      }







//__________________________________________________________________________   III./  PLATE






    // 1. component center on zero
    
    
    
    class Plate implements Observer{
    
      private final MovingConstraint MOVING_CONSTRAINT;
      
      private color colorPlate;
      private final int WIDTH, HEIGHT, DEPTH;
      private Rotation rotation = new Rotation();

      public Plate(int width, int height,  int depth, color v){
      this.WIDTH  = width;
      this.HEIGHT = height; 
      this.DEPTH  =  depth;
      this.colorPlate = v;
      this.MOVING_CONSTRAINT = new InsideSquareConstraint(new PVector(0,0,0), new Bound(-this.WIDTH/2, this.WIDTH/2), new Bound(-DEPTH/2, DEPTH/2) );
      }
      
      public int width()                            {         return this.WIDTH;                  }
      public int height()                           {         return this.HEIGHT;                 }
      public int depth()                            {         return this.DEPTH;                  }     
      public MovingConstraint movingConstraint()    {         return this.MOVING_CONSTRAINT;      }
      
      
      public void update(Subject subj){      if (subj instanceof RotationInteract) rotation = ((RotationInteract)subj).provide();        }
        
      
      void drawIt(){

        pushMatrix(); 

        translate(SCENE_CENTER_X, SCENE_CENTER_Y, SCENE_CENTER_Z);  
        rotateX(rotation.x());     /** AND **/      rotateZ(rotation.z()); 
        fill(colorPlate); 
        box(PLATE_WIDTH, PLATE_HEIGHT, PLATE_DEPTH);

        popMatrix();
        
        }
          
    }
















//__________________________________________________________________________   III./ BALL
         
         
         
         
         
         
      // 1. component
      
      
      
      // todo implements obs qui obs des constaints : table
      class Ball implements Observer{
    
      private final int RADIUS;
      private final color MY_COLOR;
      
      private PVector gravity, velocity, frictionVelocity;
      private PVector positionOnHorizontalPlate;
      private Rotation rotation = new Rotation();
      private Plate plate;
      private Set<MovingConstraint> movingConstraints = new HashSet<MovingConstraint>();
        
      public Ball(int radius, color v){
      this.RADIUS  = radius;
      this.MY_COLOR = v;
      this.plate = plate;
      this.gravity  = new PVector(0,0,0);
      this.velocity = new PVector(0,0,0);
      this.frictionVelocity = new PVector(0,0,0);
      this.positionOnHorizontalPlate = new PVector(0, 0, 0); // ???
      }
      
      
      public void addMovingConstraint(MovingConstraint constraint){      movingConstraints.add(constraint);       }
      
      private void updatePosition(){
          

          // gravity
          gravity.x = sin(rotation.z()) * BALL_MASSE * GRAVITY;    /**  AND  **/     gravity.z = -sin(rotation.x()) * BALL_MASSE * GRAVITY; 
          
                    // velocity
          boolean changeXVelocity = false, changeZVelocity = false; 
          for( MovingConstraint constraint : movingConstraints) {
          if(constraint.outOnX(positionOnHorizontalPlate, /** with margin : **/  RADIUS )) changeXVelocity = true;
          if(constraint.outOnZ(positionOnHorizontalPlate, /** with margin : **/  RADIUS )) changeZVelocity = true;
          }
          
          if(changeXVelocity) velocity.x = -velocity.x;      /**  AND  **/     if( changeZVelocity) velocity.z = -velocity.z;     
          System.out.println(velocity.z);
          velocity.add(gravity); 
          frictionVelocity = PVector.mult(velocity, -1);   /**  AND  **/  frictionVelocity.normalize();  /**  THEN  **/  frictionVelocity.mult(-BALL_FRICTION_MAGNITUDE);

          
          
         positionOnHorizontalPlate.add(velocity);
         for( MovingConstraint constraint : movingConstraints)  positionOnHorizontalPlate = constraint.mirroringBounder(positionOnHorizontalPlate, /** with margin : **/  RADIUS);
         
        }
      
      
      public void update(Subject subj){     if(subj instanceof RotationInteract) rotation = ((RotationInteract)subj).provide();            } 
     
       
      public void drawIt(){
        System.out.println(positionOnHorizontalPlate.x);
        pushMatrix(); 
        updatePosition();
        translate(SCENE_CENTER_X , SCENE_CENTER_Y - BALL_RADIUS , SCENE_CENTER_Z);     
        rotateX(rotation.x());     /**  AND  **/    rotateZ(rotation.z());
        translate(positionOnHorizontalPlate.x, positionOnHorizontalPlate.y, positionOnHorizontalPlate.z);    
        
        fill(MY_COLOR); 
        sphere(RADIUS);
        
        popMatrix(); 
        }
        
    
    
     }
    
    
    
    

         





//__________________________________________________________________________   IV./ CYLINDER






      public class MyCylinderShape {
      
      private final float CYLINDER_BASE_SIZE, CYLINDER_HEIGHT;
      private final int CYLINDER_RESOLUTION; 
      private final float[] x, z;
      private final color MY_COLOR;
      
      public MyCylinderShape(float cylinderBaseSize, float cylinderHeight, int cylinderResolution, color v)
      {

        this.CYLINDER_HEIGHT     = cylinderHeight;
        this.CYLINDER_BASE_SIZE  = cylinderBaseSize;
        this.CYLINDER_RESOLUTION = cylinderResolution;
        this.MY_COLOR = v;
        
        this.x = new float[cylinderResolution +1];
        this.z = new float[cylinderResolution + 1];

       // circle positions
       float angle;
       for(int i = 0; i< x.length; i++){
         angle = (TWO_PI/cylinderResolution)*i;     /**  AND  **/      x[i] = sin(angle)*cylinderBaseSize;     /**  AND  **/     z[i] = cos(angle)*cylinderBaseSize;
        }
        
      }
      
      public float cylinderBaseSize()     {       return CYLINDER_BASE_SIZE;      }
      public float cylinderHeight()       {       return CYLINDER_HEIGHT;         }
      public int cylinderResolution()     {       return CYLINDER_RESOLUTION;     }
      public color myColor()              {       return MY_COLOR;                }
      
      public void drawIt(){
        
      fill(this.MY_COLOR);
       
      pushMatrix(); 
      rotateX(HALF_PI);
      
      beginShape(QUAD_STRIP);  // Pq marche pas avec Line ? Comment definir une forme constr. ?
      for(int i = 0; i < x.length; i++){   vertex( x[i], z[i], 0 );   /** AND **/  vertex( x[i], z[i], CYLINDER_HEIGHT ); /** 2/4 vertex of a quad **/    }
      endShape(); 
       
       
      beginShape(TRIANGLES);
      for(int i = 0; i < x.length-1; i++){  
      vertex( 0, 0, 0 );                /** AND **/   vertex( x[i], z[i], 0);                     /** AND **/    vertex( x[i+1], z[i+1], 0);
      vertex( 0, 0, CYLINDER_HEIGHT );  /** AND **/     vertex( x[i], z[i],  CYLINDER_HEIGHT);    /** AND **/    vertex( x[i+1], z[i+1],  CYLINDER_HEIGHT); 
      }
      endShape(); 
       
      popMatrix();      
      
      }
      
      }
      
      
      
      
      
      
      public class Cylinder implements Observer {
      
      private final MovingConstraint MOVING_CONSTRAINT;
      private final MyCylinderShape MY_SHAPE; 
      private final PVector POSITION; 
      private Rotation rotation = new Rotation();
      
      
      public Cylinder(MyCylinderShape shape, PVector position )
      {
        this.MY_SHAPE  = shape;
        this.POSITION = position.get();
        this.MOVING_CONSTRAINT = new OutsideCircleConstraint( this.POSITION, this.MY_SHAPE.cylinderBaseSize() );
      }
      

      
      public MovingConstraint movingConstraint(){   return MOVING_CONSTRAINT;     }
      
      public void update(Subject subj){    if(subj instanceof RotationInteract) rotation = ((RotationInteract)subj).provide();        } 
      
      public void drawIt(){
      pushMatrix();
      translate(SCENE_CENTER_X, SCENE_CENTER_Y, SCENE_CENTER_Z);
      rotateX(rotation.x());          /**  AND  **/       rotateZ(rotation.z());
      translate(POSITION.x, 0, POSITION.z);
      MY_SHAPE.drawIt();
      popMatrix();
      }
      

      }




      public class CylinderBuilder implements Observer{
      
      
      private final MyCylinderShape MY_SHAPE; 
      private PVector position = new PVector(); 
      private Rotation rotation = new Rotation();
      private Set<MovingConstraint> movingConstraint  =  new HashSet<MovingConstraint>();
      
      public CylinderBuilder(float cylinderBaseSize, float cylinderHeight, int cylinderResolution, color v)
      {
        this.MY_SHAPE = new MyCylinderShape(cylinderBaseSize, cylinderHeight, cylinderResolution, v);
      }
      
      
      public void addMovingConstraint(MovingConstraint constraint){    movingConstraint.add(constraint);    }
      
      public void update(Subject subj){     if(subj instanceof RotationInteract) rotation = ((RotationInteract)subj).provide();         } 
      
      public Cylinder build()         {     return new Cylinder(MY_SHAPE, position);      }
      
      
      public void drawIt(){
      this.position.x = mouseX - SCENE_CENTER_X;       /** AND **/     this.position.z = mouseY - SCENE_CENTER_Y; 
      pushMatrix();
      translate(SCENE_CENTER_X, SCENE_CENTER_Y, SCENE_CENTER_Z);
      rotateX(rotation.x());     /** AND **/     rotateZ(rotation.z());
      translate(position.x, 0, position.z);
      MY_SHAPE.drawIt();
      popMatrix();
      }
      
      }
      
      
      
      
      
      
      
      


//__________________________________________________________________________   VI./ RENDERING

      
      
      
      
      
      
      public class Rendering implements Observer{
           
         private Plate plate = new Plate(PLATE_WIDTH, PLATE_HEIGHT, PLATE_DEPTH, PLATE_COLOR);
         private Ball ball  = new Ball(BALL_RADIUS, BALL_COLOR);
         private CylinderBuilder cylinderBuilder = new CylinderBuilder(CYLINDER_BASE_SIZE, CYLINDER_HEIGHT, CYLINDER_RESOLUTION, CYLINDER_COLOR);
         private Set<Cylinder> cylinders = new HashSet<Cylinder>();
         private Mode mode = new Mode();
         
         public Rendering(){
          rotationInteract.addObs(plate);
          rotationInteract.addObs(ball);
          rotationInteract.addObs(cylinderBuilder);
          ball.addMovingConstraint(plate.movingConstraint());
          cylinderBuilder.addMovingConstraint(plate.movingConstraint());
          for(Cylinder cylinder : cylinders) rotationInteract.addObs(cylinder);
         }
         
         
         public void drawIt(){
             plate.drawIt();
             for(Cylinder cylinder : cylinders) cylinder.drawIt();
             if(mode.onPlayView())  ball.drawIt();
             if(mode.onBuildView()) cylinderBuilder.drawIt();
         }
         
         
         public void update(Subject subj){
          
          if(subj instanceof ModeInteract) this.mode = ((ModeInteract)subj).provide();
          
          if(subj instanceof ActionInteract && ((ActionInteract)subj).wantBuildNewCylinder() && mode.onBuildView()) {
            ((ActionInteract)subj).setBuildCylinderToFalse();
            
             Cylinder newCylinder = cylinderBuilder.build();
             ball.addMovingConstraint(newCylinder.movingConstraint());
             rotationInteract.addObs(newCylinder);     /** AND **/    newCylinder.update(rotationInteract);    /** THEN **/     cylinders.add(newCylinder);
          }
          

          }
      
      }









//__________________________________________________________________________   VII./ USER INTERACTION






     
     public class Rotation{
       private final float ROT_X, ROT_Z;
       
       public Rotation()                {      this.ROT_X = 0;           this.ROT_Z = 0;       }
       public Rotation(float x, float z){      this.ROT_X = x;           this.ROT_Z = z;       }
       
       public float x() { return ROT_X; }
       public float z() { return ROT_Z; }
     }
     
     
     
       
     public class RotationInteract implements Subject, Observer {
       private Set<Observer> observers = new HashSet<Observer>();
       
       private float rotX = 0, rotZ = 0;
       private Mode mode = new Mode();
       private final float BUILDING_ROT_X = -PI/3, BUILDING_ROT_Z =  -PI/7;
       private final Bound BOUND_X, BOUND_Z;
       
       public RotationInteract( float lowerBoundX, float upperBoundX, float lowerBoundZ, float upperBoundZ ){
       this.BOUND_X = new Bound(lowerBoundX, upperBoundX);
       this.BOUND_Z = new Bound(lowerBoundZ, upperBoundZ);
       }
       
       private float x() {  /** **/   if(mode.onPlayView())  return rotX;       else if(mode.onBuildView())  return BUILDING_ROT_X;       else   return 0.0;     /** **/    }
       private float z() {  /** **/   if(mode.onPlayView())  return rotZ;       else if(mode.onBuildView())  return BUILDING_ROT_Z;       else   return 0.0;     /** **/    }
         
       
       public void incrementeFromEvent(float dx, float dz){
       rotX = BOUND_X.frame(rotX + dx);   /**  AND  **/    rotZ = BOUND_Z.frame(rotZ + dz);   /**  THEN  **/     callObs();  
       }
       
       public void addObs(Observer obs){         observers.add(obs);                                         }
       public void callObs()           {         for(Observer obs : observers) obs.update(this);             } 
       
       public Rotation provide(){return new Rotation(x(), z());}
       public void update(Subject subj){ if(subj instanceof ModeInteract) this.mode = ((ModeInteract)subj).provide();      callObs();      }
       
       }
      
      
      
      
      

       public class Mode{
       private final boolean PLAYING_MODE, BUILDING_MODE;
       
       public Mode()                                 {       this.PLAYING_MODE = true;            this.BUILDING_MODE = false;           }
       public Mode(boolean playing, boolean building){       this.PLAYING_MODE = playing;         this.BUILDING_MODE = building;        } 
       
       public boolean onPlayView(){  return PLAYING_MODE;  }
       public boolean onBuildView(){ return BUILDING_MODE; }
       }
      
      
      
      
      
       public class ModeInteract implements Subject {
         
       private Set<Observer> observers = new HashSet<Observer>();
       private boolean playingView = true, buildingView = false;
       
       public void setBuildView(){     playingView = false;    /**  AND  **/    buildingView = true;    /**  THEN  **/    callObs();             }  
       public void setPlayView() {     playingView = true;     /**  AND  **/    buildingView = false;   /**  THEN  **/    callObs();             }
       
       
       public void addObs(Observer obs){     observers.add(obs);                                     }
       public void callObs()           {     for(Observer obs : observers) obs.update(this);         } 
       
       public Mode provide(){    return new Mode(playingView, buildingView);    }
       
      }
      



      
       public class ActionInteract implements Subject {
         
         private Set<Observer> observers = new HashSet<Observer>();
         private boolean buildCylinder = false;
         
         public void setToBuildCylinder()      {     buildCylinder = true;      /**  AND  **/       callObs();         }
         public void setBuildCylinderToFalse() {     buildCylinder = false;     /**  AND  **/       callObs();         }
         
         public void addObs(Observer obs){       observers.add(obs);                                     }
         public void callObs()           {       for(Observer obs : observers) obs.update(this);         } 
         
         public boolean wantBuildNewCylinder(){       return buildCylinder;       }
               
       }
       
       
       
      
      
      
      public void mousePressed() {         actionInteract.setToBuildCylinder();      }
       
      public void keyPressed()   {        if(key == CODED && keyCode == SHIFT)      modeInteract.setBuildView();        }
      
      public void keyReleased()  {        if(key == CODED && keyCode == SHIFT)      modeInteract.setPlayView();         }
      
      public void mouseDragged(){ 
            // when grabing on Y axis, we want to move AROUND X axis
            float deltaX =   map(mouseY, 0, height, DRAG_SENSIBILITY, -DRAG_SENSIBILITY) - map(pmouseY, 0, height, DRAG_SENSIBILITY, -DRAG_SENSIBILITY) ; 
            float deltaZ = map(mouseX, 0, width, -DRAG_SENSIBILITY, DRAG_SENSIBILITY) - map(pmouseX, 0, width, -DRAG_SENSIBILITY, DRAG_SENSIBILITY) ;
            rotationInteract.incrementeFromEvent(deltaX, deltaZ); 
      }
          
               
//--

  

