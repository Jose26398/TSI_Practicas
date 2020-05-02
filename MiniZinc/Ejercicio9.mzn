% EJERCICIO 9: Construccion de casa 3 %
include "globals.mzn";

int: limit = 20; % time limit
set of int: Time = 0..limit;

% Tareas necesarias para construirla.
set of int: TASKS = 1..9;
array[TASKS] of string: tasks = ["Levantar_muros", "Carpinteria_de_tejado", "Tejado",
                                 "Instalacion_electrica", "Pintado_fachada", "Ventanas",
                                 "Jardin", "Techado", "Pintado_interior"];

% Trabajadores disponibles para hacer las tareas.
int : workers = 3;

% Duracion de cada una de las tareas anteriores.
array[TASKS, 1..workers] of int: duration =  [| 4, 7, 10,
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
int: maxd = max([ duration[t,m] | t in TASKS, m in 1..workers ]);
int: mind = min([ duration[t,m] | t in TASKS, m in 1..workers ]);

array[TASKS] of var Time: start;
array[TASKS] of var 1..100: end;
array[TASKS] of var mind..maxd: D;
array[TASKS, 1..workers] of var opt Time: O;
var 1..100 : total_time;


constraint
% Actualiza el tiempo total utilizado.
maximum(total_time, end) /\
% Distribucion de los trabajdores por tarea
cumulative(start, D, [1 | i in TASKS], workers) /\
% Comprobacion de las duraciones de cada tarea
forall(m in 1..workers)( disjunctive([O[t,m] | t in TASKS], [duration[t,m] | t in TASKS]) ) /\
forall(t in TASKS)(alternative(start[t], D[t], [O[t,m] | m in 1..workers], [duration[t,m] | m in 1..workers])) /\
% Comprobacion de las duraciones de cada tarea
forall(t in TASKS) (end[t] = start[t] + D[t]) /\
% Comprobacion de las precedencias de cada tarea
forall(p in PRECEDENCES)(start[ precedences[p,1] ] + D[precedences[p,1]] <= start[ precedences[p,2] ]);


solve minimize total_time;

% Resultado:
output ["Tiempo total: \(total_time)\n"] ++ ["\(tasks[t]) : empieza el dia \(start[t]), tarda \(D[t]) dias (termina el dia \(start[t] + D[t]))\n" | t in TASKS];