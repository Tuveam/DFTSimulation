class Bounds{
    private PVector m_pos;
    private PVector m_len;

//_________________Constructors_________________________________________________
    Bounds(float xPos, float yPos, float xLen, float yLen){
        construct(xPos, yPos, xLen, yLen);
    }

    Bounds(PVector pos, PVector len){
        construct(pos.x, pos.y, len.x, len.y);
    }

    Bounds(Bounds in){
        construct(in.getXPos(), in.getYPos(), in.getXLen(), in.getYLen());
    }

    private void construct(float xPos, float yPos, float xLen, float yLen){
        m_pos = new PVector(xPos, yPos);
        m_len = new PVector(xLen, yLen);
    }

//_________________getterFunctions______________________________________________
    public float getXPos(){ return m_pos.x; }

    public float getYPos(){ return m_pos.y; }

    public PVector getPos(){ return m_pos; }

    public float getXLen(){ return m_len.x; }

    public float getYLen(){ return m_len.y; }

    public PVector getLen(){ return m_len; }

//_________________Hitbox_______________________________________________________

    public boolean checkHitbox(float x, float y){
        return (
            x < m_pos.x + m_len.x &&
            x > m_pos.x &&
            y < m_pos.y + m_len.y &&
            y > m_pos.y
        );
    }

    public int checkHitboxXPartition(float x, int xPartitions){
        return constrain(floor(xPartitions * (x - m_pos.x)/m_len.x), 0, xPartitions - 1);
    }

    public int checkHitboxYPartition(float y, int yPartitions){
        return constrain(floor(yPartitions * (y - m_pos.y)/m_len.y), 0, yPartitions - 1);
    }
    
//_________________withPosAndLen________________________________________________ 
    public Bounds withPosAndLen(float xPos, float yPos, float xLen, float yLen){
        return new Bounds(xPos, yPos, xLen, yLen);
    }
    
    public Bounds withPosAndLen(PVector newPos, PVector newLen){
        return withPosAndLen(newPos.x, newPos.y, newLen.x, newLen.y);
    }

//_________________withPos______________________________________________________ 
    public Bounds withPos(float xPos, float yPos){
        return withPosAndLen(xPos, yPos, m_len.x, m_len.y);
    }

    public Bounds withPos(PVector newPos){
        return withPos(newPos.x, newPos.y);
    }

    public Bounds withXPos(float xPos){
        return withPos(xPos, m_pos.y);
    }

    public Bounds withYPos(float yPos){
        return withPos(m_pos.x, yPos);
    }

//_________________withLen______________________________________________________ 
    public Bounds withLen(float xLen, float yLen){
        return withPosAndLen(m_pos.x, m_pos.y, xLen, yLen);
    }

    public Bounds withLen(PVector newLen){
        return withLen(newLen.x, newLen.y);
    }

    public Bounds withXLen(float xLen){
        return withLen(xLen, m_len.y);
    }

    public Bounds withYLen(float yLen){
        return withLen(m_len.x, yLen);
    }

//_________________without_side_________________________________________________ 
    public Bounds withoutLeft(float remove){
        return withPosAndLen(m_pos.x + remove, m_pos.y, m_len.x - remove, m_len.y);
    }

    public Bounds withoutLeftRatio(float removeRatio){
        return withoutLeft(m_len.x * removeRatio);
    }

    public Bounds withoutRight(float remove){
        return withPosAndLen(m_pos.x, m_pos.y, m_len.x - remove, m_len.y);
    }

    public Bounds withoutRightRatio(float removeRatio){
        return withoutRight(m_len.x * removeRatio);
    }

    public Bounds withoutTop(float remove){
        return withPosAndLen(m_pos.x, m_pos.y + remove, m_len.x, m_len.y - remove);
    }

    public Bounds withoutTopRatio(float removeRatio){
        return withoutTop(m_len.y * removeRatio);
    }

    public Bounds withoutBottom(float remove){
        return withPosAndLen(m_pos.x, m_pos.y, m_len.x, m_len.y - remove);
    }

    public Bounds withoutBottomRatio(float removeRatio){
        return withoutBottom(m_len.y * removeRatio);
    }

//_________________framing______________________________________________________ 
    public Bounds withFrame(float frameThickness){
        return withPosAndLen(m_pos.x + frameThickness,
                            m_pos.y + frameThickness,
                            m_len.x - 2 * frameThickness,
                            m_len.y - 2 * frameThickness);
    }

    public Bounds withFrameRatio(float frameRatio){
        float frameThickness = (m_len.x < m_len.y)? (m_len.x * frameRatio) : (m_len.y * frameRatio) ;
        return withFrame(frameThickness);
    }

    public Bounds withXFrame(float frameThickness){
        return withPosAndLen(m_pos.x + frameThickness,
                            m_pos.y,
                            m_len.x - 2 * frameThickness,
                            m_len.y);
    }

    public Bounds withXFrameRatio(float frameRatio){
        return withXFrame(m_len.x * frameRatio);
    }

    public Bounds withYFrame(float frameThickness){
        return withPosAndLen(m_pos.x,
                            m_pos.y + frameThickness,
                            m_len.x,
                            m_len.y - 2 * frameThickness);
    }

    public Bounds withYFrameRatio(float frameRatio){
        return withYFrame(m_len.y * frameRatio);
    }

//_________________Squares______________________________________________________

    public Bounds withCenteredSquare(){
        float side = (m_len.x < m_len.y)? m_len.x : m_len.y;

        return withPosAndLen(m_pos.x + m_len.x/2 - side/2,
                            m_pos.y + m_len.y/2 - side/2,
                            side,
                            side);
    }

    public Bounds withLeftSquare(){
        float side = (m_len.x < m_len.y)? m_len.x : m_len.y;

        return withPosAndLen(m_pos.x,
                            m_pos.y + m_len.y/2 - side/2,
                            side,
                            side);
    }

//_________________Sections_____________________________________________________

    public Bounds fromToSectionOfXDivisions(int fromSection, int toSection, int divisions){
        //toSection is exclusive!!
        return withoutLeftRatio((1.0f * fromSection) / divisions).withoutRightRatio(1 - ( 1.0f * (toSection - fromSection) ) / (divisions-fromSection));
    }

    public Bounds asSectionOfXDivisions(int section, int divisions){
        return fromToSectionOfXDivisions(section, section + 1, divisions);
    }

    public Bounds fromToSectionOfYDivisions(int fromSection, int toSection, int divisions){
        //toSection is exclusive!!
        return withoutTopRatio((1.0f * fromSection) / divisions).withoutBottomRatio(1 - ( 1.0f * (toSection - fromSection) ) / (divisions-fromSection));
    }

    public Bounds asSectionOfYDivisions(int section, int divisions){
        return fromToSectionOfYDivisions(section, section + 1, divisions);
    }

    

}

//_________________Translate____________________________________________________
    void translate(Bounds b){
        translate(b.getXPos(), b.getYPos());
    }
//_________________Vertex_______________________________________________________
    void vertex(PVector v){
        vertex(v.x, v.y);
    }
//_________________Rectangle____________________________________________________
    void rect(Bounds b, float tl, float tr, float br, float bl){
        rectMode(CORNER);
        rect(b.getXPos(), b.getYPos(), b.getXLen(), b.getYLen(), tl, tr, br, bl);
    }

    void rect(Bounds b, float rounding){
        rect(b, rounding, rounding, rounding, rounding);
    }

    void rect(Bounds b){
        rect(b, 0);
    }

//_________________Ellipse______________________________________________________

    void ellipse(Bounds b){
        ellipseMode(CENTER);
        ellipse(b.getXPos() + b.getXLen()/2, b.getYPos() + b.getYLen()/2, b.getXLen(), b.getYLen());
    }
        
//_________________Crosses______________________________________________________
    
    void cross(Bounds b){
        cross(b.getXPos() + b.getXLen()/2, b.getYPos() + b.getYLen()/2, b.getXLen(), b.getYLen());
    }
    
    void cross(float xCenter, float yCenter, float xLen, float yLen){
        line(xCenter - xLen/2, yCenter - yLen/2, xCenter + xLen/2, yCenter + yLen/2);
        line(xCenter - xLen/2, yCenter + yLen/2, xCenter + xLen/2, yCenter - yLen/2);
    }

//_________________Arc__________________________________________________________

    void arc(Bounds b, float startAngle, float endAngle, int arcMode){
        ellipseMode(CENTER);
        arc(b.getXPos() + b.getXLen()/2,
            b.getYPos() + b.getYLen()/2,
            b.getXLen(),
            b.getYLen(),
            startAngle,
            endAngle,
            arcMode);
    }

//_________________Text_________________________________________________________
    void text(String text, Bounds b, int textAlign){
        textAlign(textAlign);
        float textSize = b.getYLen();
        textSize(textSize);

        float yPos = b.getYPos() + 4 * textSize/5;
        switch(textAlign){
            case LEFT:
            text(text, b.getXPos(), yPos);
            break;
            case RIGHT:
            text(text, b.getXPos() + b.getXLen(), yPos);
            break;
            case CENTER:
            text(text, b.getXPos() + b.getXLen()/2, yPos);
            break;
        }

        //noFill();
        //stroke(255);
        //strokeWeight(1);
        //rect(b);
        
    }
