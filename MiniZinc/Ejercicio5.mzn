% EJERCICIO 5: Horarios 3 %
include "globals.mzn";

% Definición de variables y constantes:
set of int: HOURS = 8..13;
set of int: DAYS = 1..5;
set of int: PROF = 1..4;

array[1..9] of int: subjects = [1, 2, 3, 4, 5, 6, 7, 8, 9];
array[1..9] of int: subject_hours = [4, 2, 4, 4, 4, 2, 2, 2, 1];

set of int: blk_2h = {1, 3, 4, 5, 8};
set of int: blk_1h = {2, 6, 7, 9};
                                              
% Definición de los arrays:
array[HOURS, DAYS] of int: schedule;

constraint forall(s in subject_hours)(sum( h in HOURS )( sum( d in DAYS )( schedule[h,d] == s ) ) == s);

constraint forall(d in DAYS, h in HOURS)(
      (schedule[h,d] == schedule[h+1,d] \/ schedule[h,d] == schedule[h-1,d]) /\ schedule[h,d] in blk_2h
);

% Resultado:
%output ["Profesor \(j) da " ++ subjects[ fix(schedule[i,j]) ] ++ " a las \(i):00h\n" | i in HOURS, j in PROF];