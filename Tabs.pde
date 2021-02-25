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

        fill(m_backgroundColor1);
        textAlign(CENTER);
        textSize(m_len.y/2);
        for(int i = 0; i < m_tabName.length; i++){
            text(m_tabName[i], m_pos.x + (i + 0.5) * m_len.x/m_tabName.length, m_pos.y + 5 * m_len.y/8);
        }

    }

    public int getValue(){
        return m_value;
    }

}

//====================================================================

class SinCosTabs extends Tabs{

    SinCosTabs(float xPos, float yPos, float xLen, float yLen, String[] tabName){
        super(xPos, yPos, xLen, yLen, tabName);
    }

    public void draw(){
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
                    (xPartitions - m_value) * m_len.x / xPartitions,
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
                    (xPartitions - (m_value % xPartitions)) * m_len.x / xPartitions,
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
        fill(m_backgroundColor1);
        textAlign(CENTER);
        textSize(m_len.y/2);
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