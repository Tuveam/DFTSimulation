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

    private boolean m_value;

    private boolean m_pressed = false;

    private color m_backgroundColor1;
    private color m_backgroundColor2;


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

        //Tick
        float indent = 0.1;
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

        popMatrix();
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

//====================================================================

class Automation extends Controller{

    ArrayList<AutomationPoint> m_point = new ArrayList<AutomationPoint>(2);

    private color m_backgroundColor1;
    private color m_backgroundColor2;

    Automation(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_backgroundColor1 = color(100, 100, 100);
        m_backgroundColor2 = color(50, 50, 50);
    }

    public void draw(){
        pushMatrix();
        translate(m_pos.x, m_pos.y);

        fill(m_backgroundColor2);
        stroke(m_backgroundColor1);
        strokeWeight(2);
        rect(0, 0, m_len.x, m_len.y);
        popMatrix();

    }

    public void setColor(color backgroundColor1, color backgroundColor2, color fillColor){
        m_backgroundColor1 = backgroundColor1;
        m_backgroundColor2 = backgroundColor2;
        m_fillColor = fillColor;
    }

}

class AutomationPoint extends Controller{


    AutomationPoint(PVector value, PVector windowLen){
        super(value, windowLen);
    }

    public void draw(){
        pushMatrix();
        translate(m_pos.x * m_len.x, m_pos.y * m_len.y);

        noFill();
        stroke(m_fillColor);
        strokeWeight(2);
        ellipse(0, 0, 5, 5);

        popMatrix();
    }

}