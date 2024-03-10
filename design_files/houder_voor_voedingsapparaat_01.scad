$fn = 150;

include <lasercut.scad>; 

triplex = 0;
thickness = 3.1; // Assuming hardboard
if (triplex == 1) { 
    thickness = 3.0; // For triplex.
} 

x = 180;
y = 60;
diepte = 35;

// Als je ipv finger_joints bumpy_finger_joints gebruikt,
// krijgen de vingers een klein uitsteeksel dat vermoedelijk een ietwat
// klemmende verbinding oplevert.

module onderkant() {
    lasercutoutSquare(thickness=thickness, x=x, y=diepte,
        finger_joints=[
                [UP,    1, 8],
                [DOWN,  1, 8],
                [LEFT,  1, 2],
                [RIGHT, 1, 2]
            ]
    );
}

// Afstand tussen center van boorgaten
afstand_tussen_boorgaten = 94.5;
boorgat_diameter = 3.2;
boorgat_radius = boorgat_diameter / 2;
// Centreer de boorgaten.
boorgat_afstand_tot_zijrand = x / 2 - afstand_tussen_boorgaten / 2 - boorgat_radius + thickness / 2;
boorgat_afstand_tot_onderrand = y - 3 * boorgat_radius;

module boorgaten() {
    translate([boorgat_afstand_tot_zijrand, boorgat_afstand_tot_onderrand, 0]) {
        linear_extrude(thickness) circle(boorgat_radius);
    }
    translate([boorgat_afstand_tot_zijrand + afstand_tussen_boorgaten, boorgat_afstand_tot_onderrand, 0]) {
        linear_extrude(thickness) {
            circle(boorgat_radius);
        }
    }
} 

module achterkant() {
    difference() {
        lasercutoutSquare(thickness=thickness, x=x, y=y,
            finger_joints=[
                    [DOWN,  1, 8],
                    [LEFT,  1, 3],
                    [RIGHT, 1, 3]
                ]
        );
        #boorgaten();
    }
}

// Aan de rechterkant wordt de laagspanningsvoedingslijn naar 
// buiten geleid via een sleuf en een gat.
kabeldoorlaat_diameter = thickness * 2;

// Aan de linkerkant zijn een sleuf en een gat om het platte netsnoer naar 
// binnen te leiden.
linker_zijkant_hoogte = y / 2;
rechter_zijkant_hoogte = y / 5;
voorkant_hoogte = 15;
kabeldikte = 4;
module linker_zijkant(x) {
    lasercutoutSquare(thickness=thickness, x=x, y=diepte, 
            bumpy_finger_joints=[
                [UP,    1, 3],
                [DOWN,  1, 1],
                [RIGHT, 1, 2]
            ],
            circles_remove=[
                [kabeldoorlaat_diameter, x / 2, diepte / 2],
            ],
            cutouts = [
                [x/2 - kabeldikte / 2, -diepte / 2, kabeldikte, 30],
            ]
        );
}

module rechter_zijkant(x) {
    difference() {
        lasercutoutSquare(thickness=thickness, x=x, y=diepte, 
                bumpy_finger_joints=[
                    [UP,   1, 3],
                    [DOWN, 0, 1],
                    [LEFT, 1, 2],
                ],
                circles_remove=[
                    [kabeldoorlaat_diameter, rechter_zijkant_hoogte, diepte / 2],
                ]
        );
        #translate([kabeldoorlaat_diameter, diepte / 2 + kabeldikte / 2, 0]) #rotate([0, 0, -90]) cube([kabeldikte, 2 * y / 5, thickness]);
        #translate([x / 2, -diepte + 2.4 * kabeldikte, 0]) cube([kabeldikte, 3 * y / 4, thickness]);
    }
}

module voorkant() {
    rotate([0, 0, 0]) lasercutoutSquare(thickness=thickness, x=x, y=voorkant_hoogte,
        bumpy_finger_joints=[
                [UP, 1, 8],
            ]
    );
}

module alles(a = 1, b = 1, c = 1, d = 1, e = 1){
    if (a == 1) onderkant();
    if (b == 1) {
        translate([0, 0.9 * y, 0]) {
            achterkant();
        }
    }
    if (c == 1) translate([-2 * x / 5, 0, 0]) linker_zijkant(y);
    if (d == 1) translate([x + .2 * x / 4, 0, 0]) rechter_zijkant(y);
    if (e == 1) translate([0, -y / 2, 0]) voorkant();
}

// LET OP LET OP LET OP
// Stel de dikte van het materiaal in boven in de file!
// LET OP LET OP LET OP

//alles();

projection(cut=true) alles(0, 0, 0, 1, 0);