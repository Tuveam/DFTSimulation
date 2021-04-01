class MainSection extends GUISection{
    protected VerticalTabs m_tabs;
    protected Tutorial m_tutorial;

    protected InterferenceSection m_interferenceSection;
    protected AliasingSection m_aliasingSection;
    protected DFTSection m_dftSection;
    protected InfoSection m_infoSection;


    MainSection(Bounds b){
        super(b);

        //savePNG();

        textFont(createFont("Arial", 20));

        String[] tempTabNames = new String[]{"+&x", "Aliasing", "DFT", "Info"};
        m_tabs = new VerticalTabs(m_bounds.withoutTop(m_spacer).withXLen(m_spacer), tempTabNames);

        m_tutorial = new Tutorial(m_bounds, m_spacer, tempTabNames);
    }

    protected void initializeSections(){
        Bounds temp = m_bounds.withoutLeft(m_spacer);
        m_interferenceSection = new InterferenceSection(temp, 150);
        m_dftSection = new DFTSection(temp, 80);
        m_aliasingSection = new AliasingSection(temp);
        m_infoSection = new InfoSection(temp);
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
        m_tutorial.setCurrentTab(m_tabs.getValue());
        
    }


}