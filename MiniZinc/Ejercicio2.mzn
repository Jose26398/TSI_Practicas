% EJERCICIO 2: Encontrar número %
include "globals.mzn";

% Definición del array:
array [0..9] of var 0..9: number;

% Por cada posicion del array contamos cada vez que aparece ese numero en el.
constraint forall(i in 0..9) (count(number, i) == number[i]);

% Result:
output ["X = "] ++ ["\(number[i])" | i in 0..9];