class Tabs extends Controller{

    protected int m_value;
    protected String[] m_tabName;

    Tabs(Bounds b, String[] tabName){
        super(b);

        m_value = 0;

        m_tabName = tabName;
    }

    protected void click(){
        if(mousePressed && (m_firstClick || m_selected)){
            m_firstClick = false;

            if(m_bounds.checkHitbox(mouseX, mouseY)){

                int xPartitions = m_tabName.length;

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;

                m_value = m_bounds.checkHitboxXPartition(mouseX, xPartitions);

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
        rect(m_bounds.withoutBottomRatio(0.2), 10);

        if(m_value > 0){
            //rect(m_pos.x, m_pos.y, m_value * m_len.x/m_tabName.length, m_len.y, 10);
            rect(m_bounds.fromToSectionOfXDivisions(0, m_value, m_tabName.length), 10);
        }

        if(m_value < (m_tabName.length - 1)){
            //rect(m_pos.x + (m_value + 1) * m_len.x/m_tabName.length, m_pos.y, (m_tabName.length - (m_value + 1)) * m_len.x/m_tabName.length, m_len.y, m_len.y/5);
            rect(m_bounds.fromToSectionOfXDivisions(m_value + 1, m_tabName.length, m_tabName.length), 10);
        }

        //marked Tab
        fill(m_fillColor);
        //rect(m_pos.x + m_value * m_len.x/m_tabName.length, m_pos.y, m_len.x/m_tabName.length, 4 * m_len.y/5);
        rect( m_bounds.asSectionOfXDivisions(m_value, m_tabName.length).withoutBottomRatio( 0.2 ) );

        stroke(m_backgroundColor1);
        strokeWeight(2);
        for(int i = 1; i < m_tabName.length; i++){
            line(m_bounds.getXPos() + i * m_bounds.getXLen()/m_tabName.length,
                m_bounds.getYPos() + m_bounds.getYLen()/5,
                m_bounds.getXPos() + i * m_bounds.getXLen()/m_tabName.length,
                m_bounds.getYPos() + 4 * m_bounds.getYLen()/5);
        }

        fill(m_textColor);
        textAlign(CENTER);
        textSize(m_textSize);
        for(int i = 0; i < m_tabName.length; i++){
            text(m_tabName[i], m_bounds.getXPos() + (i + 0.5) * m_bounds.getXLen()/m_tabName.length, m_bounds.getYPos() + 5 * m_bounds.getYLen()/8);
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

    SinCosTabs(Bounds b, String[] tabName){
        super(b, tabName);
    }

    protected void draw(){
        int xPartitions = (m_tabName.length % 2 == 0)? m_tabName.length/2 : m_tabName.length/2 + 1;

        //Background
        noStroke();
        fill(m_backgroundColor2);
        /*rect(m_pos.x,
            m_pos.y + m_len.y/10,
            m_len.x,
            4 * m_len.y / 5);*/
        rect(m_bounds.withYFrameRatio(0.1));
        
        //Unmarked Tabs
        if(m_value < xPartitions){
            //Upper Deck
            if(m_value > 0){//Left
                rect(m_bounds.withoutBottomRatio(0.5).fromToSectionOfXDivisions(0, m_value, xPartitions),
                    m_bounds.getYLen()/10);
            }

            if(m_value < xPartitions - 1){//Right
                rect(m_bounds.withoutBottomRatio(0.5).fromToSectionOfXDivisions(m_value + 1, xPartitions, xPartitions),
                    m_bounds.getYLen()/10);
            }

            //Lower Deck
            rect(m_bounds.withoutTopRatio(0.5), m_bounds.getYLen()/10);
        }else{
            //Upper Deck
            rect(m_bounds.withoutBottomRatio(0.5), m_bounds.getYLen()/10);

            //Lower Deck
            if((m_value % xPartitions) > 0){//Left
                rect( m_bounds.withoutTopRatio(0.5).fromToSectionOfXDivisions(0, m_value % xPartitions, xPartitions) );
            }

            if((m_value % xPartitions) < xPartitions - 1){
                rect( m_bounds.withoutTopRatio(0.5).fromToSectionOfXDivisions( (m_value % xPartitions) + 1, xPartitions, xPartitions) );
            }
        }
        
        //Marked Tab
        noStroke();
        fill(m_fillColor);
        rect( m_bounds.withoutBottomRatio(0.6
                        ).withYPos( m_bounds.getYPos() + ((m_value / xPartitions) * 0.4 + 0.1) * m_bounds.getYLen() 
                        ).asSectionOfXDivisions(m_value % xPartitions, xPartitions) );


        //Lines
        stroke(m_backgroundColor1);
        strokeWeight(2);

        for(int i = 1; i < xPartitions; i++){
            line(m_bounds.getXPos() + i * m_bounds.getXLen()/xPartitions,
                m_bounds.getYPos() + m_bounds.getYLen()/10,
                m_bounds.getXPos() + i * m_bounds.getXLen()/xPartitions,
                m_bounds.getYPos() + 9 * m_bounds.getYLen()/10);
        }

        //Tabnames
        fill(m_textColor);
        textAlign(CENTER);
        textSize(m_textSize);
        for(int i = 0; i < m_tabName.length; i++){
            text(m_tabName[i],
                m_bounds.getXPos() + ((i % xPartitions) + 0.5) * m_bounds.getXLen()/xPartitions,
                m_bounds.getYPos() + 5 * m_bounds.getYLen()/12 + (i / xPartitions) * m_bounds.getYLen()/2);
        }
    }

    protected void click(){
        if(mousePressed && (m_firstClick || m_selected)){
            
            m_firstClick = false;

            if(m_bounds.checkHitbox(mouseX, mouseY)){

                int xPartitions = (m_tabName.length % 2 == 0)? m_tabName.length/2 : m_tabName.length/2 + 1;

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;

                m_value = constrain(xPartitions * m_bounds.checkHitboxYPartition(mouseY, 2) + m_bounds.checkHitboxXPartition(mouseX, xPartitions), 0, m_tabName.length - 1);

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

    HoverTabs(Bounds b, String[] tabName){
        super(b, tabName);

    }

    protected void draw(){
        //float spacing = m_len.x / m_tabName.length;

        //m_value-Rectangle
        Bounds bValue = m_bounds.asSectionOfXDivisions(m_value, m_tabName.length);
        fill(m_fillColor, 50);
        noStroke();
        //rect(m_pos.x + m_value * spacing, m_pos.y, spacing, m_len.y);
        rect(bValue);

        fill(m_textColor);
        textAlign(CENTER);
        textSize(m_textSize);
        text(m_tabName[m_value], bValue.getXPos() + bValue.getXLen()/2, bValue.getYPos() + bValue.getXLen());

        //m_hoverValue-Rectangle
        Bounds bHoverValue = m_bounds.asSectionOfXDivisions(m_hoverValue, m_tabName.length);
        fill(255, 50);
        noStroke();
        //rect(m_pos.x + m_hoverValue * spacing, m_pos.y, spacing, m_len.y);
        rect( bHoverValue );

        fill(m_textColor);
        textAlign(CENTER);
        textSize(m_textSize);
        text(m_tabName[m_hoverValue], bHoverValue.getXPos() + bHoverValue.getXLen()/2, bHoverValue.getYPos() + bHoverValue.getXLen());
    }

    public void update(){
        hover();
        click();
        adjust();
        draw();
    }

    protected void hover(){
        if(m_firstClick && 
            m_bounds.checkHitbox(mouseX, mouseY)){

            int xPartitions = m_tabName.length;

            m_hoverValue = m_bounds.checkHitboxXPartition(mouseX, xPartitions);
        }else{
            m_hoverValue = m_value;
        }

    }

}

//====================================================================

class VerticalTabs extends Tabs{

    VerticalTabs(Bounds b, String[] tabName){
        super(b, tabName);
    }

    protected void click(){
        if(mousePressed && (m_firstClick || m_selected)){
            m_firstClick = false;

            if(m_bounds.checkHitbox(mouseX, mouseY)){

                int yPartitions = m_tabName.length;

                m_mouseClicked.x = mouseX;
                m_mouseClicked.y = mouseY;

                m_selected = true;

                m_value = m_bounds.checkHitboxYPartition(mouseY, yPartitions);

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
        rect(m_bounds.withoutRightRatio(0.2), 10);

        //Unmarked Tabs
        //Upper
        if(m_value > 0){
            //rect(m_pos.x, m_pos.y, m_len.x, m_value * m_len.y/m_tabName.length, m_len.x/5);
            rect( m_bounds.fromToSectionOfYDivisions(0, m_value, m_tabName.length), m_bounds.getXLen()/5 );
        }

        //Lower
        if(m_value < (m_tabName.length - 1)){
            /*rect(m_pos.x,
                m_pos.y + (m_value + 1) * m_len.y/m_tabName.length,
                m_len.x,
                (m_tabName.length - (m_value + 1)) * m_len.y/m_tabName.length,
                m_len.x/5);*/
            rect( m_bounds.fromToSectionOfYDivisions(m_value + 1, m_tabName.length, m_tabName.length), m_bounds.getXLen()/5 );
        }

        //Marked Tab
        fill(m_fillColor);
        /*rect(m_pos.x,
            m_pos.y + m_value * m_len.y/m_tabName.length,
            4 * m_len.x/5, 
            m_len.y/m_tabName.length);*/
        rect( m_bounds.asSectionOfYDivisions(m_value, m_tabName.length).withoutRightRatio( 0.2 ) );

        //Lines
        stroke(m_backgroundColor1);
        strokeWeight(2);
        for(int i = 1; i < m_tabName.length; i++){
            line(m_bounds.getXPos() + m_bounds.getXLen()/5,
                m_bounds.getYPos() + i * m_bounds.getYLen()/m_tabName.length,
                m_bounds.getXPos() + 4 * m_bounds.getXLen()/5,
                m_bounds.getYPos() + i * m_bounds.getYLen()/m_tabName.length);
        }

        //Text
        fill(m_textColor);
        textAlign(CENTER);
        textSize(m_textSize);
        for(int i = 0; i < m_tabName.length; i++){
            pushMatrix();
            translate(m_bounds.getXPos() + 5 * m_bounds.getXLen()/8,
                    m_bounds.getYPos() + (i + 0.5) * m_bounds.getYLen()/m_tabName.length);
            rotate(3 * PI / 2);
            text(m_tabName[i], 0, 0);
            popMatrix();
            
        }

    }
}