class Controller{
    //private float/boolean m_value = 0;
    
    protected PVector m_pos;
    protected PVector m_len;

    protected boolean m_selected = false;
    protected boolean m_firstClick = true;

    protected PVector m_mouseClicked;

    protected color m_fillColor;

    Controller(PVector pos, PVector len){
        m_pos = pos;
        m_len = len;

        m_fillColor = color(75, 200, 75);
        
        m_mouseClicked = new PVector(mouseX, mouseY);
    }

    public void update(){
        click();
        adjust();
        draw();
    }

    protected void click(){
        /*if(mousePressed && m_firstClick){
            m_firstClick = false;
            if( mouseX >= m_pos.x && 
                mouseX <= m_pos.x + m_len.x && 
                mouseY >= m_pos.y && 
                mouseY <= m_pos.y + m_len.y){

                m_mouseClickedX = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;
            }
        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }*/
        
    }

    protected void adjust(){
        //to be inherited and overloaded
    }

    protected void draw(){
        //to be inherited and overloaded
    }

    //public float getValue(){
        //to be inherited and overloaded
    //}

}

//====================================================================

class Knob extends Controller{

    private float m_value;
    private float m_previousValue;

    private float m_minRealValue = 0;
    private float m_maxRealValue = 1;

    private float m_sensitivity = 0.25;

    private color m_capColor;
    private color m_barColor;
    

    Knob(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector((xLen < yLen)? xLen : yLen, (xLen < yLen)? xLen : yLen));
        m_value = 0.8;
        m_capColor = color(50, 50, 50);
        m_barColor = color(100, 100, 100);
        
    }

    protected void click(){
        if(mousePressed && m_firstClick){
            m_firstClick = false;
            if( mouseX >= m_pos.x && 
                mouseX <= m_pos.x + m_len.x && 
                mouseY >= m_pos.y && 
                mouseY <= m_pos.y + m_len.y){

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;
                m_previousValue = m_value;
            }
        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
    }

    protected void adjust(){
        if(m_selected){
            m_value = m_previousValue + m_sensitivity * (m_mouseClicked.y - mouseY) / m_len.y;

            

            if(m_value < 0){
                m_value = 0;
            }

            if(m_value > 1){
                m_value = 1;
            }

            //println(m_value);
        }
    }

    protected void draw(){
        colorMode(RGB, 255, 255, 255);

        pushMatrix();
        translate(m_pos.x + m_len.x / 2, m_pos.y + m_len.y / 2);

        //Bar
        noStroke();
        fill(m_barColor);
        arc(0, 0, m_len.x, m_len.y, PI * 3 / 4, PI * 9 / 4, PIE);

        //Fill
        float angle = map(m_value, 0, 1, PI * 3 / 4, PI * 9 / 4);
        noStroke();
        fill(m_fillColor);
        arc(0, 0, m_len.x, m_len.y, PI * 3 / 4, angle, PIE);

        
        //Cap
        noStroke();
        fill(m_capColor);
        ellipse(0, 0, 0.8 * m_len.x, 0.8 * m_len.y);

        //indicator line
        stroke(m_fillColor);
        strokeWeight(3);
        line(0.1 * m_len.x * cos(angle), 0.1 * m_len.y * sin(angle), 0.3 * m_len.x * cos(angle), 0.3 * m_len.y * sin(angle));

        popMatrix();
    }

    public float getValue(){
        return m_value;
    }

    public float getRealValue(){
        return map(m_value, 0, 1, m_minRealValue, m_maxRealValue);
    }

    public void setColor(color capColor, color barColor, color fillColor){
        m_capColor = capColor;
        m_barColor = barColor;
        m_fillColor = fillColor;
    }

    public void setRealValueRange(float minRealValue, float maxRealValue){
        m_minRealValue = minRealValue;
        m_maxRealValue = maxRealValue;
    }
}

//====================================================================

class Tickbox extends Controller{

    protected boolean m_value;

    protected boolean m_pressed = false;

    protected color m_backgroundColor1;
    protected color m_backgroundColor2;


    Tickbox(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_backgroundColor1 = color(100, 100, 100);
        m_backgroundColor2 = color(50, 50, 50);

        m_value = true;
    }

    protected void click(){
        if(mousePressed && m_firstClick){
            m_firstClick = false;
            if( mouseX >= m_pos.x && 
                mouseX <= m_pos.x + m_len.x && 
                mouseY >= m_pos.y && 
                mouseY <= m_pos.y + m_len.y){

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;
            }
        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
        
    }

    protected void adjust(){
        if(m_selected){
            m_pressed = true;
        }

        if(!m_selected && m_pressed){
            m_value = !m_value;
            m_pressed = false;
        }
    }

    protected void draw(){
        pushMatrix();
        translate(m_pos.x, m_pos.y);

        float rounding = ((m_len.x < m_len.y)? m_len.x : m_len.y)/4;

        //Background
        noStroke();
        fill(m_backgroundColor2);
        rect(0, 0, m_len.x, m_len.y, rounding);
        float indent = 0.1;

        drawTick(indent, rounding);

        popMatrix();
    }

    protected void drawTick(float indent, float rounding){
        //Tick
        if(m_value){
            noStroke();
            fill(m_fillColor);
        }else{
            noStroke();
            fill(m_backgroundColor1);
        }

        rect(m_len.x * indent, m_len.y * indent, m_len.x * (1 - 2 * indent), m_len.y * (1 - 2 * indent), rounding);

        //Highlight
        if(m_pressed){
            noStroke();
            fill(255, 100);
            rect(m_len.x * indent, m_len.y * indent, m_len.x * (1 - 2 * indent), m_len.y * (1 - 2 * indent), rounding);
        }
    }


    public boolean getValue(){
        return m_value;
    }

    public void setColor(color backgroundColor1, color backgroundColor2, color fillColor){
        m_backgroundColor1 = backgroundColor1;
        m_backgroundColor2 = backgroundColor2;
        m_fillColor = fillColor;
    }
}

class Button extends Tickbox{
    protected int m_cooldown = 20;
    protected int m_tickCooldown = m_cooldown;

    Button(float xPos, float yPos, float xLen, float yLen){
        super(xPos, yPos, xLen, yLen);
    }

    protected void adjust(){
        if(m_selected){
            m_pressed = true;
        }

        if(!m_selected && m_pressed){
            m_value = true;
            m_pressed = false;
            m_tickCooldown = 0;
        }

        if(!m_pressed && !m_selected && m_value){
            m_value = false;
        }

        if(m_tickCooldown < m_cooldown){
            m_tickCooldown++;
        }

        if(m_tickCooldown > m_cooldown){
            m_tickCooldown = m_cooldown;
        }
    }

    protected void drawTick(float indent, float rounding){
        noStroke();
        fill(m_backgroundColor1);
        rect(m_len.x * indent, m_len.y * indent, m_len.x * (1 - 2 * indent), m_len.y * (1 - 2 * indent), rounding);

        fill(m_fillColor, map(m_tickCooldown, 0, 20, 255, 0));
        rect(m_len.x * indent, m_len.y * indent, m_len.x * (1 - 2 * indent), m_len.y * (1 - 2 * indent), rounding);

        fill(m_backgroundColor2);
        rect(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y * 3 * indent, m_len.x * 2 * (1 - 6 * indent)/5, m_len.y * (1 - 6 * indent));
        beginShape();
            vertex(m_len.x * 3 * indent, m_len.y * 3 * indent);
            vertex(m_len.x * 3 * indent, m_len.y - m_len.y * 3 * indent);
            vertex(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y/2);
        endShape();

        if(m_pressed){
            fill(255,100);
            rect(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y * 3 * indent, m_len.x * 2 * (1 - 6 * indent)/5, m_len.y * (1 - 6 * indent));
            beginShape();
            vertex(m_len.x * 3 * indent, m_len.y * 3 * indent);
            vertex(m_len.x * 3 * indent, m_len.y - m_len.y * 3 * indent);
            vertex(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y/2);
            endShape();
        }
    }
}

class PlayButton extends Tickbox{

    PlayButton(float xPos, float yPos, float xLen, float yLen){
        super(xPos, yPos, xLen, yLen);
    }

    protected void drawTick(float indent, float rounding){
        //Tick
        if(m_value){
            noStroke();
            fill(m_fillColor);
        }else{
            noStroke();
            fill(m_backgroundColor1);
        }

        rect(m_len.x * indent, m_len.y * indent, m_len.x * (1 - 2 * indent), m_len.y * (1 - 2 * indent), rounding);

        if(m_value){//PAUSE
            noStroke();
            fill(m_backgroundColor2);
            rect(m_len.x * 3 * indent, m_len.y * 3 * indent, m_len.x * 2 * (1 - 6 * indent)/5, m_len.y * (1 - 6 * indent));
            rect(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y * 3 * indent, m_len.x * 2 * (1 - 6 * indent)/5, m_len.y * (1 - 6 * indent));

            if(m_pressed){
                fill(255, 100);
                rect(m_len.x * 3 * indent, m_len.y * 3 * indent, m_len.x * 2 * (1 - 6 * indent)/5, m_len.y * (1 - 6 * indent));
                rect(m_len.x - m_len.x * (3 * indent + 2 * (1 - 6 * indent)/5), m_len.y * 3 * indent, m_len.x * 2 * (1 - 6 * indent)/5, m_len.y * (1 - 6 * indent));
            }
        }else{//PLAY
            noStroke();
            fill(m_fillColor);

            beginShape();
            vertex(m_len.x * 3 * indent, m_len.y * 3 * indent);
            vertex(m_len.x * 3 * indent, m_len.y - m_len.y * 3 * indent);
            vertex(m_len.x - m_len.x * 3 * indent, m_len.y/2);
            endShape();

            if(m_pressed){
                fill(255,100);
                beginShape();
                vertex(m_len.x * 3 * indent, m_len.y * 3 * indent);
                vertex(m_len.x * 3 * indent, m_len.y - m_len.y * 3 * indent);
                vertex(m_len.x - m_len.x * 3 * indent, m_len.y/2);
                endShape();
            }
        }
    }
}

//====================================================================

class Automation extends Controller{

    ArrayList<AutomationPoint> m_point = new ArrayList<AutomationPoint>();

    private color m_backgroundColor1;
    private color m_backgroundColor2;

    Automation(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_backgroundColor1 = color(100, 100, 100);
        m_backgroundColor2 = color(50, 50, 50);

        m_point.add( new AutomationPoint(m_pos, m_len, new PVector(0, 0)) );
        m_point.add( new AutomationPoint(m_pos, m_len, new PVector(1, 1)) );
    }

    private void insertPointAtIndex(AutomationPoint insert, ArrayList<AutomationPoint> toSort, int index){
        toSort.add(new AutomationPoint( new PVector(0, 0), new PVector(0, 0), new PVector(0, 0)));

        for(int i = toSort.size() - 2; i >= index; i--){
            toSort.set(i + 1, toSort.get(i));
        }

        toSort.set(index, insert);
    }

    protected void click(){
        if(mousePressed && m_firstClick && mouseButton == RIGHT){
            m_firstClick = false;

            boolean createPoint = true;

            for(int i = 0; i < m_point.size() && createPoint; i++){
                if(m_point.get(i).checkHitbox()){
                    createPoint  = false;
                    m_point.remove(i);
                }

                if(m_point.get(i).checkCurveHandleHitbox(m_point, i)){
                    createPoint  = false;
                    m_point.get(i).resetCurve();
                }
            }

            if(createPoint){
                if( mouseX >= m_pos.x && 
                    mouseX <= m_pos.x + m_len.x && 
                    mouseY >= m_pos.y && 
                    mouseY <= m_pos.y + m_len.y){

                    m_mouseClicked.x = mouseX;
                    m_mouseClicked.y = mouseY;

                    m_selected = true;

                    int index = m_point.size()-1;

                    for(int i = m_point.size()-2; i >= 0; i--){
                        if(m_point.get(i).getActualPosition().x < mouseX){
                            break;
                        }
                        index = i;
                    }

                    PVector temp = new PVector( (mouseX - m_pos.x) / m_len.x, 1 - (mouseY - m_pos.y) / m_len.y);

                    insertPointAtIndex(new AutomationPoint(m_pos, m_len, temp), m_point, index);

                }
            }
        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
        
    }

    public void draw(){
        pushMatrix();
        translate(m_pos.x, m_pos.y);

        //background
        fill(m_backgroundColor2);
        stroke(m_backgroundColor1);
        strokeWeight(2);
        rect(0, 0, m_len.x, m_len.y);

        popMatrix();

        //points
        for(int i = 0; i < m_point.size(); i++){
            m_point.get(i).update(m_point, i);
        }

    }

    public void setColor(color backgroundColor1, color backgroundColor2, color fillColor){
        m_backgroundColor1 = backgroundColor1;
        m_backgroundColor2 = backgroundColor2;
        m_fillColor = fillColor;
    }

    public float mapXToY(float x){
        if(x < 0){
            return m_point.get(0).getValue().y;
        }

        int index = 0;

        for(int i = 0; i < m_point.size(); i++){
            if(x <= m_point.get(i).getValue().x){
                return m_point.get(index).mapXToY(x, m_point, index);
            }

            index = i;
        }

        return m_point.get(m_point.size() - 1).getValue().y;
    }

}

class AutomationPoint extends Controller{

    private PVector m_value;

    private float m_curve;
    private float m_previousCurve;
    private int m_displayIncrement = 10;
    private boolean m_selectedCurveHandle = false;
    private float m_curveHandleSensitivity = 1;

    private float m_radius = 6;

    AutomationPoint(PVector windowPos, PVector windowLen, PVector value){
        super(windowPos, windowLen);

        m_value = value;
        m_curve = 0.5;
        m_previousCurve = m_curve;
    }

    public PVector getActualPosition(){
        return new PVector(m_pos.x + m_value.x * m_len.x, m_pos.y + (1 - m_value.y) * m_len.y);
    }

    private void setActualPosition(float x, float y){
        m_value.x = (x - m_pos.x) / m_len.x;
        m_value.y = 1 - (y - m_pos.y) / m_len.y;
    }

    public void update(ArrayList<AutomationPoint> others, int myIndex){
        click(others, myIndex);
        adjust(others, myIndex);
        draw(others, myIndex);
    }

    protected void click(ArrayList<AutomationPoint> others, int myIndex){
        if(mousePressed && m_firstClick){
            m_firstClick = false;
            if(checkHitbox()){

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;

                
            }else if(checkCurveHandleHitbox(others, myIndex)){
                
                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selectedCurveHandle = true;
                m_previousCurve = m_curve;

            }
        }
        
        if(!mousePressed){
            m_selected = false;
            m_selectedCurveHandle = false;
            m_firstClick = true;
            
        }
        
    }

    public PVector getValue(){
        return m_value;
    }

    protected void adjust(ArrayList<AutomationPoint> others, int myIndex){
        
        if(m_selected){
            
            setActualPosition(mouseX, mouseY);

            if(myIndex == 0){
                m_value.x = 0;
            }else if(myIndex == others.size() - 1){
                m_value.x = 1;
            }else{
                if(m_value.x < others.get(myIndex - 1).getValue().x){
                    m_value.x = others.get(myIndex - 1).getValue().x;
                }

                if(m_value.x > others.get(myIndex + 1).getValue().x){
                    m_value.x = others.get(myIndex + 1).getValue().x;
                }
            }

            if(m_value.y < 0){
                m_value.y = 0;
            }

            if(m_value.y > 1){
                m_value.y = 1;
            }

            //println(m_value);
        }else if(m_selectedCurveHandle){

            //println(m_curveHandleSensitivity * (m_mouseClicked.y - mouseY) / m_len.y);
            if(myIndex < others.size() - 1){
                if(others.get(myIndex + 1).getValue().y > getValue().y){
                    m_curve = m_previousCurve + m_curveHandleSensitivity * (m_mouseClicked.y - mouseY) / m_len.y;
                }else{
                    m_curve = m_previousCurve - m_curveHandleSensitivity * (m_mouseClicked.y - mouseY) / m_len.y;
                }
                if(m_curve < 0){
                    m_curve = 0;
                }
                
                if(m_curve > 1){
                    m_curve = 1;
                }
            }
            
        }
    }

    public void draw(ArrayList<AutomationPoint> others, int myIndex){
        pushMatrix();
        translate(getActualPosition().x, getActualPosition().y);

        //Point
        noFill();
        stroke(m_fillColor);
        strokeWeight(2);
        if(m_selected){
            ellipse(0, 0, 3 * m_radius, 3 * m_radius);
        }else{
            ellipse(0, 0, 2 * m_radius, 2 * m_radius);
        }

        popMatrix();

        //Curve
        if(myIndex < others.size() - 1){
            if(m_curve == 0.5 || getActualPosition().x == others.get(myIndex + 1).getActualPosition().x){
                strokeWeight(2);
                stroke(m_fillColor);
                line(getActualPosition().x, getActualPosition().y, others.get(myIndex + 1).getActualPosition().x, others.get(myIndex + 1).getActualPosition().y);
            }else{
                beginShape();
                for(int i = int(getActualPosition().x); i < others.get(myIndex + 1).getActualPosition().x; i += m_displayIncrement){
                    float x = map(i, getActualPosition().x, others.get(myIndex + 1).getActualPosition().x, 0, 1);
                    float actualY = map(getY(x), 0, 1, getActualPosition().y, others.get(myIndex + 1).getActualPosition().y);

                    vertex(i, actualY);
                }
                vertex(others.get(myIndex + 1).getActualPosition().x, others.get(myIndex + 1).getActualPosition().y);
                endShape();
            }
        }

        //CurveHandle
        
        if(myIndex < others.size() - 1){
            if(!(getActualPosition().x == others.get(myIndex + 1).getActualPosition().x)){
                pushMatrix();

                translate(getCurveHandlePosition(others, myIndex).x, getCurveHandlePosition(others, myIndex).y);

                noFill();
                stroke(m_fillColor);
                strokeWeight(2);

                if(m_selectedCurveHandle){
                    rect(-m_radius, -m_radius, 2 * m_radius, 2 * m_radius);
                }else{
                    rect(-0.5 * m_radius, -0.5 * m_radius, m_radius, m_radius);
                }
                popMatrix();
            }
        }
        
        
        
        
        

    }

    private PVector getCurveHandlePosition(ArrayList<AutomationPoint> others, int myIndex){
        if(myIndex < others.size() - 1){
            float actualX = map(0.5, 0, 1, getActualPosition().x, others.get(myIndex + 1).getActualPosition().x);
            float actualY = map(getY(0.5), 0, 1, getActualPosition().y, others.get(myIndex + 1).getActualPosition().y);

            return new PVector(actualX, actualY);
        }else{
            return new PVector(0, 0);
        }
    }

    private float getY(float x){
        float s = map(m_curve, 0, 1, 0.001, 0.999)/(1-map(m_curve, 0, 1, 0.001, 0.999));
        float y;
        if(s == 1){
            y = x;
        }else{
            y = 1 - 1/((s-2+1/s) * x + 1 - 1/s) + 1/(s-1);
        }
        
        return y;
    }

    public float mapXToY(float windowX, ArrayList<AutomationPoint> others, int myIndex){
        if(windowX == m_value.x){
            return m_value.y;
        }

        float curveX = map(windowX, m_value.x, others.get(myIndex + 1).getValue().x, 0, 1);
        float curveY = getY(curveX);

        return map(curveY, 0, 1, m_value.y, others.get(myIndex + 1).getValue().y);
    }

    public boolean checkHitbox(){
        return ( (mouseX - getActualPosition().x) * (mouseX - getActualPosition().x)
                 + (mouseY - getActualPosition().y) * (mouseY - getActualPosition().y) )
                 < (m_radius * m_radius);
    }

    public boolean checkCurveHandleHitbox(ArrayList<AutomationPoint> others, int myIndex){
        return ( (mouseX - getCurveHandlePosition(others, myIndex).x) * (mouseX - getCurveHandlePosition(others, myIndex).x)
                 + (mouseY - getCurveHandlePosition(others, myIndex).y) * (mouseY - getCurveHandlePosition(others, myIndex).y) )
                 < (m_radius * m_radius);
    }

    public void resetCurve(){
        m_curve = 0.5;
    }

}
