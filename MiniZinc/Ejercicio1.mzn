% EJERCICIO 1: Puzzle Cripto-aritmético %
include "globals.mzn";

% Definición de variables y constantes:
set of int: POS = 1..10;
set of int: VALUES = 0..9;

% Definición de los arrays:          1    2    3    4    5    6    7    8    9    10
array[POS] of string: strNumbers = ["T", "E", "S", "F", "D", "I", "N", "K", "R", "A"];
array [POS] of var VALUES: numbers;

% Todos los números tienen que ser distintos
constraint all_different(numbers);

%  Suma: TESTE + FESTE + DEINE = KRAFTE
constraint (numbers[1]*10000 + numbers[2]*1000 + numbers[3]*100 + numbers[1]*10 + numbers[2]) +
           (numbers[4]*10000 + numbers[2]*1000 + numbers[3]*100 + numbers[1]*10 + numbers[2]) +
           (numbers[5]*10000 + numbers[2]*1000 + numbers[6]*100 + numbers[7]*10 + numbers[2]) =
           (numbers[8]*100000 + numbers[9]*10000 + numbers[10]*1000 + numbers[4]*100 + numbers[1]*10 + numbers[2]);

% Result: 30.830 + 60.830 + 50970 = 142.630
output ["\(strNumbers[i]) = \(numbers[i])\n" | i in POS];