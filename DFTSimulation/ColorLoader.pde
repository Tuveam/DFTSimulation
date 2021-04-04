static class ColorLoader{

    static private boolean m_isConstructed = false;
    static private color[][] m_color;

    ColorLoader(){
    }

    static private void construct(PImage colorPalette){
        if(!m_isConstructed){
            m_isConstructed = true;

            colorPalette.loadPixels();
            m_color = new color[colorPalette.height][colorPalette.width];

            for(int y = 0; y < m_color.length; y++){
                for(int x = 0; x < m_color[0].length; x++){
                    int i = x + colorPalette.width * y;
                    m_color[y][x] = colorPalette.pixels[i];
                }
                
            }
        }
    }

    static public color getColor(int group, int variant){

        if(group < m_color.length && variant < m_color[0].length){
            return m_color[group][variant];
        }

        return m_color[0][0];
        
    }

    static public color getGreyColor(int variant){
        return getColor(0, variant);
    }

    static public color getFillColor(int variant){
        return getColor(1, variant);
    }

    static public color getGraphColor(int variant){
        return getColor(2, variant);
    }

    static public color getBackgroundColor(int variant){
        return getColor(3, variant);
    }

}


void savePNG(){

    PImage temp = createImage(10, 4, RGB);

    temp.loadPixels();

    //global greys
    temp.pixels[0 * temp.width + 0] = color(228, 228, 228, 255);
    temp.pixels[0 * temp.width + 1] = color(100, 100, 100, 255);
    temp.pixels[0 * temp.width + 2] = color(50, 50, 50, 255);

    //fillcolors
    temp.pixels[1 * temp.width + 0] = color(56, 174, 65, 255);
    temp.pixels[1 * temp.width + 1] = color(200, 50, 50, 255);
    temp.pixels[1 * temp.width + 2] = color(224, 211, 36, 255);

    //graphcolors
    temp.pixels[2 * temp.width + 0] = color(56, 174, 65, 255);
    temp.pixels[2 * temp.width + 1] = color(200, 50, 50, 255);
    temp.pixels[2 * temp.width + 2] = color(224, 211, 36, 255);

    //backgroundcolors
    temp.pixels[3 * temp.width + 0] = color(17, 53, 20, 255);
    temp.pixels[3 * temp.width + 1] = color(19, 19, 19, 255);
    //temp.pixels[3 * temp.width + 1] = color(65, 19, 19, 255);
    temp.pixels[3 * temp.width + 2] = color(102, 96, 14, 255);

    temp.updatePixels();

    temp.save("ColorPalette.png");
}