% EJERCICIO 7: Construccion de casa %
include "globals.mzn"; 

% Tareas necesarias para construirla.
set of int : TASKS = 1..9;
array[TASKS] of string: tasks = ["Levantar_muros", "Carpinteria_de_tejado", "Tejado",
                                 "Instalacion_electrica", "Pintado_fachada", "Ventanas",
                                 "Jardin", "Techado", "Pintado_interior"];

% Duracion de cada una de las tareas anteriores.
array[TASKS] of int : duration =  [7, 3, 1, 8, 2, 1, 1, 3, 2];

% Durancion total que pueden tardar las tareas.
int : total_duration = sum(t in TASKS) (duration[t]);

% Precedencia entre las tareas.
set of int : PRECEDENCES = 1..12;
array[PRECEDENCES, 1..2] of int : precedences = [|1, 2  |2, 3  |1, 4  |3, 5  |4, 5  |3, 6  |4, 6  |3, 7  |4, 7  |1, 8  |6, 9  |8, 9 |];
                                              %   A, B   B, C   A, D   C, E   D, E   C, F   D, F   C, G   D, G   A, H   F, I   H, I

% Definicion de variables y constantes:
array[TASKS] of var 0..total_duration : start;
array[TASKS] of var 1..total_duration : end;
var 1..total_duration : total_time;


constraint
% Asigna el tiempo total utilizado.
maximum(total_time, end) /\
% Distribucion de los trabajdores por tarea.
cumulative(start, duration, [1 | i in TASKS], 1000) /\
% Actualiza las duraciones de cada tarea.
forall(t in TASKS) (end[t] = start[t] + duration[t]) /\
% Comprobacion de las precedencias de cada tarea.
forall(p in PRECEDENCES) ( start[ precedences[p,1] ] + duration[ precedences[p,1] ] <= start[ precedences[p,2] ] );


% Hacemos la parte de satisfaccion y la de minimizacion de tiempo total.
solve minimize total_time;

% Resultado:
output ["Tiempo total: \(total_time)\n"] ++ ["\(tasks[t]) : empieza el dia \(start[t]), tarda \(duration[t]) dias (termina el dia \(start[t] + duration[t]))\n" | t in TASKS];