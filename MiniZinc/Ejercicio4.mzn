% EJERCICIO 4: Horarios %
include "globals.mzn";

% Definición de variables y constantes:
set of int: HOURS = 9..12;
set of int: PROF = 1..4;
array[1..16] of string: subjects = ["IA-G1", "IA-G2", "TSI-G1", "TSI-G2", "FBD-G1", "FBD-G2", "TSI-G3", "TSI-G4",
                                    "FBD-G3", "FBD-G4", "IA-G3", "IA-G4", "EMPTY1", "EMPTY2", "EMPTY3", "EMPTY4"];

% Definición de los arrays:
array[HOURS, PROF] of var 1..16: schedule;
array[HOURS, PROF] of var 1..16: groups;


% Asignamos sólo una asignatura a cada profesor y horario
constraint alldifferent(schedule);
% Evitamos que en una hora este dando clase el mismo grupo
constraint forall (h in HOURS) (alldifferent( [ groups[h,p] | p in PROF ]) ); 

% Ponemos las asignaturas y grupos que cada profesor cursa y las restricciones de horarios de cada uno
constraint forall(h in HOURS) ((schedule[h,1] == 1 /\ groups[h,1] == 1) \/ (schedule[h,1] == 2 /\ groups[h,1] == 2)
                            \/ (schedule[h,1] == 3 /\ groups[h,1] == 1) \/ (schedule[h,1] == 4 /\ groups[h,1] == 2) );
                            
constraint forall(h in HOURS where h != 10) (( (schedule[h,2] == 5 /\ groups[h,2] == 1) \/ (schedule[h,2] == 6 /\ groups[h,2] == 2)
                                            \/ (schedule[h,2] == 13 /\ groups[h,2] == 1) ) /\ schedule[10,2] == 14 /\ groups[10,2] == 2);
                                            
constraint forall(h in HOURS) ((schedule[h,3] == 7 /\ groups[h,3] == 3) \/ (schedule[h,3] == 8 /\ groups[h,3] == 4)
                            \/ (schedule[h,3] == 9 /\ groups[h,3] == 3) \/ (schedule[h,3] == 10 /\ groups[h,3] == 4) );
                            
constraint forall(h in HOURS where h != 9)  (( (schedule[h,4] == 11 /\ groups[h,4] == 3) \/ (schedule[h,4] == 12 /\ groups[h,4] == 4)
                                            \/ (schedule[h,4] == 15 /\ groups[h,4] == 3) ) /\ schedule[9,4] == 16 /\ groups[9,4] == 4);


% Resultado:
output ["Profesor \(j) da " ++ subjects[ fix(schedule[i,j]) ] ++ " a las \(i):00h\n" | i in HOURS, j in PROF];