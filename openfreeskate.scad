// Check this option to rotate the parts for optimal print orientation. Some parts cannot be printed as a signle part.
rotateForPrint = true;
// Lower quality gives faster compile times and a more polygonal shape. Higher qualit adds more smoothly rounded wheel wells.
qualitySelection = 10;  // [1:100]
// Trucks/Decks in general are compatible with any brand. Bearing adaptors and wheels change size with brand.
wheelBrand = "JMKPerformance"; // [JMKPerformance, TwoLions]
deckBoltSize = "M5"; // [None, M4, M5]
// Using the "light" option hollows out the interior of the truck. Using this option will use less filament, but only if your printer can print the midsection wihout supports.
light = true;
// Mirror the parts in the direction of the y axis
mirrorParts = false;
// Wheel diameter affects both the trucks and the wheels. If you bump your wheel diameter up to the max, the trucks will adjust to fit the wheels.
Wheel_Diameter = 73; // [65:90]
// Increase or decrease the axle to axle distance of the truck. With the default settings, the total distance comes to about 99mm (compare to 103mm on JMK). Axle to axle distance is calculated as : Wheel_Diameter + Added_Axle_Distance + Gap (so wheels never hit each other even with Added_Axle_Distance of 0)
Added_Axle_Distance = 20; // [0:40]

/* [Wheel] */
showWheel = false;
wheel_type = "OnePiece"; // [OnePiece, TwoPiece_hub, TwoPiece_tire]
// Only affects two-piece wheels. Gap between hub and tire (in 1/10 mm).
tireHubGap = 0; // [0:20]
// Only affects two-piece wheels. Hub size (in mm).
hubDiameter = 40; // [30:60]
// Only affects two-piece wheels. Depth of the lip that holds the tire on (in 1/10 mm).
hubLipDepth = 30; // [0:100]
// Only affects two-piece wheels. Wdth of the lip that holds the tire on (in 1/10 mm).
hubLipBase = 70; // [0:200]
// Only affects two-piece wheels. Wdth of the lip that holds the tire on (in 1/10 mm).
hubLipTip = 30; // [0:200]
// Only affects two-piece wheels. Wdth of the lip that holds the tire on (in 1/10 mm).
numHubLips = 2; // [0:4]
// Controls how much extra space there is between the hub lips and the edge of the hub.
hubEdgePercent = 150; // [0:200]

/* [Deck] */
showPrintedDeck = false;
showLaserDeck = false;
// Laser cut deck only. Widens the holes in order to cut a counterbore for bolt heads.
Counter_Bore=false;
Deck_Width=135; // [50:200]
Deck_Height=160; // [50:200]
Toe_Heel_Edge_Radius=40; // [1:100]
Sides_Edge_Radius=40; // [1:100]
Added_Arch_Bump_Width=0; // [-20:20]
Added_Arch_Bump_Height=0; // [-20:20]
/* [Truck] */
showTruck = false;
/* [Bearing Adaptor] */
showBearingAdaptor = false;

module print_build(){
    rotate([0,-90,0]) {
        if (showTruck)
            truck(light);
        if (showPrintedDeck)
            deck(make_bolt_cuts);
    }
    if (showBearingAdaptor)
        bearing_adaptor();
    if (showLaserDeck)
        lazercutdeck(Counter_Bore);
    if (showWheel){
        if(wheel_type=="OnePiece")
            one_piece_wheel();
        else if (wheel_type=="TwoPiece_hub")
            wheel_hub();
        else if (wheel_type=="TwoPiece_tire")
            wheel_tire();
    }
}

module assembled_build(target){
    if (showTruck)
        truck(light);
    if (showPrintedDeck)
        deck(true);
    if (showBearingAdaptor)
        bearing_adaptor();
    if (showLaserDeck)
        lazercutdeck(false);
    if (showWheel)
        move_to_well_locations() translate([0,0,wheel_gap])
            if(wheel_type=="OnePiece")
                one_piece_wheel();
            else if (wheel_type=="TwoPiece_hub")
                wheel_hub();
            else if (wheel_type=="TwoPiece_tire")
                wheel_tire();
}

function btoi(input) = input ? 1 : 0;
multipe_parts = (btoi(showPrintedDeck) + btoi(showLaserDeck) + btoi(showTruck) + btoi(showWheel) + btoi(showBearingAdaptor)) > 1;
deck_and_truck_only = !(showLaserDeck || showWheel || showBearingAdaptor);
can_print = !rotateForPrint || ( deck_and_truck_only || !multipe_parts);

assert(can_print, "Only the truck + deck may be printed together as a single part.");

if (showPrintedDeck||showLaserDeck) {
    assert((Toe_Heel_Edge_Radius < Deck_Width / 2), "Toe Edge radius for deck must be less than half the width.");
    assert((Sides_Edge_Radius < Deck_Height / 2), "Side Edge radius for deck must be less than half the height.");
}


if (rotateForPrint)
    if (mirrorParts)
        mirror([0,1,0])
            print_build();
    else
        print_build();

else
    if (mirrorParts)
        mirror([0,1,0])
            assembled_build();
    else
        assembled_build();
 
 
 $quality = qualitySelection/100; // Quality scale 0 to 1. 1 Takes a lot of CPU/RAM to render for now.
 $fn = round(100*$quality);
    //wheel info here
    od=Wheel_Diameter;
    id=20;
    edge_r=25;
    edge_r_offset=8;
    w=43;
    bearing_to_bearing = ( wheelBrand == "JMKPerformance" ) ? 26.5 : 24.5; // Change this to 26.5 for JMK Performance wheels. Twolions seem to be 24.5.
    tireHubGap_mm = tireHubGap / 10.0;
    hubLipDepth_mm = hubLipDepth / 10.0;
    // hubLipWidth_mm = hubLipWidth / 10.0;
    hubLipBase_mm = hubLipBase / 10.0;
    hubLipTip_mm = hubLipTip / 10.0;
    hubEdgeRatio = hubEdgePercent /100.0;
    wheel_overhang = (w-bearing_to_bearing)/2;

    //non-wheel
    bolt_head_radius=8;
    wall_thickness=21;
    bolt_wall_thickness=8;
    wheel_gap=3;
    whell_shell_width=10;
    added_wheel_distance=Added_Axle_Distance;
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
    make_bolt_cuts = use_m4 || use_m5;

    // assert(use_m4 || use_m5);

    deck_bolt_head_bore_h = use_m4 ? 4 : use_m5 ? 5 : 5;
    deck_bolt_head_bore_r= use_m4 ? 3.5 : use_m5 ? 4.3 : 4.3;
    deck_bolt_total_h= use_m4 ? 19.7 : use_m5 ? 20.8 : 20.8;
    deck_bolt_total_r= use_m4 ? 2 : use_m5 ? 2.5 : 2.5;
    deck_bolt_nut_bore_r= use_m4 ? 4 : use_m5 ? 4.6 : 4.6;
    deck_bolt_nut_bore_h= use_m4 ? 3 : use_m5 ? 3.8 : 3.8;

    deck_bolt_nut_bore_translation=deck_bolt_head_bore_h+10;


    deck_bolt_nut_bore_extra_h=40; //actual h is 3 or 3.8, but this is to go through the whole truck

    deck_angle=15;
    deck_edge_r_x=Sides_Edge_Radius;
    deck_edge_r_y=Toe_Heel_Edge_Radius;
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

module bearing_bore (bigod, overhang, od = 22, id=8, w=7) {
    echo(bigod);
    echo(od);
    union(){
    cylinder(r1=bigod/2, r2=od/2, h=overhang);
    translate([0,0,overhang])
        cylinder(r=od/2, h=w);
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

 module bore_for_axle_and_bearings(){
     bearing_bore (bigod = (od + bearing_shell_od )/2, overhang=wheel_overhang, od = bearing_shell_od, id=bearing_shell_id, w=bearing_shell_w) ;
        translate ([0,0,w]) mirror([0,0,1])
            bearing_bore (bigod = (od + bearing_shell_od )/2 , overhang=wheel_overhang, od = bearing_shell_od, id=bearing_shell_id, w=bearing_shell_w) ;
        cylinder(r=id/2, h=w);
 }



module wheel_hub(add_bore = true, extra_gap = 0.0) {
    difference(){
        translate([0,0,wheel_overhang])
        union(){
            translate([0,0, -extra_gap])
            cylinder(r=(hubDiameter+extra_gap)/2, h=bearing_to_bearing + extra_gap);
                                poly_shift = (hubLipBase_mm-hubLipTip_mm)/2;
            if (numHubLips > 1){
                for ( i = [1 : numHubLips] ) {
                    max_edge_lip = bearing_to_bearing/(numHubLips + 1)-hubLipBase_mm/2;
                    tip_to_tip = (bearing_to_bearing-hubLipBase_mm-max_edge_lip*hubEdgeRatio)/(numHubLips-1);
                    min_tip_to_tip = (bearing_to_bearing-hubLipBase_mm)/(numHubLips+1);
                    translate([0,0,tip_to_tip*(i-1)+hubEdgeRatio*(max_edge_lip)/2])

                    rotate_extrude()
                    translate([hubDiameter/2, 0, 0])
                    polygon(points=[[-.1,-extra_gap], [-.1,hubLipBase_mm+extra_gap], [hubLipDepth_mm+extra_gap,poly_shift+hubLipTip_mm+extra_gap], [hubLipDepth_mm+extra_gap,poly_shift-extra_gap]]);
                }
        
            } else {
                    translate([0,0,(bearing_to_bearing-hubLipBase_mm)/2])
                    rotate_extrude()
                    translate([hubDiameter/2, 0, 0])
                    polygon(points=[[-.1,-extra_gap], [-.1,hubLipBase_mm+extra_gap], [hubLipDepth_mm+extra_gap,poly_shift+hubLipTip_mm+extra_gap], [hubLipDepth_mm+extra_gap,poly_shift-extra_gap]]);
            }
        }
        if(add_bore) bore_for_axle_and_bearings();
    }
}

module space_for_wheel_hub() {
        union(){
            translate([0,0,-.1])
                cylinder(r=(hubDiameter+tireHubGap_mm)/2, h= w + 2*.1);
            wheel_hub(false, tireHubGap_mm);
        }
}

module wheel_tire() {
    difference(){
        wheel_shell(od,w,edge_r,edge_r_offset);
        space_for_wheel_hub();
    }
}

module move_to_well_locations(){
            translate([0,-(od+wheel_gap*2+added_wheel_distance)/2,wall_thickness])
                children();
            mirror([0,1,0])
            translate([0,-(od+wheel_gap*2+added_wheel_distance)/2,wall_thickness])
                children();
};

module one_piece_wheel(){
    difference(){
        wheel_shell(od,w,edge_r,edge_r_offset);
        bore_for_axle_and_bearings();
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
        
        wheel_shell(od+wheel_gap*2,w+2*wheel_gap,10,0);
        translate([0,0,-wall_thickness])
        cylinder(r=bearing_shell_id/2, h=w+2*wheel_gap+2*wall_thickness);
        translate([0,0,-wall_thickness])
        cylinder(r=bolt_head_radius, h=wall_thickness-bolt_wall_thickness);
        translate([0,0,w+2*wheel_gap+wall_thickness-(wall_thickness-bolt_wall_thickness)])
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


            move_to_well_locations()
                well();

            deck(false);
            if(make_bolt_cuts)
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
    
module oval(w,h, height, center = false) {
 scale([1, h/w, 1]) cylinder(h=height, r=w, center=center);
}

module unmirrored_deck(shrunk = false){
    trans_x=Deck_Height/2-deck_edge_r_x;
    trans_y=shrunk ? Deck_Width/3-deck_edge_r_y : Deck_Width/2-deck_edge_r_y;
    hull(){
        translate([0,0,deck_thickness/2])
        rotate([0,0,deck_angle])
            cube(platform_interface_size,center=true);
        translate([trans_x,trans_y])
            oval(w=deck_edge_r_x,h=deck_edge_r_y,height=deck_thickness_edge);
        translate([-trans_x,trans_y])
            oval(w=deck_edge_r_x,h=deck_edge_r_y,height=deck_thickness_edge);
        translate([-trans_x,-trans_y])
            oval(w=deck_edge_r_x,h=deck_edge_r_y,height=deck_thickness_edge);
        translate([trans_x,-trans_y])
            oval(w=deck_edge_r_x,h=deck_edge_r_y,height=deck_thickness_edge);
        intersection(){
            oval(w=(Deck_Height+Added_Arch_Bump_Height)/2,h=(Deck_Width+Added_Arch_Bump_Width)/2,height=deck_thickness_edge);
            translate([0,0,deck_thickness_edge/2])
                cube([Deck_Width+Added_Arch_Bump_Width,Deck_Height,deck_thickness_edge], center=true);
        }
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