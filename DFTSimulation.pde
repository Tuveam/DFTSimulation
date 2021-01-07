//command+shift+b to run it in vscode
//Anything in here is only testing code and can be deleted


Automation a;

ArrayList<Knob> k = new ArrayList<Knob>();

PlayButton p;
Button b;


boolean iterated = false;

void setup(){
    size(800,800);

    a = new Automation(200, 200, 500, 300);

    k.add(new Knob(50, 100, 50, 50));
    k.add(new Knob(150, 100, 50, 50));

    k.get(0).setColor(color(int(random(255)), int(random(255)), int(random(255))), color(int(random(255)), int(random(255)), int(random(255))), color(int(random(255)), int(random(255)), int(random(255))));

    p = new PlayButton(540, 50, 50, 50);
    b = new Button(600, 50, 50, 50);
}

void draw(){
    background(50, 0, 0);

    a.update();

    p.update();
    b.update();

    for(int i = 0; i < k.size(); i++){
        k.get(i).update();
    }

    noFill();
    stroke(255);
    strokeWeight(2);
    ellipse(width/2, height * a.mapXToY(k.get(0).getValue()), 50, 50);

}

void swap(ArrayList<Knob> in, int index1, int index2){
    Knob temp = in.get(index1);
    in.set(index1, in.get(index2));
    in.set(index2, temp);
}