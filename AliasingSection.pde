class AliasingSection extends GUISection{

    protected AliasInputSection m_inputSection;
    protected InterpolationSection m_interpolationSection;

    AliasingSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));
    }

    protected void initializeSections(){
        m_inputSection = new AliasInputSection(m_pos.x, m_pos.y, m_len.x, m_len.y/2);
        m_interpolationSection = new InterpolationSection(m_pos.x, m_pos.y + m_len.y/2, m_len.x, m_len.y/2);
    }


    protected void drawSections(){
        m_inputSection.update();
        m_interpolationSection.update();
    }

}

//====================================================================

class AliasInputSection extends GUISection{

    AliasInputSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));
    }

    protected void drawBackground(){
        noStroke();
        fill(13, 37, 51);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);
    }

}

//====================================================================

class InterpolationSection extends GUISection{

    InterpolationSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));
    }

    protected void drawBackground(){
        noStroke();
        fill(51, 13, 37);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y, 10);
    }

}