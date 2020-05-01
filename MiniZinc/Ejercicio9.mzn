% EJERCICIO 9: Construccion de casa 3 %
include "globals.mzn";

int: horizon = 20; % time horizon
set of int: Time = 0..horizon;

% Tareas necesarias para construirla.
int: num_tasks = 9;
array[1..num_tasks] of string: tasks = ["Levantar_muros", "Carpinteria_de_tejado", "Tejado",
                                        "Instalacion_electrica", "Pintado_fachada", "Ventanas",
                                        "Jardin", "Techado", "Pintado_interior"];

% Trabajadores disponibles para hacer las tareas.
int : workers = 3;

% Duracion de cada una de las tareas anteriores.
array[1..num_tasks, 1..workers] of int: duration =  [| 4, 7, 10,
                                                     | 3, 5, 7,
                                                     | 3, 1, 4,
                                                     | 2, 5, 8,
                                                     | 4, 2, 2,
                                                     | 3, 1, 1,
                                                     | 1, 1, 1,
                                                     | 1, 3, 3,
                                                     | 2, 2, 2 |];
                                                     
% Precedencia entre las tareas.
int : num_precedences = 12;
array[1..num_precedences, 1..2] of int : precedences = [|1, 2  |2, 3  |1, 4  |3, 5  |4, 5  |3, 6  |4, 6  |3, 7  |4, 7  |1, 8  |6, 9  |8, 9 |];
                                                     %   A, B   B, C   A, D   C, E   D, E   C, F   D, F   C, G   D, G   A, H   F, I   H, I
                                                     

% Definicion de variables y constantes:
int: maxd = max([ duration[t,m] | t in 1..num_tasks, m in 1..workers ]);
int: mind = min([ duration[t,m] | t in 1..num_tasks, m in 1..workers ]);

array[1..num_tasks] of var Time: start;
array[1..num_tasks] of var 1..100: end;
array[1..num_tasks] of var mind..maxd: D;
array[1..num_tasks, 1..workers] of var opt Time: O;
var 1..100 : total_time;


constraint
% Actualiza el tiempo total utilizado.
maximum(total_time, end) /\
% Distribucion de los trabajdores por tarea
cumulative(start, D, [1 | i in 1..num_tasks], workers) /\
% Comprobacion de las duraciones de cada tarea
forall(m in 1..workers)( disjunctive([O[t,m] | t in 1..num_tasks], [duration[t,m] | t in 1..num_tasks]) ) /\
forall(t in 1..num_tasks)(alternative(start[t], D[t], [O[t,m] | m in 1..workers], [duration[t,m] | m in 1..workers])) /\
% Comprobacion de las duraciones de cada tarea
forall(t in 1..num_tasks) (end[t] = start[t] + D[t]) /\
% Comprobacion de las precedencias de cada tarea
forall(p in 1..num_precedences)(start[ precedences[p,1] ] + D[precedences[p,1]] <= start[ precedences[p,2] ]);


solve minimize total_time;

% Resultado:
output ["Tiempo total: \(total_time)\n"] ++ ["\(tasks[t]) : empieza el dia \(start[t]), tarda \(D[t]) dias (termina el dia \(start[t] + D[t]))\n" | t in 1..num_tasks];