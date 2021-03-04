class Graph{
    private PVector m_pos;
    private PVector m_len;
    private color m_color;

    protected float[] m_data;
    protected int m_dataLength;
    protected int m_firstIndex;
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
        m_dataLength = m_data.length;

        m_firstIndex = m_data.length - 1;
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
        }else{
            println("Wrong Data size");
        }

        m_firstIndex = m_data.length - 1;
    }

    public void setLatestValue(float value){
        int lastIndex = getLastIndex();
        m_data[lastIndex] = value;
        m_firstIndex = lastIndex;
    }

    public int getFirstIndex(){
        return m_firstIndex;
    }

    protected int getLastIndex(){
        return (m_firstIndex + 1) % m_data.length;
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

            case 2:
            drawShape();
            break;

            case 3:
            drawPointsAndLines();
            drawShape();
            break;
        }
        
    }

    private void drawPointsAndLines(){
        noFill();
        stroke(m_color);
        strokeWeight(2);
        float spacing = m_len.x / (m_dataLength - 1);
        for(int i = 0; i < m_dataLength; i++){

            float drawValue = getDrawValue(i);

            ellipse(m_pos.x + i * spacing,
                map(drawValue, m_minInputValue, m_maxInputValue, m_pos.y + m_len.y, m_pos.y),
                10, 10);
            line(m_pos.x + i * spacing,
                map(drawValue, m_minInputValue, m_maxInputValue, m_pos.y + m_len.y, m_pos.y),
                m_pos.x + i * spacing,
                m_pos.y + (1 - m_baseValue) * m_len.y);
        }
    }

    private void drawShapeAndLines(){
        noFill();
        stroke(m_color);
        strokeWeight(2);
        beginShape();
        float spacing = m_len.x / (m_dataLength);
        for(int i = 0; i < m_dataLength; i++){

            float drawValue = getDrawValue(i);

            vertex(m_pos.x + spacing/2 + i * spacing,
                map(drawValue, m_minInputValue, m_maxInputValue, m_pos.y + m_len.y, m_pos.y));
            line(m_pos.x + spacing/2 + i * spacing,
                map(drawValue, m_minInputValue, m_maxInputValue, m_pos.y + m_len.y, m_pos.y),
                m_pos.x + spacing/2 + i * spacing,
                m_pos.y + (1 - m_baseValue) * m_len.y);
        }

        
        endShape();
    }

    private void drawShape(){
        noFill();
        stroke(m_color);
        strokeWeight(2);
        beginShape();
        float spacing = m_len.x / (m_dataLength - 1);
        for(int i = 0; i < m_dataLength; i++){

            float drawValue = getDrawValue(i);

            vertex(m_pos.x + i * spacing,
                map(drawValue, m_minInputValue, m_maxInputValue, m_pos.y + m_len.y, m_pos.y));
        }

        
        endShape();
    }

    protected float getDrawValue(int index){
        return m_data[getDrawIndex(index)];
    }

    public int getDrawIndex(int index){
        return (index + m_firstIndex + 1) % m_dataLength;
    }

    public int getLength(){
        return m_dataLength;
    }
}

//==========================================================================================

class SampledGraph extends Graph{
    private float[] m_inputData;

    SampledGraph(float xPos, float yPos, float xLen, float yLen, int maxResolution){
        super(xPos, yPos, xLen, yLen, maxResolution);

    }

    public void setSampleRate(int samplerate){
        m_dataLength = samplerate;
    }

    public void setData(float[] data){
        //println("Graph.setData(): " + data[data.length - 1]);
        m_inputData = data;

        translateData();

        m_firstIndex = m_data.length - 1;
    }

    protected void translateData(){
        for(int i = 0; i < m_dataLength - 1; i++){
            m_data[i] = m_inputData[i * m_inputData.length/(m_dataLength - 1) ];
        }

        m_data[m_dataLength - 1] = m_inputData[m_inputData.length - 1];
    }

    public int getDrawIndex(int index){
        return index;
    }

    public float[] getData(){
        return subset(m_data, 0, m_dataLength);
    }

}

//==========================================================================================

class InterpolationGraph extends Graph{
    InterpolationGraph(float xPos, float yPos, float xLen, float yLen){
        super(xPos, yPos, xLen, yLen, 1);
        setDisplayMode(3);
    }

    public void setData(float[] data){
        m_data = data;
        m_dataLength = m_data.length;
    }

    public int getDrawIndex(int index){
        return index;
    }
}