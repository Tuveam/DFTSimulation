class Graph{
    private PVector m_pos;
    private PVector m_len;
    private color m_color;

    private float[] m_data;
    private float m_baseValue = 0.5;
    private float m_minInputValue = -1;
    private float m_maxInputValue = 1;

    private int m_displayMode = 0;

    Graph(float xPos, float yPos, float xLen, float yLen, int resolution){
        m_pos = new PVector(xPos, yPos);
        m_len = new PVector(xLen, yLen);

        m_color = color(75, 170, 75);

        m_data = new float[resolution];
        for(int i = 0; i < m_data.length; i++){
            m_data[i] = 0;
        }
    }

    public void setBaseValue(float baseValue){
        m_baseValue = baseValue;
    }

    public void setInputValueRange(float minInputValue, float maxInputValue){
        m_minInputValue = minInputValue;
        m_maxInputValue = maxInputValue;
    }

    public void setData(float[] data){
        //println("Graph.setData(): " + data[data.length - 1]);
        if(data.length == m_data.length){
            m_data = data;
        }
    }

    public void setColor(color c){
        m_color = c;
    }

    public void setDisplayMode(int mode){
        m_displayMode = mode;
    }

    public float[] getData(){
        return m_data;
    }

    public void draw(){
        switch(m_displayMode){
            case 0:
            drawPointsAndLines();
            break;

            case 1:
            drawShapeAndLines();
            break;
        }
        
    }

    private void drawPointsAndLines(){
        noFill();
        stroke(m_color);
        strokeWeight(2);
        float spacing = m_len.x / (m_data.length - 1);
        for(int i = 0; i < m_data.length; i++){
            
            ellipse(m_pos.x + i * spacing,
                map(m_data[i], m_minInputValue, m_maxInputValue, m_pos.y + m_len.y, m_pos.y),
                10, 10);
            line(m_pos.x + i * spacing,
                map(m_data[i], m_minInputValue, m_maxInputValue, m_pos.y + m_len.y, m_pos.y),
                m_pos.x + i * spacing,
                m_pos.y + (1 - m_baseValue) * m_len.y);
        }
    }

    private void drawShapeAndLines(){
        noFill();
        stroke(m_color);
        strokeWeight(2);
        beginShape();
        float spacing = m_len.x / (m_data.length);
        for(int i = 0; i < m_data.length; i++){
            vertex(m_pos.x + spacing/2 + i * spacing,
                map(m_data[i], m_minInputValue, m_maxInputValue, m_pos.y + m_len.y, m_pos.y));
            line(m_pos.x + spacing/2 + i * spacing,
                map(m_data[i], m_minInputValue, m_maxInputValue, m_pos.y + m_len.y, m_pos.y),
                m_pos.x + spacing/2 + i * spacing,
                m_pos.y + (1 - m_baseValue) * m_len.y);
        }

        
        endShape();
    }

    public int getLength(){
        return m_data.length;
    }
}

//==========================================================================================

