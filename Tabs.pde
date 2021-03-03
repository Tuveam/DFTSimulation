class Tabs extends Controller{

    protected int m_value;
    protected String[] m_tabName;

    Tabs(float xPos, float yPos, float xLen, float yLen, String[] tabName){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));

        m_value = 0;

        m_tabName = tabName;
    }

    protected void click(){
        if(mousePressed && (m_firstClick || m_selected)){
            m_firstClick = false;

            if(mouseX >= m_pos.x &&
                mouseX <= m_pos.x + m_len.x &&
                mouseY >= m_pos.y && 
                mouseY <= m_pos.y + m_len.y){

                int xPartitions = m_tabName.length;

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;

                m_value = constrain(floor(xPartitions * (mouseX - m_pos.x)/m_len.x), 0, m_tabName.length - 1);

            }

        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
        
    }

    protected void draw(){
        noStroke();
        fill(m_backgroundColor2);
        rect(m_pos.x, m_pos.y, m_len.x, 4 * m_len.y/5, 10);

        if(m_value > 0){
            rect(m_pos.x, m_pos.y, m_value * m_len.x/m_tabName.length, m_len.y, 10);
        }

        if(m_value < (m_tabName.length - 1)){
            rect(m_pos.x + (m_value + 1) * m_len.x/m_tabName.length, m_pos.y, (m_tabName.length - (m_value + 1)) * m_len.x/m_tabName.length, m_len.y, m_len.y/5);
        }

        fill(m_fillColor);
        rect(m_pos.x + m_value * m_len.x/m_tabName.length, m_pos.y, m_len.x/m_tabName.length, 4 * m_len.y/5);

        stroke(m_backgroundColor1);
        strokeWeight(2);
        for(int i = 1; i < m_tabName.length; i++){
            line(m_pos.x + i * m_len.x/m_tabName.length, m_pos.y + m_len.y/5, m_pos.x + i * m_len.x/m_tabName.length, m_pos.y + 4 * m_len.y/5);
        }

        fill(m_textColor);
        textAlign(CENTER);
        textSize(m_textSize);
        for(int i = 0; i < m_tabName.length; i++){
            text(m_tabName[i], m_pos.x + (i + 0.5) * m_len.x/m_tabName.length, m_pos.y + 5 * m_len.y/8);
        }

    }

    public int getValue(){
        return m_value;
    }

    public void setValue(int value){
        if(value < m_tabName.length && value >= 0){
            m_value = value;
        }
    }

    public int getMaxValue(){
        return m_tabName.length;
    }

}

//====================================================================

class SinCosTabs extends Tabs{

    SinCosTabs(float xPos, float yPos, float xLen, float yLen, String[] tabName){
        super(xPos, yPos, xLen, yLen, tabName);
    }

    protected void draw(){
        int xPartitions = (m_tabName.length % 2 == 0)? m_tabName.length/2 : m_tabName.length/2 + 1;

        //Background
        noStroke();
        fill(m_backgroundColor2);
        rect(m_pos.x,
            m_pos.y + m_len.y/10,
            m_len.x,
            4 * m_len.y / 5);
        
        //Unmarked Tabs
        if(m_value < xPartitions){
            //Upper Deck
            if(m_value > 0){//Left
                rect(m_pos.x, m_pos.y,
                    m_value * m_len.x / xPartitions,
                    m_len.y/2, m_len.y/10);
            }

            if(m_value < xPartitions - 1){//Right
                rect(m_pos.x + (m_value + 1) * m_len.x / xPartitions,
                    m_pos.y,
                    (xPartitions - 1 - m_value) * m_len.x / xPartitions,
                    m_len.y/2, m_len.y/10);
            }

            //Lower Deck
            rect(m_pos.x, m_pos.y + m_len.y/2, m_len.x, m_len.y/2, m_len.y/10);
        }else{
            //Upper Deck
            rect(m_pos.x, m_pos.y, m_len.x, m_len.y/2, m_len.y/10);

            //Lower Deck
            if((m_value % xPartitions) > 0){//Left
                rect(m_pos.x,
                    m_pos.y + m_len.y/2,
                    (m_value % xPartitions) * m_len.x / xPartitions,
                    m_len.y/2, m_len.y/10);
            }

            if((m_value % xPartitions) < xPartitions - 1){
                rect(m_pos.x + ((m_value % xPartitions) + 1) * m_len.x / xPartitions,
                    m_pos.y + m_len.y/2,
                    (xPartitions - 1 - (m_value % xPartitions)) * m_len.x / xPartitions,
                    m_len.y/2, m_len.y/10);
            }
        }
        
        //Marked Tab
        noStroke();
        fill(m_fillColor);
        rect(m_pos.x + (m_value % xPartitions) * m_len.x / xPartitions,
            m_pos.y + m_len.y/10 + (m_value / xPartitions) * m_len.y * 2 / 5,
            m_len.x / xPartitions,
            m_len.y * 2 / 5);

        //Lines
        stroke(m_backgroundColor1);
        strokeWeight(2);
        //line(m_pos.x, m_pos.y + m_len.y/2, m_pos.x + m_len.x, m_pos.y + m_len.y/2);

        for(int i = 1; i < xPartitions; i++){
            line(m_pos.x + i * m_len.x / xPartitions,
                m_pos.y + m_len.y/10,
                m_pos.x + i * m_len.x / xPartitions,
                m_pos.y + 9 * m_len.y/10);
        }

        //Tabnames
        fill(m_textColor);
        textAlign(CENTER);
        textSize(m_textSize);
        for(int i = 0; i < m_tabName.length; i++){
            text(m_tabName[i],
                m_pos.x + ((i % xPartitions) + 0.5) * m_len.x/xPartitions,
                m_pos.y + 5 * m_len.y/12 + (i / xPartitions) * m_len.y/2);
        }
    }

    protected void click(){
        if(mousePressed && (m_firstClick || m_selected)){
            
            m_firstClick = false;

            if(mouseX >= m_pos.x &&
                mouseX <= m_pos.x + m_len.x &&
                mouseY >= m_pos.y && 
                mouseY <= m_pos.y + m_len.y){

                int xPartitions = (m_tabName.length % 2 == 0)? m_tabName.length/2 : m_tabName.length/2 + 1;

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;

                m_value = constrain(xPartitions * round((mouseY - m_pos.y)/m_len.y) + floor(xPartitions * (mouseX - m_pos.x)/m_len.x), 0, m_tabName.length - 1);

            }

        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
        
    }


}

//====================================================================

class HoverTabs extends Tabs{
    private int m_hoverValue = 0;

    HoverTabs(float xPos, float yPos, float xLen, float yLen, String[] tabName){
        super(xPos, yPos, xLen, yLen, tabName);

    }

    protected void draw(){
        float spacing = m_len.x / m_tabName.length;

        //m_value-Rectangle
        fill(m_fillColor, 50);
        noStroke();
        rect(m_pos.x + m_value * spacing, m_pos.y, spacing, m_len.y);

        fill(m_textColor);
        textAlign(CENTER);
        textSize(m_textSize);
        text(m_tabName[m_value], m_pos.x + m_value * spacing + spacing/2, m_pos.y + spacing);

        //m_hoverValue-Rectangle
        fill(255, 50);
        noStroke();
        rect(m_pos.x + m_hoverValue * spacing, m_pos.y, spacing, m_len.y);

        fill(m_textColor);
        textAlign(CENTER);
        textSize(m_textSize);
        text(m_tabName[m_hoverValue], m_pos.x + m_hoverValue * spacing + spacing/2, m_pos.y + spacing);
    }

    public void update(){
        hover();
        click();
        adjust();
        draw();
    }

    protected void hover(){
        if(m_firstClick && 
            mouseX >= m_pos.x &&
            mouseX <= m_pos.x + m_len.x &&
            mouseY >= m_pos.y && 
            mouseY <= m_pos.y + m_len.y){

            int xPartitions = m_tabName.length;

            m_hoverValue = constrain(floor(xPartitions * (mouseX - m_pos.x)/m_len.x), 0, m_tabName.length - 1);
        }else{
            m_hoverValue = m_value;
        }

    }

}

//====================================================================

class VerticalTabs extends Tabs{

    VerticalTabs(float xPos, float yPos, float xLen, float yLen, String[] tabName){
        super(xPos, yPos, xLen, yLen, tabName);
    }

    protected void click(){
        if(mousePressed && (m_firstClick || m_selected)){
            m_firstClick = false;

            if(mouseX >= m_pos.x &&
                mouseX <= m_pos.x + m_len.x &&
                mouseY >= m_pos.y && 
                mouseY <= m_pos.y + m_len.y){

                int yPartitions = m_tabName.length;

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;

                m_value = constrain(floor(yPartitions * (mouseY - m_pos.y)/m_len.y), 0, m_tabName.length - 1);

            }

        }
        
        if(!mousePressed){
            m_selected = false;
            m_firstClick = true;
        }
        
    }

    protected void draw(){

        //Background
        noStroke();
        fill(m_backgroundColor2);
        rect(m_pos.x, m_pos.y, 4 * m_len.x / 5, m_len.y, 10);

        //Unmarked Tabs
        //Upper
        if(m_value > 0){
            rect(m_pos.x, m_pos.y, m_len.x, m_value * m_len.y/m_tabName.length, m_len.x/5);
        }

        //Lower
        if(m_value < (m_tabName.length - 1)){
            rect(m_pos.x,
                m_pos.y + (m_value + 1) * m_len.y/m_tabName.length,
                m_len.x,
                (m_tabName.length - (m_value + 1)) * m_len.y/m_tabName.length,
                m_len.x/5);
        }

        //Marked Tab
        fill(m_fillColor);
        rect(m_pos.x,
            m_pos.y + m_value * m_len.y/m_tabName.length,
            4 * m_len.x/5, 
            m_len.y/m_tabName.length);

        //Lines
        stroke(m_backgroundColor1);
        strokeWeight(2);
        for(int i = 1; i < m_tabName.length; i++){
            line(m_pos.x + m_len.x/5,
                m_pos.y + i * m_len.y/m_tabName.length,
                m_pos.x + 4 * m_len.x/5,
                m_pos.y + i * m_len.y/m_tabName.length);
        }

        //Text
        fill(m_textColor);
        textAlign(CENTER);
        textSize(m_textSize);
        for(int i = 0; i < m_tabName.length; i++){
            pushMatrix();
            translate(m_pos.x + 5 * m_len.x/8, m_pos.y + (i + 0.5) * m_len.y/m_tabName.length);
            rotate(3 * PI / 2);
            text(m_tabName[i], 0, 0);
            popMatrix();
            
        }

    }
}