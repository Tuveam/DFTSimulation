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

class Generator{
    float[] m_data; //goes from -1 to 1
    int m_time = 0;
    float m_phase = 0; //goes from 0 to 1
    int m_generationMode = 3;
    float m_frequency = 1;
    

    Generator(int arrayLength){
        m_data = new float[arrayLength];
        for(int i = 0; i < m_data.length; i++){
            m_data[i] = 0;
        }
    }

    public void advanceTime(){
        m_phase = (m_phase + m_frequency / m_data.length)%1;

        switch(m_generationMode){
            case 0: //Zero
            m_data[getFirstIndex()] = 0;
            break;
            case 1: //Sin
            m_data[getFirstIndex()] = sin(2 * PI * m_phase);
            break;
            case 2: //Saw
            m_data[getFirstIndex()] = 2.0 * m_phase - 1;
            break;
            case 3: //Noise
            m_data[getFirstIndex()] = random(-1, 1);
            break;
        }
        m_time++;
    }

    public float[] getArray(){
        float[] temp = new float[m_data.length];
        for(int i = 0; i < m_data.length; i++){
            int tempIndex = (i + getFirstIndex()) % temp.length;
            temp[i] = m_data[tempIndex];
        }
        return temp;
    }

    protected int getFirstIndex(){
        return m_time % m_data.length;
    }

    public void setVariables(float frequency, int mode){
        m_frequency = frequency;
        m_generationMode = mode;
        //println(mode + " and " + m_generationMode);
    }

}