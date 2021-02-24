class Graph{
    private PVector m_pos;
    private PVector m_len;
    private color m_color;

    Graph(float xPos, float yPos, float xLen, float yLen){
        m_pos = new PVector(xPos, yPos);
        m_len = new PVector(xLen, yLen);

        m_color = color(75, 170, 75);
    }

    public void draw(float[] data){
        for(int i = 0; i < data.length; i++){
            noFill();
            stroke(m_color);
            strokeWeight(2);
            ellipse(m_pos.x + i * m_len.x / data.length, m_pos.y + m_len.y * (1 - data[i])/2, 10, 10);
            line(m_pos.x + i * m_len.x / data.length, m_pos.y + m_len.y * (1 - data[i])/2, m_pos.x + i * m_len.x / data.length, m_pos.y + m_len.y/2);
        }
    }
}

//==========================================================================================

