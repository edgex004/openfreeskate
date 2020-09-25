// Lower quality gives faster compile times and a more polygonal shape. Higher qualit adds more smoothly rounded wheel wells.
qualitySelection = 20;  // [1:100]
// Increase or decrease the axle to axle distance between your wheels.
modifyAxleDistance = 0; // [-20:20]
buildTarget = "printed_deck"; // [truck, printed_deck, lazer_cut_deck, bearing_adaptor]
// Trucks/Decks in general are compatible with any brand. Bearing adaptors change size with brand.
wheelBrand = "JMKPerformance"; // [JMKPerformance, TwoLions]
deckBoltSize = "M5"; // [M4, M5]
// Using the "light" option hollows out the interior of the truck. Using this option will use less filament, but only if your printer can print the midsection wihout supports.
light = true;
module build(target){
    rotate([0,-90,0]) {
        if (target == "truck") {
            truck(light);
        } else if (target == "printed_deck") {
            deck(true);
        }
    }
    if (target == "bearing_adaptor") {
        bearing_adaptor();
    } else if (target == "lazer_cut_deck") {
            lazercutdeck(false);
    }
}

build(buildTarget);
 
 
 $quality = qualitySelection/100; // Quality scale 0 to 1. 1 Takes a lot of CPU/RAM to render for now.
 $fn = round(100*$quality);
    //wheel info here
    od=73;
    id=20;
    edge_r=25;
    edge_r_offset=8;
    w=43;
    bearing_to_bearing = ( wheelBrand == "JMKPerformance" ) ? 26.5 : 24.5; // Change this to 26.5 for JMK Performance wheels. Twolions seem to be 24.5.

    //non-wheel
    bolt_head_radius=8;
    wall_thickness=21;
    bolt_wall_thickness=8;
    wheel_gap=3;
    whell_shell_width=10;
    added_wheel_distance=20+modifyAxleDistance;
    wheel_coverage_ratio=.9;
    wheel_coverage_offset=(od/pow(wheel_coverage_ratio,1.55))/8;
    truck_height=wheel_coverage_ratio*od;
   
   wheel_hull_shrink_ratio=.8;
   
    bearing_shell_od=22;
    bearing_shell_id=8.4;
    bearing_shell_w=8;
    
    deck_bolt_size = deckBoltSize; // M4 vs M5 for now.

    use_m4 = deck_bolt_size == "M4";
    use_m5 = deck_bolt_size == "M5";

    assert(use_m4 || use_m5);

    deck_bolt_head_bore_h = use_m4 ? 4 : use_m5 ? 5 : 0;
    deck_bolt_head_bore_r= use_m4 ? 3.5 : use_m5 ? 4.3 : 0; //4.5
    deck_bolt_total_h= use_m4 ? 19.7 : use_m5 ? 20.8 : 0;
    deck_bolt_total_r= use_m4 ? 2 : use_m5 ? 2.5 : 0; //3
    deck_bolt_nut_bore_r= use_m4 ? 4 : use_m5 ? 4.6 : 0; //5.5
    deck_bolt_nut_bore_h= use_m4 ? 3 : use_m5 ? 3.8 : 0;

    deck_bolt_nut_bore_translation=deck_bolt_head_bore_h+10;


    deck_bolt_nut_bore_extra_h=40; //actual h is 3 or 3.8, but this is to go through the whole truck

    deck_w=135;
    deck_h=160;
    deck_angle=15;
    deck_edge_r=40;
    deck_thickness_edge=5;
    deck_thickness=deck_bolt_head_bore_h+5;

    bolt_distance=42;
    bolt_distance_from_center=bolt_distance/2; // JMK bolt distance is 63.7/2 based off https://www.thingiverse.com/thing:4152124.
    // 4 bolt measurements from https://www.thingiverse.com/thing:4152124. bolt distance is 51/2. distance in the horizontal is 78.2 total.

    four_bolt_distance = 51;
    four_bolt_distance_from_center = four_bolt_distance/2;
    four_bolt_width = 78.2;
    four_bolt_width_from_center = four_bolt_width/2;


    platform_interface_size=[w+2*wall_thickness+2*wheel_gap,od+added_wheel_distance+1.7,deck_thickness];
        truck_interface_size=[w+2*wall_thickness+2*wheel_gap,od+added_wheel_distance+40,20];

    truck_interface_thicknes=10;

    bearing_adaptor_od_big = 22;
    bearing_adaptor_od_small = 13;
    bearing_adaptor_width = (w + 2*wheel_gap -  bearing_to_bearing)/2;


module bearing_mock (od = 22, id=8, w=7) {
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

module bearing_washer(width){
    difference(){
        cylinder(r=bearing_adaptor_od_big/2,h=width);
        cylinder(r=bearing_shell_id/2, h=width);
    }
}

module inwheel_spacer(width){
    difference(){
        union(){
            cylinder(r1=bearing_shell_id/2 + 2,r2=bearing_shell_id/2 + 3,h=width/2);
            translate([0,0,width/2])cylinder(r1=bearing_shell_id/2 + 3,r2=bearing_shell_id/2 + 2,h=width/2);
        }
        cylinder(r=(bearing_shell_id/2), h=width);
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
        bearing_mock (od = bearing_shell_od, id=bearing_shell_id, w=bearing_shell_w) ;
        translate ([0,0,w-bearing_shell_w])
            bearing_mock (od = bearing_shell_od, id=bearing_shell_id, w=bearing_shell_w) ;
        cylinder(r=id/2, h=w);
    }
}

module wheels_for_hulling(){
    translate([0,-(od+wheel_gap*2+added_wheel_distance)/2])
    translate([0,0,wall_thickness+wheel_gap])
        wheel_shell(od*wheel_hull_shrink_ratio,w,edge_r,edge_r_offset,true);
    
    translate([0,(od+wheel_gap*2+added_wheel_distance)/2])
    translate([0,0,wall_thickness+wheel_gap])
        wheel_shell(od*wheel_hull_shrink_ratio,w,edge_r,edge_r_offset,true);
}

module tire(){
    
    difference(){
        wheel_shell(od,w,edge_r,edge_r_offset);
        bearing_mock (od = bearing_shell_od, id=bearing_shell_id, w=bearing_shell_w);
        translate ([0,0,w-bearing_shell_w])
            bearing_mock (od = bearing_shell_od, id=bearing_shell_id, w=bearing_shell_w);
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
        cylinder(r=bolt_head_radius, h=wall_thickness-bolt_wall_thickness);
        translate([0,0,w+2*wheel_gap+2*wall_thickness-(wall_thickness-bolt_wall_thickness)])
            cylinder(r=bolt_head_radius, h=wall_thickness-bolt_wall_thickness);
}

module well_shell(){
    wheel_shell(od+wheel_gap*2+whell_shell_width,w+2*wheel_gap+2*wall_thickness,edge_r,edge_r_offset,true);
}


module flying_butrous(hole_scale_z,hole_scale_y=1.3, side_hole_scale=1.5){
    module quarter_flying_butrous(){        
        hull(){
            translate([0,0])
                cube([truck_interface_size[0]/2,truck_interface_size[1]*0.25,truck_interface_size[2]*0.5],center=false);
            translate([0,bolt_distance_from_center-10])
                cube([truck_interface_size[0]*0.5,truck_interface_size[1]*0.5-bolt_distance_from_center,truck_interface_size[2]],center=false);
        }
    }

    difference(){
        union(){
            mirror([0,0,0])
                quarter_flying_butrous();
            mirror([0,1,0])
                quarter_flying_butrous();
            mirror([1,0,0])
            mirror([0,1,0])
                quarter_flying_butrous();
            mirror([1,0,0])
                quarter_flying_butrous();
        }
        sides=12;
        
        scale([hole_scale_z,hole_scale_y,1])
        rotate([0,0,180/sides])
            cylinder(r=bolt_distance_from_center-9,h=100,$fn=sides);
        
        scale([1,side_hole_scale,1])
        translate([0,0,(truck_interface_size[2]/2+bolt_distance_from_center)])
        rotate([0,90,0])
            cylinder(r=bolt_distance_from_center,h=100,$fn=14,center=true);

    }
}
    
    
module truck(lightweight = true){
    module outline(){
        hull(){
            translate([0,-(od+wheel_gap*2+added_wheel_distance)/2])
                truck_half();
            mirror([0,1,0])
            translate([0,-(od+wheel_gap*2+added_wheel_distance)/2])
                truck_half();
        }
    }
    
    intersection(){
        difference(){
            union(){
                intersection(){
                outline();
                    union(){
                        translate([0,-(od+wheel_gap*2+added_wheel_distance)/2])
                            well_shell();
                        mirror([0,1,0])
                        translate([0,-(od+wheel_gap*2+added_wheel_distance)/2])
                            well_shell();
        
                        translate([-40,0,truck_interface_size[0]/2])
                        rotate([0,-90,0])
                        mirror([0,0,1])
                            flying_butrous(3.4,1.8);
                        
                        translate([23,0,truck_interface_size[0]/2])
                        rotate([0,-90,0]) {
                            flying_butrous(1.7,1.3,0.3);
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
                union(){
                    difference(){
                        hull(){
                            translate([hull_translate,-(od+wheel_gap*2+added_wheel_distance)/2,wall_thickness])
                                wheel_shell(hull_od,w+wheel_gap*2,hull_edge_r,hull_edge_offset);
                            mirror([0,1,0])
                            translate([hull_translate,-(od+wheel_gap*2+added_wheel_distance)/2,wall_thickness])
                                wheel_shell(hull_od,w+wheel_gap*2,hull_edge_r,hull_edge_offset);
                        }
                        // HACKITY HACK DON'T TALK BACK
                        // Clean up these magic numbers.
                        translate([-15,-100,0])
                            cube([100,200,400]);
                    }
                    difference(){
                        {
                            intersect_amount=18;
                            translate([-15,0,wall_thickness+wheel_gap+w/2])
                            scale([intersect_amount/9.0,1,(w/2+wheel_gap)/(w/2+wheel_gap-intersect_amount)])
                            intersection(){
                                translate([0,0,intersect_amount])
                                rotate([90,0,0]) 
                                    cylinder(h=200, r=(w/2+wheel_gap),center=true,$fn=40);
                                
                                translate([0,0,-intersect_amount])
                                rotate([90,0,0])
                                    cylinder(h=200, r=(w/2+wheel_gap),center=true,$fn=40);
                            }
                        }
                        mirror([1,0,0])
                        translate([16,-100,0])
                            cube([100,200,400]);
                        
                        translate([18,-100,0])
                            cube([100,200,400]);
                    }
                }
            }

            translate([0,-(od+wheel_gap*2+added_wheel_distance)/2])
                well();
            mirror([0,1,0])
            translate([0,-(od+wheel_gap*2+added_wheel_distance)/2])
                well();

            
            deck(false);
            four_deckbolts();
            run = 40 + bolt_head_radius;
            rise = wall_thickness-bolt_wall_thickness;
            slope = rise/run;
            slope1 = slope/1.6;
            slope2 = 2*slope;
            length = 100;
            anglelength = 20;


            height_offset=5+deck_bolt_head_bore_h/3;
            shift_to_deck= 40;

            translate([0,100])
            rotate([90])
            linear_extrude(height=200)
                polygon( points=[[-shift_to_deck+height_offset,0],[length-shift_to_deck,0],[length-shift_to_deck,length*slope1],[anglelength-shift_to_deck,anglelength*slope2]] );

            mirror([0,0,1])
            translate([0,100,-(w+2*wheel_gap+2*wall_thickness)])
            rotate([90])
            linear_extrude(height=200)
                polygon( points=[[-shift_to_deck+height_offset,0],[length-shift_to_deck,0],[length-shift_to_deck,length*slope1],[anglelength-shift_to_deck,anglelength*slope2]] );
        }
            
        hull(){
            deck(false,false,true);
            wheels_for_hulling();
        }
        minimum_necessary_area_for_strength();
    }
}
    
    
module unmirrored_deck(shrunk = false){
    trans_x=deck_h/2-deck_edge_r;
    trans_y=shrunk ? deck_w/3-deck_edge_r : deck_w/2-deck_edge_r;
    hull(){
        translate([0,0,deck_thickness/2])
        rotate([0,0,deck_angle])
            cube(platform_interface_size,center=true);
        translate([trans_x,trans_y])
            cylinder(r=deck_edge_r,h=deck_thickness_edge);
        translate([-trans_x,trans_y])
            cylinder(r=deck_edge_r,h=deck_thickness_edge);
        translate([-trans_x,-trans_y])
            cylinder(r=deck_edge_r,h=deck_thickness_edge);
        translate([trans_x,-trans_y])
            cylinder(r=deck_edge_r,h=deck_thickness_edge);
        }
    }
        
module deck(add_bore=true,add_angle=true,shrunk = false){
       
    difference(){
        translate([-od/2-wheel_gap-deck_thickness,0,wall_thickness+wheel_gap+w/2])
        rotate([0,90,0])
                rotate([0,0,add_angle?deck_angle:0])
        union(){
            unmirrored_deck(shrunk);
            mirror([0,1,0])
                unmirrored_deck(shrunk);
        }
            
        if(add_bore) {
            // deckbolts(true);
            four_deckbolts(true);
        }
    }
}



module deckbolt(just_head=false, additional_r=0){
    color("green")
    rotate([0,90,0]) 
    union(){
        cylinder(r=deck_bolt_head_bore_r+additional_r,h=deck_bolt_head_bore_h);            
        if (!just_head){
            cylinder(r=deck_bolt_total_r+additional_r,h=deck_bolt_total_h);
            translate([0,0,deck_bolt_nut_bore_translation])
                cylinder(r=deck_bolt_nut_bore_r+additional_r,h=deck_bolt_nut_bore_h+deck_bolt_nut_bore_extra_h,$fn=6);
        }
    }
}
    
module deckbolts(add_mirror=false){
    translate([-od/2-wheel_gap-deck_thickness,bolt_distance_from_center,wall_thickness+wheel_gap+w/2])
        deckbolt();
    
    translate([-od/2-wheel_gap-deck_thickness,-bolt_distance_from_center,wall_thickness+wheel_gap+w/2])
        deckbolt();
    if (add_mirror){
        translate([0,0,wall_thickness+wheel_gap+w/2])
        rotate([deck_angle*2]){
            translate([-od/2-wheel_gap-deck_thickness,bolt_distance_from_center])
                deckbolt();
            translate([-od/2-wheel_gap-deck_thickness,-bolt_distance_from_center])
                deckbolt();
        }
    }                             
}
    
module four_deckbolts(add_mirror=false, additional_r=0, just_head=false, width_offset=0){
    module twobolts(){
        translate([-od/2-wheel_gap-deck_thickness,four_bolt_distance_from_center])
            deckbolt(just_head,additional_r);

        translate([-od/2-wheel_gap-deck_thickness,-four_bolt_distance_from_center])
            deckbolt(just_head,additional_r);
    }

    translate([0,0,wall_thickness+wheel_gap+w/2]){
    translate ([0,0,four_bolt_width_from_center+width_offset]) 
        twobolts();
    translate ([0,0,-four_bolt_width_from_center-width_offset]) 
        twobolts();

        if (add_mirror){
            rotate([deck_angle*2]){
                translate ([0,0,four_bolt_width_from_center+width_offset]) 
                    twobolts();
                translate ([0,0,-four_bolt_width_from_center-width_offset]) 
                    twobolts();
            }
        }
    }
}
    
module minimum_necessary_area_for_strength(){
    difference(){
        hull(){
            radius=8;
            four_deckbolts(false, radius, false, radius-4);
            wheels_for_hulling();
        }
        deck(false,false,true);
    }
}

module lazercutdeck(include_bolt_head_bore=false){
    difference(){

    projection(cut = false)
    rotate([0,-90,0])
    {
        deck(!include_bolt_head_bore);
        // truck(true);
        // four_deckbolts();
    }
    if(include_bolt_head_bore){
        projection(cut = false)
        rotate([0,-90,0])
        four_deckbolts(true,0,include_bolt_head_bore); 
    }
    

    }
}