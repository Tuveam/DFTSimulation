class Graph{
    private PVector m_pos;
    private PVector m_len;
    private color m_color;

    private float[] m_data;

    Graph(float xPos, float yPos, float xLen, float yLen, int resolution){
        m_pos = new PVector(xPos, yPos);
        m_len = new PVector(xLen, yLen);

        m_color = color(75, 170, 75);

        m_data = new float[resolution];
        for(int i = 0; i < m_data.length; i++){
            m_data[i] = 0;
        }
    }

    public void setData(float[] data){
        if(data.length == m_data.length){
            m_data = data;
        }
    }

    public void setColor(color c){
        m_color = c;
    }

    public float[] getData(){
        return m_data;
    }

    public void draw(){
        for(int i = 0; i < m_data.length; i++){
            noFill();
            stroke(m_color);
            strokeWeight(2);
            ellipse(m_pos.x + i * m_len.x / m_data.length, m_pos.y + m_len.y * (1 - m_data[i])/2, 10, 10);
            line(m_pos.x + i * m_len.x / m_data.length, m_pos.y + m_len.y * (1 - m_data[i])/2, m_pos.x + i * m_len.x / m_data.length, m_pos.y + m_len.y/2);
        }
    }

    public int getLength(){
        return m_data.length;
    }
}

//==========================================================================================

