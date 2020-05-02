% EJERCICIO 5: Horarios 3 %
include "globals.mzn";

% Definición de variables y constantes:
set of int: HOURS = 8..13;
set of int: DAYS = 1..5;

array [1..15] of string: subjects = ["A1-1", "A2-1", "A3-1", "A4-1", "A5-1", "A6-1", "A7-1", "A8-1", "A9-1",
                                     "EMPTY", "A1-2", "A3-2", "A4-2", "A5-2", "A8-2"];     % Segunda hora de la asignatura 
array [1..15] of var 1..5: subject_hours = [2, 2, 2, 2, 2, 2, 2, 1, 1, 5, 2, 2, 2, 2, 1];
array [1..15] of int: subject_teac = [1, 4, 1, 2, 2, 3, 4, 4, 3, 0, 1, 1, 2, 2, 4];

% Definición de los arrays:
array [HOURS, DAYS] of var 1..15: schedule_subj;
array [HOURS, DAYS] of var 1..10: schedule_teac;


% Evitamos que en un dia se de más de una clase de un mismo bloque.
constraint forall (j in DAYS) ( alldifferent( [ schedule_subj[i,j] | i in HOURS ]) );
% Evitamos que un profesor imparta mas de un bloque.
constraint forall (j in DAYS) ( alldifferent( [ schedule_teac[i,j] | i in HOURS ]) );

% Recreos:
constraint forall(j in DAYS)(schedule_subj[11,j] == 10);

% Cada asignatura imparte sus horas correspondientes.
constraint forall(s in 1..15)(count([ schedule_subj[i,j] | i in HOURS, j in DAYS ], s) == subject_hours[s]);


% Evitamos asignaturas de 2 horas antes del recreo o ultima hora:
constraint forall(j in DAYS)(schedule_subj[9,j]  != 1 /\ schedule_subj[9,j]  != 3 /\ schedule_subj[9,j]  != 4 /\ schedule_subj[9,j]  != 5 /\ schedule_subj[9,j]  != 8);
constraint forall(j in DAYS)(schedule_subj[13,j] != 1 /\ schedule_subj[13,j] != 3 /\ schedule_subj[13,j] != 4 /\ schedule_subj[13,j] != 5 /\ schedule_subj[13,j] != 8);

% Asignamos las segundsa partes de las asignaturas:
constraint forall(i in {8,9,10,12}, j in DAYS)(schedule_subj[i,j] != 1 \/ schedule_subj[i+1,j] == 11);
constraint forall(i in {8,9,10,12}, j in DAYS)(schedule_subj[i,j] != 3 \/ schedule_subj[i+1,j] == 12);
constraint forall(i in {8,9,10,12}, j in DAYS)(schedule_subj[i,j] != 4 \/ schedule_subj[i+1,j] == 13);
constraint forall(i in {8,9,10,12}, j in DAYS)(schedule_subj[i,j] != 5 \/ schedule_subj[i+1,j] == 14);
constraint forall(i in {8,9,10,12}, j in DAYS)(schedule_subj[i,j] != 8 \/ schedule_subj[i+1,j] == 15);


% Asignamos un valor distinto a cada celda (no es el profesor, es un valor):
constraint forall(i in HOURS, j in DAYS)(
    if     (schedule_subj[i,j] == 1 \/ schedule_subj[i,j] == 3) then schedule_teac[i,j] == 1
    elseif (schedule_subj[i,j] == 4 \/ schedule_subj[i,j] == 5) then schedule_teac[i,j] == 2
    elseif (schedule_subj[i,j] == 6 \/ schedule_subj[i,j] == 9) then schedule_teac[i,j] == 3
    else   schedule_teac[i,j] == (i-4)
    endif
);


solve satisfy;

% Resultado
output ["\(i):00h - \(subjects[fix(schedule_subj[i,j])])-> Prof: \(subject_teac[fix(schedule_subj[i,j])]) " ++ if i==13 then "\n" else "\t" endif |j in DAYS,  i in HOURS]
