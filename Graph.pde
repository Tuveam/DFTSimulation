class Graph{
    private PVector m_pos;
    private PVector m_len;
    private float[] m_data; //goes from -1 to 1
    private color m_color;

    Graph(float xPos, float yPos, float xLen, float yLen, int arrayLength){
        m_pos = new PVector(xPos, yPos);
        m_len = new PVector(xLen, yLen);

        m_data = new float[arrayLength];
        for(int i = 0; i < m_data.length; i++){
            m_data[i] = 0;
        }

        m_color = color(3, 250, 75);
    }

    public void draw(int index){
        index %= m_data.length;

        for(int i = index; i < m_data.length; i++){
            noFill();
            stroke(m_color);
            strokeWeight(2);
            ellipse(m_pos.x + (i - index) * m_len.x / m_data.length, getPointYPos(i), 10, 10);
            line(m_pos.x + (i - index) * m_len.x / m_data.length, getPointYPos(i), m_pos.x + (i - index) * m_len.x / m_data.length, m_pos.y + m_len.y/2);
        }

        for(int i = 0; i < index; i++){
            noFill();
            stroke(m_color);
            strokeWeight(2);
            ellipse(m_pos.x + (i + m_data.length - index) * m_len.x / m_data.length, getPointYPos(i), 10, 10);
            line(m_pos.x + (i + m_data.length - index) * m_len.x / m_data.length, getPointYPos(i), m_pos.x + (i + m_data.length - index) * m_len.x / m_data.length, m_pos.y + m_len.y/2);
        }
    }

    private float getPointYPos(int index){
        return map(m_data[index], -1, 1, m_pos.y + m_len.y, m_pos.y);
    }

    public void addData(float data, int index){
        index %= m_data.length;
        m_data[index] = data;
    }
}