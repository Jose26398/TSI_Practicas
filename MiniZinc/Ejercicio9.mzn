% EJERCICIO 9: Construccion de casa 3 %
include "globals.mzn";

int: horizon = 10; % time horizon
set of int: Time = 0..horizon;

int: n = 9; % number of tasks
set of int: Task = 1..n;

int: k = 3; % number of machines
set of int: Machine = 1..k;

array[Task,Machine] of int: d =  [|
 4, 7, 10,
| 3, 5, 7,
| 3, 1, 4,
| 2, 5, 8,
| 4, 2, 2,
| 3, 1, 1,
| 1, 1, 1,
| 1, 3, 3,
| 2, 2, 2 |];
int: maxd = max([ d[t,m] | t in Task, m in Machine ]);
int: mind = min([ d[t,m] | t in Task, m in Machine ]);
array[Task] of var Time: S;
array[Task] of var mind..maxd: D;
array[Task,Machine] of var opt Time: O;

% Precedencia entre las tareas.
int : num_precedences = 12;
array[1..num_precedences, 1..2] of int : precedences = [|1, 2  |2, 3  |1, 4  |3, 5  |4, 5  |3, 6  |4, 6  |3, 7  |4, 7  |1, 8  |6, 9  |8, 9 |];
                                                     %   A, B   B, C   A, D   C, E   D, E   C, F   D, F   C, G   D, G   A, H   F, I   H, I


constraint cumulative(S, D, [1 | i in Task], k) /\

forall(m in Machine)( disjunctive([O[t,m] | t in Task], [d[t,m] | t in Task]) ) /\

forall(t in Task)(alternative(S[t], D[t], [O[t,m] | m in Machine], [d[t,m] | m in Machine])) /\

forall(p in 1..num_precedences)(S[ precedences[p,1] ] + D[precedences[p,1]] <= S[ precedences[p,2] ]);


solve minimize max(t in Task)(S[t] + D[t]);

% Resultado:
%output ["Tiempo total: \(max(t in Task)(S[t] + D[t]))\n"] ++ ["\(Task[t]) : empieza el dia \(S[t]), tarda \(D[t]) dias (termina el dia \(S[t] + D[t]))\n" | t in Task];