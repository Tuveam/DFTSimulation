class InfoSection extends GUISection{
    protected String[] m_infoText;

    protected LinkButton[] m_linkButton;

    InfoSection(Bounds b){
        super(b);
        m_infoText = loadStrings("info.txt");

        m_linkButton = new LinkButton[3];

        Bounds area = m_bounds.withoutLeft(m_bounds.getXLen() - 2 * m_spacer
            ).withoutRight(m_spacer
            ).withYFrame(m_spacer);
        for(int i = 0; i < m_linkButton.length; i++){
            m_linkButton[i] = new LinkButton(area.withYPos(area.getYPos() + i * 3 * m_spacer/2
                ).withYLen(m_spacer));
            m_linkButton[i].setLink(m_infoText[i]);
        }
    }

    protected void drawBackground(){
        noStroke();
        fill(40);
        rect(m_bounds);

        float textSize = 25;
        fill(200);
        textSize(textSize);
        textAlign(LEFT);
        for(int i = m_linkButton.length; i < m_infoText.length; i++){
            text( m_infoText[i], m_bounds.getXPos() + m_spacer, m_bounds.getYPos() + m_spacer + i * textSize);
        }
        
    }

    protected void drawComponents(){

        for(int i = 0; i < m_linkButton.length; i++){


            m_linkButton[i].update();
        }
    } 


}