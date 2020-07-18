 $quality = 1; // Quality scale 0 to 1. 1 Takes a lot of CPU/RAM to render for now.
 $fn = round(100*$quality);
    //wheel info here
    od=73;
    id=20;
    edge_r=25;
    edge_r_offset=8;
    w=43;
    bearing_to_bearing=26.5; // Change this if not using JMK Performance wheels.

    //non-wheel
    wall_thickness=8;
    wheel_gap=3;
    whell_shell_width=10;
    added_wheel_distance=20;
    wheel_coverage_ratio=.9;
    wheel_coverage_offset=(od/pow(wheel_coverage_ratio,1.55))/8;
    truck_height=wheel_coverage_ratio*od;
   
   wheel_hull_shrink_ratio=.8;
   
    bearing_shell_od=22;
    bearing_shell_id=8.4;
    bearing_shell_w=8;
    
    deck_w=135;
    deck_h=160;
    deck_angle=15;
    deck_edge_r=40;
    deck_thickness_edge=5;
    deck_thickness=9;

    deck_bolt_head_bore_h=4;
    deck_bolt_head_bore_r=3.5;
    deck_bolt_total_h=18;
    deck_bolt_total_r=2;
    deck_bolt_nut_bore_r=4;
    deck_bolt_nut_bore_h=3;

    deck_bolt_nut_bore_extra_h=10; //actual h is 3, but this is to go through the whole truck
    
    bolt_distance=21;


    platform_interface_size=[w+2*wall_thickness+2*wheel_gap,od+added_wheel_distance+1.7,deck_thickness];
        truck_interface_size=[w+2*wall_thickness+2*wheel_gap,od+added_wheel_distance+40,20];

    truck_interface_thicknes=10;

    bearing_adaptor_od_big = 22;
    bearing_adaptor_od_small = 13;
    bearing_adaptor_width = (w + 2*wheel_gap -  bearing_to_bearing)/2;

module bearing (od = 22, id=8, w=7) {
    
    difference(){
        cylinder(r=od/2, h=w);
        cylinder(r=id/2, h=w);
        }
}

module bearing_adaptor(){
    difference(){
        cylinder(r1=bearing_adaptor_od_big/2,r2=bearing_adaptor_od_small/2,h=bearing_adaptor_width);
        cylinder(r=bearing_shell_id/2, h=bearing_adaptor_width);
    }
}

module edge(od,edge_r,low_poly=false){
    translate ([0,0,edge_r])
    rotate_extrude(convexity = 10, $fn = low_poly?13:round(500*$quality))
    intersection(){
        translate([0,-(od)/2])
            square([od/2,od]);
        translate([od/2-edge_r, 0, 0])
            circle(r = edge_r);
    }
}

module wheel_shell(od,w,edge_r,edge_r_offset,low_poly=false){
    intersection(){
        cylinder(r=od/2, h=w);
    hull(){
        translate ([0,0,-edge_r_offset])edge(od,edge_r,low_poly);
        translate ([0,0,edge_r_offset+w-2*edge_r]) edge(od,edge_r,low_poly);
    }
}
    }

module wheel(){
    
    difference(){
        wheel_shell(od,w,edge_r,edge_r_offset);
    bearing (od = bearing_shell_od, id=bearing_shell_id, w=bearing_shell_w) ;
    translate ([0,0,w-bearing_shell_w])bearing (od = bearing_shell_od, id=bearing_shell_id, w=bearing_shell_w) ;
    
    cylinder(r=id/2, h=w);
}
}

module tire(){
    
    difference(){
        wheel_shell(od,w,edge_r,edge_r_offset);
    bearing (od = bearing_shell_od, id=bearing_shell_id, w=bearing_shell_w) ;
    translate ([0,0,w-bearing_shell_w])bearing (od = bearing_shell_od, id=bearing_shell_id, w=bearing_shell_w) ;
    
    cylinder(r=(od*3/4)/2, h=w);
}
}

module truck_half() {
     
    translate([-wheel_coverage_offset,wheel_coverage_offset,0])    
        cylinder(r=(truck_height/2), h=w+2*wall_thickness+2*wheel_gap, $fn=6);

}

module well(){
        translate([0,0,wall_thickness])
    wheel_shell(od+wheel_gap*2,w+2*wheel_gap,10,0);
        cylinder(r=bearing_shell_id/2, h=w+2*wheel_gap+2*wall_thickness);

}

module well_shell(){
    wheel_shell(od+wheel_gap*2+whell_shell_width,w+2*wheel_gap+2*wall_thickness,edge_r,edge_r_offset,true);
}


module flying_butrous(hole_scale){
    module quarter_flying_butrous(){        
//        hull(){
//        translate([(truck_interface_size[0])/2-wall_thickness,0])
//        cube([wall_thickness,truck_interface_size[1]*0.25,truck_interface_size[2]*0.5],center=false);
//        translate([0,bolt_distance-5])
//        cube([truck_interface_size[0]*0.5,truck_interface_size[1]*0.5-bolt_distance+5,truck_interface_size[2]],center=false);
//        }
        hull(){
        translate([0,0])
        cube([truck_interface_size[0]/2,truck_interface_size[1]*0.25,truck_interface_size[2]*0.5],center=false);
        translate([0,bolt_distance])
        cube([truck_interface_size[0]*0.5,truck_interface_size[1]*0.5-bolt_distance,truck_interface_size[2]],center=false);
        }
        }
        difference(){
            union(){
    mirror([0,0,0])quarter_flying_butrous();
    mirror([0,1,0])quarter_flying_butrous();
    mirror([1,0,0])mirror([0,1,0])quarter_flying_butrous();
    mirror([1,0,0])quarter_flying_butrous();
            }
            sides=12;
            scale([hole_scale,1.3,1])rotate([0,0,180/sides])cylinder(r=bolt_distance-9,h=100,$fn=sides);
            scale([1,1.5,1])translate([0,0,(truck_interface_size[2]/2+bolt_distance)])rotate([0,90,0])cylinder(r=bolt_distance,h=100,$fn=14,center=true);

        }

    }
    
    
module truck(lightweight = false){
    module outline(){
        hull(){
    translate([0,-(od+wheel_gap*2+added_wheel_distance)/2])truck_half();
    mirror([0,1,0])translate([0,-(od+wheel_gap*2+added_wheel_distance)/2])truck_half();
            }
        }
//    translate([0,-(od+wheel_gap*2)/2])truck_half();
//    mirror([0,1,0])translate([0,-(od+wheel_gap*2)/2])truck_half();
    
    intersection(){
        difference(){
            union(){
            intersection(){
            outline();
            union(){
    translate([0,-(od+wheel_gap*2+added_wheel_distance)/2])well_shell();
    mirror([0,1,0])translate([0,-(od+wheel_gap*2+added_wheel_distance)/2])well_shell();
//                   translate([-40,-50,wall_thickness/2]) HexMesh(50,100,9,wall_thickness,1);
//                   translate([-40,-50,w+2*wheel_gap+2*wall_thickness-wall_thickness/2]) HexMesh(50,100,9,wall_thickness,1);

//    translate([-33,0,truck_interface_size[0]/2])rotate([0,-90,0])
//        difference(){
//       cube(truck_interface_size,center=true);
//       cube([w,(bolt_distance-wall_thickness)*2,20],center=true);
//        }
        
                translate([-40,0,truck_interface_size[0]/2])rotate([0,-90,0])
        mirror([0,0,1])flying_butrous(2);
    translate([23,0,truck_interface_size[0]/2])rotate([0,-90,0]){
        flying_butrous(1.7);
//        //this adds a plate on the bottom for grinding
//        translate(-[truck_interface_size[0]/2,truck_interface_size[1]/2])cube([truck_interface_size[0],truck_interface_size[1],truck_interface_size[2]/2]);
        }
        
    }

}
}
            if (lightweight) {
                hull_od = 45;
                hull_translate = -od/2 -wheel_gap + hull_od/2+truck_interface_thicknes;
                hull_edge_r = edge_r;
                hull_edge_offset = edge_r_offset/2;
                hull(){
                    translate([hull_translate,-(od+wheel_gap*2+added_wheel_distance)/2,wall_thickness])wheel_shell(hull_od,w+wheel_gap*2,hull_edge_r,hull_edge_offset);
                    mirror([0,1,0])translate([hull_translate,-(od+wheel_gap*2+added_wheel_distance)/2,wall_thickness])wheel_shell(hull_od,w+wheel_gap*2,hull_edge_r,hull_edge_offset);
                } 
            }

            translate([0,-(od+wheel_gap*2+added_wheel_distance)/2])well();
            mirror([0,1,0])translate([0,-(od+wheel_gap*2+added_wheel_distance)/2])well();

            
            deck(false);
            deckbolts();

    }
    
    hull(){
        deck(false,false,true);
    translate([0,-(od+wheel_gap*2+added_wheel_distance)/2])
            translate([0,0,wall_thickness+wheel_gap])

    wheel_shell(od*wheel_hull_shrink_ratio,w,edge_r,edge_r_offset,true);
            translate([0,(od+wheel_gap*2+added_wheel_distance)/2])
            translate([0,0,wall_thickness+wheel_gap])

    wheel_shell(od*wheel_hull_shrink_ratio,w,edge_r,edge_r_offset,true);
    }
}
    }
    
    
    module unmirrored_deck(shrunk = false){
                trans_x=deck_h/2-deck_edge_r;
        trans_y=shrunk ? deck_w/3-deck_edge_r : deck_w/2-deck_edge_r;
               hull(){
            translate([0,0,deck_thickness/2])
            rotate([0,0,deck_angle])cube(platform_interface_size,center=true);
        translate([trans_x,trans_y])cylinder(r=deck_edge_r,h=deck_thickness_edge);
        translate([-trans_x,trans_y])cylinder(r=deck_edge_r,h=deck_thickness_edge);
        translate([-trans_x,-trans_y])cylinder(r=deck_edge_r,h=deck_thickness_edge);
        translate([trans_x,-trans_y])cylinder(r=deck_edge_r,h=deck_thickness_edge);
        }
        }
        
    module deck(add_bore=true,add_angle=true,shrunk = false){
       
difference(){

        
        translate([-od/2-wheel_gap-deck_thickness,0,wall_thickness+wheel_gap+w/2])
        rotate([0,90,0])
                rotate([0,0,add_angle?deck_angle:0])
    union()
 {unmirrored_deck(shrunk);
     mirror([0,1,0])unmirrored_deck(shrunk);
     }
        
        if(add_bore)
        deckbolts(true);
        }
    }



module deckbolt(){
    color("green")
       rotate([0,90,0]) 
    union(){
    cylinder(r=deck_bolt_total_r,h=deck_bolt_total_h);
    cylinder(r=deck_bolt_head_bore_r,h=deck_bolt_head_bore_h);
    translate([0,0,deck_bolt_total_h-deck_bolt_nut_bore_h])cylinder(r=deck_bolt_nut_bore_r,h=deck_bolt_nut_bore_h+deck_bolt_nut_bore_extra_h,$fn=6);
    }
    }
    
module deckbolts(add_mirror=false){
            translate([-od/2-wheel_gap-deck_thickness,bolt_distance,wall_thickness+wheel_gap+w/2])
    deckbolt();
    
                translate([-od/2-wheel_gap-deck_thickness,-bolt_distance,wall_thickness+wheel_gap+w/2])
    deckbolt();
    if (add_mirror)
                                    translate([0,0,wall_thickness+wheel_gap+w/2])
                rotate([deck_angle*2]){
                                translate([-od/2-wheel_gap-deck_thickness,bolt_distance])
    deckbolt();
    
                translate([-od/2-wheel_gap-deck_thickness,-bolt_distance])
    deckbolt();
                }

    }
    
    
    
    module Hexagon(AF, height)
{ 
  //Hexagon with across flats size
  boxWidth = AF/1.75;
  for (r = [-90, -30, 30]) rotate([0,0,r]) cube([boxWidth, AF, height], true);

}

module HexCell(AF,height,wall)
{
	difference()
	{
		Hexagon(AF,height);
		translate([0,0,-1]){
		Hexagon(AF-2*wall,height+4);
		}
	}
}

module HexMesh(length,width,AF,height,wall)
{
	union(){
		xStep = AF-wall;
		yStep = AF-wall-wall;
		for (x = [1:xStep:length]){
			for (y = [1:yStep:width]){
				translate([x+(((y/yStep) % 2)*((AF/2))),y,0]) {
					HexCell(AF,height,wall);
				}
			}
		}
	}
}

    
    
// deck();
truck(true);
// bearing_adaptor();

