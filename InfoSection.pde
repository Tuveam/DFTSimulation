class InfoSection extends GUISection{
    protected String[] m_infoText;

    protected LinkButton[] m_linkButton;

    InfoSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));
        m_infoText = loadStrings("info.txt");

        m_linkButton = new LinkButton[3];

        for(int i = 0; i < m_linkButton.length; i++){
            m_linkButton[i] = new LinkButton(new Bounds(m_pos.x + m_len.x - 2 * m_spacer,
                                            m_pos.y + m_spacer + i * 3 * m_spacer / 2,
                                            m_spacer,
                                            m_spacer));
            m_linkButton[i].setLink(m_infoText[i]);
        }
    }

    protected void drawBackground(){
        noStroke();
        fill(40);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y);

        float textSize = 25;
        fill(200);
        textSize(textSize);
        textAlign(LEFT);
        for(int i = m_linkButton.length; i < m_infoText.length; i++){
            text( m_infoText[i], m_pos.x + m_spacer, m_pos.y + m_spacer + i * textSize);
        }
        
    }

    protected void drawComponents(){

        for(int i = 0; i < m_linkButton.length; i++){


            m_linkButton[i].update();
        }
    } 


}