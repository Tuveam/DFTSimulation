class GUISection{
    PVector m_pos;
    PVector m_len;
    GUISection[] m_section;

    GUISection(PVector pos, PVector len, int sectionAmount){
        m_pos = pos;
        m_len = len;
        m_section = new GUISection[sectionAmount];

        initializeSections();
    }

    protected void initializeSections(){
        for(int i = 0; i < m_section.length; i++){

            m_section[i] = new GUISection(m_pos, m_len, 0);
        }
    }

    public void draw(){
        drawBackground();
        drawSections();
    }

    protected void drawBackground(){
        noStroke();
        fill(26);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);
    }

    protected void drawSections(){
        for(int i = 0; i < m_section.length; i++){

            m_section[i].draw();
        }
    }
}

class MainSection extends GUISection{

    MainSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen), 4);

    }

    protected void initializeSections(){
        for(int i = 0; i < m_section.length; i++){
            m_section[i] = new SubSection(m_pos.x, m_pos.y + i * m_len.y/m_section.length, m_len.x, m_len.y/m_section.length);
        }
    }

}

class SubSection extends GUISection{
    SubSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen), 0);
    }

    protected void drawBackground(){
        noStroke();
        fill(26, 75, 103);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);
    }
}