class OneGraphDisplay{
    private PVector m_pos;
    private PVector m_len;

    private Graph m_graph;

    OneGraphDisplay(float posX, float posY, float lenX, float lenY, int resolution){
        m_pos = new PVector(posX, posY);
        m_len = new PVector(lenX, lenY);

        m_graph = new Graph(m_pos.x, m_pos.y, m_len.x, m_len.y, resolution);
        m_graph.setColor(color(75, 140, 140));
    }

    public void setAsSpectrumDisplay(){
        m_graph.setBaseValue(0);
        m_graph.setInputValueRange(0, 0.6);
        m_graph.setDisplayMode(1);
    }

    public void setData(float[] data){
        m_graph.setData(data);
    }

    public void draw(){
        stroke(color(100, 100, 100));
        strokeWeight(2);
        fill(color(50, 50, 50));
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y);

        m_graph.draw();
    }



}