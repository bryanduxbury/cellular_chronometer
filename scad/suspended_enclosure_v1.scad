// TODO: add front to back screw holes


t = 3;
l = 0.005 * 25.4;

pcb_t = 1.2;
pcb_h = 25;
pcb_w = 100;

cord_r = 4.5/2;

switch_distance_from_center = 25;
switch_height = 8.5;

w = 100+6*t;
h = 50;
d = 2 * (pcb_t / 2 + switch_height + 2 * t);



feet_h = 3;
feet_w = t*2;


function polar(r, theta) = [cos(theta) * r, sin(theta) * r];

module _elipse2d(rx, ry) {
  scale([rx, ry, 1]) circle(r=1);
}

module _triangle(h) {
  assign(opp=tan(30) * h)
  polygon(points=[
    [0, h/2],
    [opp, -h/2],
    [-opp, -h/2]
  ]);
}

module _e() {
  linear_extrude(height=t, center=true) child(0);
}

module _a() {
  color([240/255, 240/255, 240/255, 0.55]) _e() child(0);
}

module _b() {
  color("black") _e() child(0);
}

module pcba_mockup() {
  color("green") {
    cube(size=[pcb_w, pcb_t, pcb_h], center=true);
  }
  for (x=[-1,1]) {
    translate([x * (switch_distance_from_center), pcb_t/2+switch_height/2, 0]) 
      cube(size=[6, switch_height, 6], center=true);
  }
  
  assign(delta = (pcb_w - 5) / 24)
  translate([0, -pcb_t/2 - 1/2, 0]) {
    for (x=[-12:12], y=[-2:2]) {
      translate([x * delta, 0, y * delta]) 
        cube(size=[0.06 * 25.4, 1, 0.120 * 25.4], center=true);
    }
  }
}

module pcba_support() {
  assign(support_d = d-2*t)
  assign(support_h = h-2*t)
  union() {
    difference() {
      square(size=[support_d+l, support_h], center=true);
      square(size=[pcb_t-l, pcb_h-l], center=true);
      for (d=[-1,1]) {
        translate([support_d/2 * d, 0, 0]) 
          _elipse2d((support_d - pcb_t - 2 * t)/2, (support_h - 3*t) / 2, $fn=72);

        translate([0, support_h/2 * d, 0]) 
          _elipse2d((support_d - 2*t)/2-l/2, (support_h - 2*t - pcb_h) / 2, $fn=72);
      }
    }

    for (x=[-1,1], y=[-1,1]) {
      translate([(support_d/2 - t/2) * x, (support_h / 2 + t/2) * y, 0]) 
        square(size=[t+l, t+l], center=true);
    }
  }
}

module _frontback_base() {
  assign(full_w = w + t)
  assign(full_h = h + t)
  difference() {
    hull() {
      for (d=[-1,1]) {
        translate([d * (full_w/2 - t/2), full_h/2-t/2, 0]) circle(r=t/2, $fn=36);
      }
      translate([0, -full_h/2 - feet_h + 1.5, 0]) square(size=[full_w, 3], center=true);
    }

    for (x=[-1,1]) {
      translate([cord_r * x, -full_h/2 - feet_h, 0]) 
        _elipse2d((full_w - feet_w*2 - cord_r*2)/2, feet_h, $fn=120);
    }

    

    for (x=[-1,1], y=[-1,1]) {
      translate([(w/2-t/2) * x, (h/2-2*t-t/2) * y, 0]) 
        square(size=[t-l, t-l], center=true);
      translate([(w/2-4*t-t/2) * x, (h/2-t/2) * y, 0]) 
        square(size=[t-l, t-l], center=true);
    }
  }
}

module front() {
  _frontback_base();
}

module back() {
  assign(full_w = w + t)
  assign(full_h = h + t)
  union() {
    difference() {
      _frontback_base();
      translate([0, -h/2 + t + cord_r, 0]) {
        circle(r=cord_r, $fn=36);
        translate([0, -2*t, 0]) square(size=[cord_r*2, 4*t], center=true);
      }

      // chop the corners of the cord slot so we can round them in a moment
      for (x=[-1,1]) {
        translate([cord_r * x, -full_h/2, 0]) 
          square(size=[t/4*2, t/4*2], center=true);
      }

      translate([switch_distance_from_center, 0, 0]) 
        rotate([0, 0, 180]) _triangle(10);
      translate([-switch_distance_from_center, 0, 0]) 
        rotate([0, 0, 0]) _triangle(10);
    }
    
    // round out the corners of the cord slot
    for (x=[-1,1]) {
      translate([(cord_r + t/4) * x, -full_h/2 + t/4, 0]) 
        circle(r=t/4, $fn=36);
    }
  }
}

module side() {
  assign(base_width = d - 2*t + l)
  difference() {
    union() {
      translate([0, h/4, 0]) square(size=[base_width, h/2], center=true);
      translate([0, -h/2 - t/2 - feet_h + (h/2 + feet_h + t/2) / 2, 0]) 
        square(size=[base_width, h/2 + feet_h + t/2], center=true);

      for (x=[-1,1], y=[-1,1]) {
        translate([((d-2*t)/2) * y, (h/2 - 2 * t - t/2) * x, 0])
          square(size=[2*t+l, t+l], center=true);
      }
    }

    translate([0, h/2, 0]) square(size=[(base_width-2*t)-l, 2*t-l], center=true);
    translate([0, -h/2 + t/2, 0]) square(size=[(base_width-2*t)-l, t-l], center=true);
  }
}

module topbottom() {
  assign(base_height = d - 2 * t + l)
  assign(base_width = w - 2 * t + l)
  difference() {
    union() {
      square(size=[base_width, base_height], center=true);
      for (x=[-1,1], y=[-1,1]) {
        translate([(w/2 - 4 * t - t/2) * x, ((d-2*t)/2) * y, 0]) 
          square(size=[t+l, 2*t+l], center=true);
      }
      for (x=[-1,1]) {
        translate([(w/2-t) * x, 0, 0]) 
          square(size=[2*t+l, (base_height - 2 * t)+l], center=true);
      }
    }

    for (x=[-1,1], y=[-1,1]) {
      translate([(pcb_w/2 + 0.5)*x, (d - 2*t)/2 * y, 0]) 
        square(size=[t-l, 2*t-l], center=true);
    }
    
  }
}

module button_flange() {
  difference() {
    _triangle(10+2);
    circle(r=3.4/2, $fn=36);
  }
  
}

module button() {
  _triangle(10);
}

module _button_assembly() {
  _b() button();
  translate([0, 0, -t]) _a() button_flange();
}

module assembled() {
  pcba_mockup();

  translate([switch_distance_from_center, d/2 - t/2, 0]) 
    rotate([-90, 180, 0]) _button_assembly();
  translate([-switch_distance_from_center, d/2 - t/2, 0]) 
    rotate([-90, 0, 0]) _button_assembly();

  for (x=[-1,1]) {
    translate([(pcb_w / 2 + 0.5) * x, 0, 0]) 
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
