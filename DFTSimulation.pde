
Knob[] a = new Knob[4];

void setup(){
    size(800,800);

    for(int i = 0; i < a.length; i++){
        a[i] = new Knob(100 + i*200, 400, 50, 50);
    }


}

void draw(){
    background(255, 0, 0);

    for(int i = 0; i < a.length; i++){
        a[i].update();
    }

}