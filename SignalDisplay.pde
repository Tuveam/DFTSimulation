class SignalDisplay{
    private PVector m_pos;
    private PVector m_len;
    
    boolean m_automationIsVisible = true;
    boolean m_inputIsVisible = true;
    boolean m_testFreqVisible = true;
    int m_testFreqIndex = 0;

    private Automation m_automation;
    private Graph m_input;
    private Graph[] m_testFreq;

    SignalDisplay(float posX, float posY, float lenX, float lenY, int testSineAmount, int resolution){
        m_pos = new PVector(posX, posY);
        m_len = new PVector(lenX, lenY);

        m_automation = new Automation(m_pos.x, m_pos.y, m_len.x, m_len.y,
                                        color(200, 75, 75), false);
        m_automation.setRealValueRange(-1, 1);

        m_input = new Graph(m_pos.x, m_pos.y, m_len.x, m_len.y, resolution);
        m_input.setColor(color(75, 75, 170));

        m_testFreq = new Graph[testSineAmount];
        for(int i = 0; i < m_testFreq.length; i++){
            m_testFreq[i] = new Graph(m_pos.x, m_pos.y, m_len.x, m_len.y, resolution);
        }
        setDataForTestFreqs();

        
    }

    private void setDataForTestFreqs(){
        for(int i = 0; i < m_testFreq.length; i++){
            float[] temp = new float[m_testFreq[0].getLength()];

            if(i < m_testFreq.length/2){
                for(int x = 0; x < temp.length; x++){
                    temp[x] = sin(i * TWO_PI * x / temp.length);
                }
            }else{
                for(int x = 0; x < temp.length; x++){
                    temp[x] = cos((i % (m_testFreq.length/2) ) * TWO_PI * x / temp.length);
                }
            }

            m_testFreq[i].setData(temp);
        }
    }

    public void setDataForInput(float[] data){
        m_input.setData(data);
        //println("SignalDisplay.setDataForInput(): " + data[data.length - 1]);
    }

    public void setInputVisibility(boolean isVisible){
        m_inputIsVisible = isVisible;
    }

    public void setTestFreqVisibility(boolean isVisible){
        m_testFreqVisible = isVisible;
    }

    public void setTestFreq(int testFreqIndex){
        m_testFreqIndex = testFreqIndex;
    }

    public void setAutomationVisibility(boolean isVisible){
        m_automationIsVisible = isVisible;
    }

    public float[] getMultipliedArray(int withTestFreq){
        float[] temp = new float[m_input.getData().length];

        float[] ip = m_input.getData();

        float[] tf = new float[m_input.getData().length];

        if(m_testFreqVisible){
            tf = m_testFreq[withTestFreq].getData();
        }
        

        for(int i = 0; i < temp.length; i++){
            temp[i] = ip[i];

            if(m_automationIsVisible){
                temp[i] *= m_automation.mapXToRealY(i / (1.0f * temp.length));
            }

            if(m_testFreqVisible){
                
                temp[i] *= tf[i];
            }
            
        }

        return temp;
    }

    public float[] getMultipliedArray(){
        return getMultipliedArray(m_testFreqIndex);
    }

    public float getMultipliedArrayAdded(int withTestFreq){
        float ret = 0;

        float[] temp = getMultipliedArray(withTestFreq);

        for(int i = 0; i < temp.length; i++){
            ret += temp[i];
        }

        return ret / temp.length;
    }

    public float getMultipliedArrayAdded(){
        return getMultipliedArrayAdded(m_testFreqIndex);
    }

    public float[] getSpectrum(){
        int freqAmount = m_testFreq.length / 2;
        float[] temp = new float[freqAmount];

        for(int i = 0; i < freqAmount; i++){
            temp[i] = sqrt(getMultipliedArrayAdded(i) * getMultipliedArrayAdded(i)
                        + getMultipliedArrayAdded(i + freqAmount) * getMultipliedArrayAdded(i + freqAmount));
        }

        return temp;
    }


    public void draw(){
        stroke(color(100, 100, 100));
        strokeWeight(2);
        fill(color(50, 50, 50));
        rect(m_pos.x, m_pos.y, m_len.x, m_len.y);

        

        if(m_testFreqVisible){
            //println("Yes" + m_testFreq[i].getData());
            m_testFreq[m_testFreqIndex].draw();
        }

        if(m_inputIsVisible){
            m_input.draw();
        }
        
        if(m_automationIsVisible){
            m_automation.update();
        }
        
    }

}