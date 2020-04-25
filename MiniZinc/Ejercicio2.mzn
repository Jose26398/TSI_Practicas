% EJERCICIO 2: Encontrar número %
include "globals.mzn";

% Definición del array:

array [1..8] of var 0..1: number;

var int : zeros = 3;
var int : ones;

% La suma de la primera mitad igual a la suma de la segunda mitad
constraint count(number, 0) == zeros /\ count(number,1) == ones;

% Result:
output ["\(zeros)\(ones)"];
output ["\(number[i])" | i in 1..8];