% EJERCICIO 3: Horarios %
include "globals.mzn";

% Definición de variables y constantes:
set of int: HOURS = 9..14;
set of int: PROF = 1..6;

% Definición de los arrays:
array [PROF] of var HOURS: schedule;


% Única aula con un único profesor por hora
constraint all_different(schedule);

% Restricciones horarias
constraint schedule[1] != 9 /\ schedule[1] != 10;
constraint schedule[2] == 11 \/ schedule[2] == 12;
constraint schedule[3] != 9 /\ schedule[3] != 14;
constraint schedule[4] != 9 /\ schedule[4] != 13 /\ schedule[4] != 14;
constraint schedule[5] == 11 \/ schedule[5] == 12;


% Resultado:
output ["Profesor \(i) da 1h de clase a las \(schedule[i]):00h\n" | i in PROF];