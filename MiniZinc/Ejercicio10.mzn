% Ejercicio 10 : Problema de la mochila %
include "globals.mzn";

% Objetos posibles a meter en la mochila:
set of int : OBJS = 1..12;
array[OBJS] of string : objects = ["Mapa", "Compas", "Agua", "Sandwich",
                                   "Azucar", "Lata", "Platano", "Manzana",
                                   "Queso", "Cerveza", "Protector Solar", "Camara"];

% Peso maximo que aguanta la mochila:
int : max_weight = 275;
% Peso de cada uno de esos objetos:
array[OBJS] of int : weights =  [ 9, 13, 153, 50, 15, 68, 27, 39, 23, 52, 11, 32];

% Escala de preferencias de cada objeto (mas alto, mas preferencia):
array[OBJS] of int : preferences =  [ 150, 35, 200, 160, 60, 45, 60, 40, 30, 10, 70, 30];

% Array que representa los objetos que hay en la mochila:
array[OBJS] of var 0..1: backpack;


% Todos los objetos que haya dentro de la mochila no pueden pasar el maximo de peso.
constraint sum(i in OBJS)(weights[i] * backpack[i]) <= max_weight;
% Resolvemos maximizando la suma de preferencias.
solve maximize sum(i in OBJS)(preferences[i] * backpack[i]);


% Resultado:
output ["Preferencia: \(sum(i in OBJS)(preferences[i] * backpack[i])) \nMochila:"] ++
       [" \(objects[obj])," | obj in OBJS where fix(backpack[obj]) == 1];