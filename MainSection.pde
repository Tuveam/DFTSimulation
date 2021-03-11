class MainSection extends GUISection{
    protected VerticalTabs m_tabs;
    protected Tutorial m_tutorial;

    protected InterferenceSection m_interferenceSection;
    protected AliasingSection m_aliasingSection;
    protected DFTSection m_dftSection;
    protected InfoSection m_infoSection;


    MainSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));
        textFont(createFont("Arial", 20));

        String[] tempTabNames = new String[]{"+&x", "Aliasing", "DFT", "Info"};
        m_tabs = new VerticalTabs(new Bounds(m_pos.x, m_pos.y + m_spacer, m_spacer, m_len.y - m_spacer), tempTabNames);

        m_tutorial = new Tutorial(new Bounds(m_pos.x, m_pos.y, m_len.x, m_len.y), m_spacer);
    }

    protected void initializeSections(){
        m_interferenceSection = new InterferenceSection(m_pos.x + m_spacer, m_pos.y, m_len.x - m_spacer, m_len.y, 150);
        m_dftSection = new DFTSection(m_pos.x + m_spacer, m_pos.y, m_len.x - m_spacer, m_len.y, 80);
        m_aliasingSection = new AliasingSection(m_pos.x + m_spacer,
                                                m_pos.y,
                                                m_len.x - m_spacer,
                                                m_len.y);
        m_infoSection = new InfoSection(m_pos.x + m_spacer, m_pos.y, m_len.x - m_spacer, m_len.y);
    }

    protected void drawSections(){
        m_tabs.update();
        

        switch(m_tabs.getValue()){
            case 0:
            m_interferenceSection.update();
            break;
            case 1:
            m_aliasingSection.update();
            break;
            case 2:
            m_dftSection.update();
            break;
            case 3:
            m_infoSection.update();
            break;
        }

        m_tutorial.update();
        
    }


}