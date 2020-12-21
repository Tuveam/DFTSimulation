class Controller{
    //private float/boolean m_value = 0;
    
    protected float m_xPos, m_yPos, m_xLen, m_yLen;

    protected boolean m_selected = false;
    protected boolean m_firstClick = true;

    protected float m_mouseClickedX;
    protected float m_mouseClickedY;

    Controller(float xPos, float yPos, float xLen, float yLen){
        m_xPos = xPos;
        m_yPos = yPos;
        m_xLen = xLen;
        m_yLen = yLen;
    }

    public void update(){
        click();
        adjust();
        draw();
    }

    private void click(){
        if(mousePressed && m_firstClick){
            m_firstClick = false;
            if( mouseX >= m_xPos && 
                mouseX <= m_xPos + m_xLen && 
                mouseY >= m_yPos && 
                mouseY <= m_yPos + m_yLen){

                m_mouseClickedX = mouseX;
                m_mouseClickedY = mouseY;

                m_selected = true;
            }
        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
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

    private float m_sensitivity = 1;

    private color m_capColor;
    private color m_barColor;
    private color m_fillColor;

    Knob(float xPos, float yPos, float xLen, float yLen){
        super(xPos, yPos, (xLen < yLen)? xLen : yLen, (xLen < yLen)? xLen : yLen);
        m_value = 0.8;
        m_capColor = color(150, 150, 150);
        m_barColor = color(100, 100, 100);
        m_fillColor = color(50, 150, 50);
    }

    protected void adjust(){
        if(m_selected){
            m_value = m_sensitivity * (m_mouseClickedY - mouseY) / m_yLen;

            

            if(m_value < 0){
                m_value = 0;
            }

            if(m_value > 1){
                m_value = 1;
            }

            println(m_value);
        }
    }

    protected void draw(){
        colorMode(RGB, 255, 255, 255);

        //Bar
        noStroke();
        fill(m_barColor);
        arc(m_xPos + m_xLen / 2, m_yPos + m_yLen / 2, m_xLen, m_yLen, PI * 3 / 4, PI / 4, PIE);

        //Fill
        noStroke();
        fill(m_fillColor);
        arc(m_xPos + m_xLen / 2, m_yPos + m_yLen / 2, m_xLen, m_yLen, PI * 3 / 4, map(m_value, 0, 1, 0, 3 * PI / 2), PIE);
        
        //Cap
        noStroke();
        fill(m_capColor);
        ellipse(m_xPos + m_xLen / 2, m_yPos + m_yLen / 2, 0.6 * m_xLen, 0.6 * m_yLen);
    }

    public float getValue(){
        return m_value;
    }

    public void setColor(color capColor, color barColor, color fillColor){
        m_capColor = capColor;
        m_barColor = barColor;
        m_fillColor = fillColor;
    }
}