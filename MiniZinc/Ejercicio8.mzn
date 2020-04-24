% EJERCICIO 7: Construccion de casa 2 %
include "globals.mzn"; 

% Tareas necesarias para construirla.
int: num_tasks = 9;
array[1..num_tasks] of string: tasks = ["Levantar_muros", "Carpinteria_de_tejado", "Tejado",
                                        "Instalacion_electrica", "Pintado_fachada", "Ventanas",
                                        "Jardin", "Techado", "Pintado_interior"];

% Duracion de cada una de las tareas anteriores.
array[1..num_tasks] of int : duration =  [7, 3, 1, 8, 2, 1, 1, 3, 2];

% Trabajadores disponibles para hacer las tareas.
int : available_workers = 3;
% Trabjadores que realizan cada una de las tareas.
array[1..num_tasks] of int : workers  =  [ 2, 3, 2, 2, 1, 2, 1, 1, 2];

% Durancion total que pueden tardar las tareas.
int : total_duration = sum(t in 1..num_tasks) (duration[t]);

% Precedencia entre las tareas.
int : num_precedences = 12;
array[1..num_precedences, 1..2] of int : precedences = [|1, 2  |2, 3  |1, 4  |3, 5  |4, 5  |3, 6  |4, 6  |3, 7  |4, 7  |1, 8  |6, 9  |8, 9 |];
                                                     %   A, B   B, C   A, D   C, E   D, E   C, F   D, F   C, G   D, G   A, H   F, I   H, I

% Definicion de variables y constantes:
array[1..num_tasks] of var 1..total_duration : start;
array[1..num_tasks] of var 1..total_duration : end;
var 1..total_duration : total_time;

% Hacemos la parte de satisfaccion y la de minimizacion de tiempo total.
solve :: int_search( start ++ [total_time], first_fail, indomain_min, complete) minimize total_time;


constraint
% Actualiza el tiempo total utilizado.
maximum(total_time, end) /\
% Distribucion de los trabajdores por tarea
cumulative(start, duration, workers, available_workers) /\
% Comprobacion de las duraciones de cada tarea
forall(t in 1..num_tasks) (end[t] = start[t] + duration[t]) /\
% Comprobacion de las precedencias de cada tarea
forall(p in 1..num_precedences) ( start[ precedences[p,1] ] + duration[ precedences[p,1] ] <= start[ precedences[p,2] ] );


% Resultado:
output ["Tiempo total: \(total_time)\n"] ++ ["\(tasks[t]) : empieza el dia \(start[t]), tarda \(duration[t]) dias (termina el dia \(start[t] + duration[t]))\n" | t in 1..num_tasks];