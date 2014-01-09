// TODO: position supports such that they only use empty space on edges of boards
// TODO: round top corners of front and back
// TODO: create feet for front and back

w = 125;
h = 40;
d = 20;
t = 3;
l = 0.005 * 25.4;


pcb_t = 1.6;
pcb_h = 25;
pcb_w = 100;

module _e() {
  linear_extrude(height=t, center=true) child(0);
}

module _a() {
  color([240/255, 240/255, 240/255, 0.75]) _e() child(0);
}

module pcba_mockup() {
  color("green") {
    cube(size=[pcb_w, pcb_t, pcb_h], center=true);
  }
}

module pcba_support() {
  assign(support_d = d-2*t)
  assign(support_h = h-2*t)
  difference() {
    square(size=[support_d, support_h], center=true);
    square(size=[pcb_t-l, pcb_h-l], center=true);
    for (d=[-1,1]) {
      translate([support_d/2 * d, 0, 0]) 
        scale([(support_d - pcb_t - 2 * t)/2, (support_h - 2*t) / 2, 1]) circle(r=1, $fn=72);

      translate([0, support_h/2 * d, 0]) 
        scale([(support_d - 2*t)/2, (support_h - 2*t - pcb_h) / 2, 1]) circle(r=1, $fn=72);
    }
    
  }
}

module front() {
  square(size=[w+t, h+t], center=true);
}

module back() {
  square(size=[w+t, h+t], center=true);
}

module side() {
  square(size=[d, h], center=true);
}

module topbottom() {
  square(size=[w, d], center=true);
}

module assembled() {
  pcba_mockup();

  for (x=[-1,1]) {
    translate([(pcb_w / 2 - t / 2) * x, 0, 0]) 
      rotate([90, 0, 90]) _a() pcba_support();
    translate([(w/2-t/2) * x, 0, 0]) rotate([90, 0, 90]) _a() side();
  }

  translate([0, -d/2+t/2, 0]) rotate([90, 0, 0]) _a() front();
  translate([0, d/2-t/2, 0]) rotate([90, 0, 180]) _a() back();

  for (z=[-1,1]) {
    translate([0, 0, (h/2-t/2)*z]) _a() topbottom();
  }
  

}

assembled();
