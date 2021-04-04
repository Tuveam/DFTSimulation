class SignalDisplay{
    private Bounds m_bounds;
    
    boolean m_automationIsVisible = true;
    boolean m_inputIsVisible = true;
    boolean m_testFreqVisible = true;
    int m_testFreqIndex = 0;

    private Automation m_automation;
    private Graph m_input;
    private Graph[] m_testFreq;

    SignalDisplay(Bounds b, int testSineAmount, int resolution){
        m_bounds = b;

        m_automation = new Automation(m_bounds);
        m_automation.setRealValueRange(-1, 1);
        m_automation.setDrawBackground(false);
        m_automation.setColor(ColorLoader.getGreyColor(1), ColorLoader.getGreyColor(2), ColorLoader.getGraphColor(2));

        m_input = new Graph(m_bounds, resolution);
        m_input.setColor(ColorLoader.getGraphColor(0));

        m_testFreq = new Graph[testSineAmount];
        for(int i = 0; i < m_testFreq.length; i++){
            m_testFreq[i] = new Graph(m_bounds, resolution);
            m_testFreq[i].setColor(ColorLoader.getGraphColor(1));
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

    public void setLatestValueForInput(float value){
        m_input.setLatestValue(value);
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
            temp[i] = ip[m_input.getDrawIndex(i)];

            if(m_automationIsVisible){
                temp[i] *= m_automation.mapXToRealY(i / (1.0f * temp.length));
            }

            if(m_testFreqVisible){
                temp[i] *= tf[m_testFreq[withTestFreq].getDrawIndex(i)];
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

    public float[] getSinSpectrum(){
        int freqAmount = m_testFreq.length / 2;
        float[] temp = new float[freqAmount];

        for(int i = 0; i < freqAmount; i++){
            temp[i] = abs(getMultipliedArrayAdded(i));
        }

        return temp;
    }

    public float[] getCosSpectrum(){
        int freqAmount = m_testFreq.length / 2;
        float[] temp = new float[freqAmount];

        for(int i = 0; i < freqAmount; i++){
            temp[i] = abs(getMultipliedArrayAdded(i + freqAmount));
        }

        return temp;
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
        rect(m_bounds);

        

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