t = 5.2;

led_w = 0.06 * 25.4;
led_h = 0.12 * 25.4;
led_spacing = 4.5; //0.150 * 25.4;
pixel_dim = 3.5;

outside_gutter = 3;

num_rows = 5;
num_cols = 25;

pcb_t = 1.6;

faceplate_hole_d = 0.5;

foot_height = 4;
foot_base_width = 10;
foot_bottom_width = 8;
foot_corner_r = 1.5;
function foot_theta() = sqrt(foot_height*foot_height+(foot_base_width - foot_bottom_width)*(foot_base_width - foot_bottom_width));

function face_width() = num_cols * led_spacing + 2 * outside_gutter;
function face_height() = num_rows * led_spacing + 2 * outside_gutter;

module _led() {
  color([255/255, 0/255, 0/255]) {
    cube(size=[led_w, led_h, 0.01 * 25.4], center=true);
  }
}

module _pcba() {
  color([0/255, 255/255, 0/255]) {
    cube(size=[led_spacing*num_cols, led_spacing*num_rows, pcb_t], center=true);
  }
  translate([0, 0, 0.005 * 25.4 + 1.6/2]) {
    for (x = [-(floor(num_cols/2)):floor(num_cols/2)], y = [-(floor(num_rows/2)):floor(num_rows/2)]) {
      translate([x * led_spacing, y * led_spacing, 0]) _led();
    }
  }
}

module _aa_battery() {
  color("silver")
  union() {
    cylinder(r=14.5/2, h=50.1, center=true);
    translate([0, 0, 50.1/2 + 0.4/2]) cylinder(r=2, h=0.4, center=true);
  }
}

module foot() {
  !assign(dy=foot_corner_r)
  assign(dx=dy/cos(foot_theta())) 
  assign(b = tan(foot_theta()) * dy)
  assign(m_dx = cos(foot_theta()) * foot_corner_r)
  assign(m_dy = sin(foot_theta()) * foot_corner_r)
  {
    echo ("short h", short_h);
    echo("mdx", m_dx);
    echo("mdy", m_dy);
    polygon(points=[
      [0, 0],
      [foot_base_width/2, 0],
      [foot_bottom_width/2 - (dx - b) + m_dx, -foot_height + dy - m_dy],
      [foot_bottom_width/2 - (dx - b), -foot_height],
      [0, -foot_height]
    ]);
    translate([foot_bottom_width/2 - dx + b, -foot_height + dy, 0]) circle(r=foot_corner_r, $fn=72);
  }
}

module baffle() {
  render()
  union() {
    difference() {
      cube(size=[face_width(), face_height(), t], center=true);
      for (x = [-(floor(num_cols/2)):floor(num_cols/2)], y = [-(floor(num_rows/2)):floor(num_rows/2)]) {
        translate([x * led_spacing, y * led_spacing, 0]) cube(size=[pixel_dim, pixel_dim, t*2], center=true);
      }
    }
    translate([0, -face_height()/2, 0]) {
      for (x=[-1,1]) {
        translate([x * face_width() / 3, 0, 0]) linear_extrude(height=t, center=true) foot();
      }
    }
  }
}

module perforated_faceplate() {
  assign(num_holes_h=num_cols * led_spacing / faceplate_hole_d / 2)
  assign(num_holes_v=num_rows * led_spacing / faceplate_hole_d / 2)
  difference() {
    // cube(size=[face_width(), face_height(), t], center=true);
    square(size=[face_width(), face_height()], center=true);

    for (x = [-(floor(num_holes_h/2)):floor(num_holes_h/2)]) {
      translate([x * faceplate_hole_d + (x-1) * faceplate_hole_d + faceplate_hole_d/2, 0, 0]) 
      render()
      for (y = [-(floor(num_holes_v/2)):floor(num_holes_v/2)]) {
        translate([0, y * faceplate_hole_d + (y-1) * faceplate_hole_d + faceplate_hole_d/2, 0]) 
          // cylinder(r=faceplate_hole_d/2, h=t*2, center=true, $fn=36);
          square(size=[faceplate_hole_d, faceplate_hole_d], center=true);
      }
    }
  }
}

module face_locking_ring() {
  difference() {
    cube(size=[face_width()-outside_gutter, face_height()-outside_gutter, t], center=true);
    cube(size=[num_cols * led_spacing, num_rows * led_spacing, t*2], center=true);
  }
}

module tail_locking_ring() {
  color("lavender")
  render()
  difference() {
    cube(size=[face_width(), face_height(), t], center=true);
    cube(size=[face_width()-outside_gutter, face_height()-outside_gutter, t*2], center=true);
  }
}

module tail_body() {
  render()
  difference() {
    cube(size=[face_width(), face_height(), t], center=true);
    cube(size=[face_width()-outside_gutter*2, face_height()-outside_gutter*2, t*2], center=true);
  }
}


module backplate() {
  render()
  difference() {
    cube(size=[face_width(), face_height(), t], center=true);
  }
}

module assembled() {
  translate([0, 0, t]) color([128/255, 128/255, 128/255]) linear_extrude(height=t, center=true) perforated_faceplate();
  baffle();
  translate([0, 0, -t/2 - pcb_t/2]) _pcba();
  translate([0, 0, -t]) color("red") face_locking_ring();

  translate([-25.2, 0, -t/2 - pcb_t - 14.5/2 - 3]) rotate([0, 90, 0]) _aa_battery();
  translate([25.2, 0, -t/2 - pcb_t - 14.5/2 - 3]) rotate([0, 90, 0]) _aa_battery();

  translate([0, 0, -t]) tail_locking_ring();
  translate([0, 0, -2*t]) tail_locking_ring();
  translate([0, 0, -3*t]) tail_locking_ring();
  translate([0, 0, -4*t]) tail_locking_ring();
  // translate([0, 0, -5*t]) % tail_locking_ring();
  // translate([0, 0, -6*t]) % tail_locking_ring();
  // translate([0, 0, -7*t]) % tail_locking_ring();
  
  translate([0, 0, -5*t]) backplate();
}

rotate([90, 0, 0]) assembled();