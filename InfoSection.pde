class InfoSection extends GUISection{
    InfoSection(float xPos, float yPos, float xLen, float yLen){
        super(new PVector(xPos, yPos), new PVector(xLen, yLen));
    }

    protected void drawBackground(){
        noStroke();
        fill(40);
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y);

        fill(200);
        textSize(15);
        textAlign(LEFT);
        text("This is some test Text.\nDo we have a line break here? And what about here?\nAnyway lets see!", m_pos.x + m_spacer, m_pos.y + m_spacer);
    }


}