% EJERCICIO 5: Horarios 2%
include "globals.mzn";

% Definición de variables y constantes:
set of int: HOURS = 9..12;
set of int: PROF = 1..4;
array[1..16] of string: subjects = ["IA-G1", "IA-G2", "TSI-G1", "TSI-G2", "FBD-G1", "FBD-G2", "TSI-G3", "TSI-G4",
                                    "FBD-G3", "FBD-G4", "IA-G3", "IA-G4", "EMPTY1", "EMPTY2", "EMPTY3", "EMPTY4"];
                       
% Definición de los arrays:
array[HOURS, PROF] of var 1..16: schedule;

% Asignamos sólo una asignatura a cada profesor y horario
constraint alldifferent(h in HOURS, p in PROF) (schedule[h, p]);

% Ponemos las asignaturas que cada profesor cursa
% y las restricciones de horarios de cada uno
constraint forall(h in HOURS) (schedule[h,1] == 1 \/ schedule[h,1] == 2 \/ schedule[h,1] == 3 \/ schedule[h,1] == 4);
constraint forall(h in HOURS) (schedule[h,2] == 5 \/ schedule[h,2] == 6 \/ schedule[h,2] == 13 \/ schedule[h,2] == 14);
constraint forall(h in HOURS) (schedule[h,3] == 7 \/ schedule[h,3] == 8 \/ schedule[h,3] == 9 \/ schedule[h,3] == 10);
constraint forall(h in HOURS) (schedule[h,4] == 11 \/ schedule[h,4] == 12 \/ schedule[h,4] == 15 \/ schedule[h,4] == 16);

% Resultado:
output ["Profesor \(j) da " ++ subjects[ fix(schedule[i,j]) ] ++ " a las \(i):00h\n" | i in HOURS, j in PROF];