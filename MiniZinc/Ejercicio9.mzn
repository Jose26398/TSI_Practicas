% EJERCICIO 9: Construccion de casa 3 %
include "globals.mzn";

% Tareas necesarias para construirla.
set of int: TASKS = 1..9;
array[TASKS] of string: tasks = ["Levantar_muros", "Carpinteria_de_tejado", "Tejado",
                                 "Instalacion_electrica", "Pintado_fachada", "Ventanas",
                                 "Jardin", "Techado", "Pintado_interior"];

% Trabajadores disponibles para hacer las tareas.
set of int : WORKERS = 1..3;

% Duracion de cada una de las tareas anteriores.
array[TASKS, WORKERS] of int: duration =  [| 4, 7, 10,
                                           | 3, 5, 7,
                                           | 3, 1, 4,
                                           | 2, 5, 8,
                                           | 4, 2, 2,
                                           | 3, 1, 1,
                                           | 1, 1, 1,
                                           | 1, 3, 3,
                                           | 2, 2, 2 |];
                                                     
% Precedencia entre las tareas.
set of int : PRECEDENCES = 1..12;
array[PRECEDENCES, 1..2] of int : precedences = [|1, 2  |2, 3  |1, 4  |3, 5  |4, 5  |3, 6  |4, 6  |3, 7  |4, 7  |1, 8  |6, 9  |8, 9 |];
                                              %   A, B   B, C   A, D   C, E   D, E   C, F   D, F   C, G   D, G   A, H   F, I   H, I
                                                     

% Definicion de variables y constantes:
int: maxd = max([ duration[t,m] | t in TASKS, m in WORKERS ]);
int: mind = min([ duration[t,m] | t in TASKS, m in WORKERS ]);

% Durancion total que pueden tardar las tareas.
int: total_duration = max(i in TASKS)(sum(j in WORKERS)(duration[i,j]) + 1);

array[TASKS] of var 0..total_duration: start;
array[TASKS] of var 1..total_duration: end;
array[TASKS] of var mind..maxd: optional_duration;
array[TASKS, WORKERS] of var opt 0..total_duration: optional_start;
var 1..100 : total_time;


constraint
% Actualiza el tiempo total utilizado.
maximum(total_time, end) /\
% Comprobacion de las duraciones de cada tarea
forall(m in WORKERS)( disjunctive([optional_start[t,m] | t in TASKS], [duration[t,m] | t in TASKS]) ) /\
forall(t in TASKS)  ( alternative(start[t], optional_duration[t], [optional_start[t,m] | m in WORKERS], [duration[t,m] | m in WORKERS])) /\
% Comprobacion de las duraciones de cada tarea
forall(t in TASKS) (end[t] = start[t] + optional_duration[t]) /\
% Comprobacion de las precedencias de cada tarea
forall(p in PRECEDENCES)(start[ precedences[p,1] ] + optional_duration[precedences[p,1]] <= start[ precedences[p,2] ]);


solve minimize total_time;

% Resultado:
output ["Tiempo total: \(total_time)\n"] ++ ["\(tasks[t]) : empieza el dia \(start[t]), tarda \(optional_duration[t]) dias (termina el dia \(start[t] + optional_duration[t]))\n" | t in TASKS];