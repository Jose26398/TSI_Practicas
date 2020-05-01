% EJERCICIO 5: Horarios 3 %
include "globals.mzn";

% Definición de variables y constantes:
set of int: HOURS = 1..6;
set of int: DAYS = 1..5;

% Definición de los arrays:
array [HOURS,DAYS] of var 1..15: schedule_subj;
array [HOURS,DAYS] of var 1..10: schedule_teac;

% Los A1.2 son asignaturas que se imparten en dos horas, se obliga a que A1 este justo detras de A1.2.  EMPTY es recreo
array [1..15] of string: subjects = ["A1", "A2", "A3", "A4", "A5", "A6", "A7", "A8", "A9", "EMPTY", "A1.2", "A3.2", "A4.2", "A5.2", "A8.2"];

% Numero de veces que van a aparecer en el horario cada asignatura
array [1..15] of var 1..5: subject_hours = [2, 2, 2, 2, 2, 2, 2, 1, 1, 5, 2, 2, 2, 2, 1];


% Asignamos profesores dependiendo de las asignatura, para la 4 asignamos profesores "distintos" y asi las siguientes restricciones funcionan
constraint forall(i in HOURS, j in DAYS)(
    if (schedule_subj[i,j] == 1 \/ schedule_subj[i,j] == 3) then schedule_teac[i,j] == 1
    elseif (schedule_subj[i,j] == 4 \/ schedule_subj[i,j] == 5) then schedule_teac[i,j] == 2
    elseif(schedule_subj[i,j] == 6 \/ schedule_subj[i,j] == 9) then schedule_teac[i,j] == 3
    else schedule_teac[i,j] == (3+i)
    endif
);

% Establece recreos
constraint forall(j in DAYS)(schedule_subj[4,j] == 10);

% Las asignaturas de 2 horas no pueden empezar en segunda hora por el recreo, o en ultima hora
constraint forall(j in DAYS)(schedule_subj[2,j] != 1 /\ schedule_subj[2,j] != 3 /\ schedule_subj[2,j] != 4 /\ schedule_subj[2,j] != 5 /\ schedule_subj[2,j] != 8);
constraint forall(j in DAYS)(schedule_subj[6,j] != 1 /\ schedule_subj[6,j] != 3 /\ schedule_subj[6,j] != 4 /\ schedule_subj[6,j] != 5 /\ schedule_subj[6,j] != 8);

% Emparejamos las asignaturas de dos horas con sus continuaciones
constraint forall(i in 1..5, j in DAYS)(schedule_subj[i,j] != 1 \/ schedule_subj[i+1,j] == 11);
constraint forall(i in 1..5, j in DAYS)(schedule_subj[i,j] != 3 \/ schedule_subj[i+1,j] == 12);
constraint forall(i in 1..5, j in DAYS)(schedule_subj[i,j] != 4 \/ schedule_subj[i+1,j] == 13);
constraint forall(i in 1..5, j in DAYS)(schedule_subj[i,j] != 5 \/ schedule_subj[i+1,j] == 14);
constraint forall(i in 1..5, j in DAYS)(schedule_subj[i,j] != 8 \/ schedule_subj[i+1,j] == 15);

% Aseguramos que cada asignatura aparece el numero de veces que debe
constraint forall(w in 1..15)(count([ schedule_subj[i,j] | i in HOURS, j in DAYS ], w) == subject_hours[w]);

% Cada dia solo se puede impartir un bloque de la misma asignatura
constraint forall (j in DAYS) ( alldifferent( [ schedule_subj[i,j] | i in HOURS ]) );

% Cada dia un profesor solo puede impartir un bloque, salvo el prof 4 (resto de indices) el cual imparte mas
constraint forall (j in DAYS) ( alldifferent( [ schedule_teac[i,j] | i in HOURS ]) );


output [ "\(i):\(j) Prof:\(schedule_teac[i,j]) Asignatura:\(subjects[fix(schedule_subj[i,j])])\t" ++ if j==5 then "\n" else "   " endif | i in HOURS, j in DAYS]