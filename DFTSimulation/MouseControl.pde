static class MouseControl{
    static private int m_idIterator;

    static private boolean m_isConstructed = false;

    static private int m_frame;
    static private boolean m_hasUpdated = false;
    static private boolean m_hasUpdatedClick = false;

    static private boolean[] m_isFirstClick;
    static private boolean m_isPreviousClick = false;

    static private int[] m_touchedID;
    static private int m_state;

    MouseControl(){}

    static public int getID(){
        construct();
        return m_idIterator++;
    }

    static private void construct(){
        if(!m_isConstructed){
            m_idIterator = 0;

            m_touchedID = new int [2];

            for(int i = 0; i < m_touchedID.length; i++){
                m_touchedID[i] = -1;
            }

            m_isFirstClick = new boolean [2];

            for(int i = 0; i < m_touchedID.length; i++){
                m_isFirstClick[i] = false;
            }

            m_state = 0;

            m_isConstructed = true;
        }
        
    }

    static private void update(boolean isClicked, int frame){
        if(m_frame != frame){
            m_hasUpdated = false;
            m_hasUpdatedClick = false;
        }

        if(!m_hasUpdated){
            iterateState();

            m_touchedID[getCurrentState()] = -1;

            m_frame = frame;

            

            m_hasUpdated = true;
        }

        if(!m_hasUpdatedClick){
            m_isFirstClick[getCurrentState()] = isClicked && !m_isPreviousClick;
            m_isPreviousClick = isClicked;

            m_hasUpdatedClick = true;
        }

    }

    static private void update(int frame){
        if(m_frame != frame){
            m_hasUpdated = false;
            m_hasUpdatedClick = false;
        }

        if(!m_hasUpdated){
            iterateState();

            m_touchedID[getCurrentState()] = -1;

            m_frame = frame;

            

            m_hasUpdated = true;
        }

    }

    static private int getCurrentState(){
        return m_state;
    }

    static private int getLastState(){
        if(m_state == 0){
            return 1;
        }

        return 0;
    }

    static private void iterateState(){
        if(m_state == 0){
            m_state = 1;
        }else{
            m_state = 0;
        }
    }

    static public boolean amIClicked(int controllerID, boolean isTargeted, boolean isClicked, int frame){
        update(isClicked, frame);

        if(isTargeted){
            m_touchedID[getCurrentState()] = controllerID;
        }

        if(m_isFirstClick[getLastState()] && controllerID == m_touchedID[getLastState()]){
            return true;
        }

        return false;
    }

    static public boolean amIHovered(int controllerID, boolean isTargeted, int frame){
        update(frame);

        if(isTargeted){
            m_touchedID[getCurrentState()] = controllerID;
        }

        if(controllerID == m_touchedID[getLastState()]){
            return true;
        }

        return false;
    }

    static public void onTop(boolean isTargeted, int frame){
        update(frame);

        if(isTargeted){
            m_touchedID[getCurrentState()] = -1;
        }
    }
}