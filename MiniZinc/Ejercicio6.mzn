% EJERCICIO 6: Personas %
include "globals.mzn";

% Definicion de variables y constantes:
set of int: PEOPLE = 1..5;
array[1..5] of string: regions = ["vasco", "catalan", "gallego", "navarro", "andaluz"];
array[1..5] of string: professions = ["pintor", "escultor", "diplomatico", "violinista", "medico"];
array[1..5] of string: animals = ["perro", "caracoles", "zorro", "caballo", "cebra"];
array[1..5] of string: drinks = ["zumo", "leche", "te", "cafe", "agua"];
array[1..5] of string: colors = ["roja", "amarilla", "azul", "verde", "blanca"];
array[1..5] of string: positions = ["izquierda", "centroizquierda", "centro", "centroderecha", "derecha"];

% Matriz solucion
array[1..5, 1..5] of var PEOPLE: matrix;


% Asignamos solo una variable distinta a cada una de las personas:
constraint forall (h in 1..5) (alldifferent(p in 1..5) (matrix[p, h]));


% El vasco vive en la casa roja.
constraint matrix[1,4] == 1;

% El catalan tiene un perro.
constraint matrix[2,2] == 1;

% El gallego es un pintor.
constraint matrix[3,1] == 1;

% El navarro bebe te.
constraint matrix[4,3] == 3;

% El andaluz vive en la primera casa de la izquierda.
constraint matrix[5,5] == 1;

% El de la casa verde bebe cafe.
var int : casa_verde;
constraint matrix[casa_verde,4] == 4 /\ matrix[casa_verde,3] == 4;

% La casa verde esta al lado de la blanca y a su derecha.
var int : casa_blanca;
constraint matrix[casa_blanca,4] == 5 /\ matrix[casa_blanca,5]+1 == matrix[casa_verde,5];

% El escultor cria caracoles.
var int : escultor;
constraint matrix[escultor,1] == 2 /\ matrix[escultor,2] == 2;

% El diplomático vive en la casa amarilla.
var int : diplomatico;
constraint matrix[diplomatico,1] == 3 /\ matrix[diplomatico,4] == 2;

% En la casa central se bebe leche.
var int : central;
constraint matrix[central,5] == 3 /\ matrix[central,3] == 2;

% La casa del andaluz esta al lado de la azul.
var int : vecino_andaluz;
constraint matrix[vecino_andaluz,5] == 2 /\ matrix[vecino_andaluz,4] == 3;

% El violinista bebe zumo.
var int : violinista;
constraint matrix[violinista,1] == 4 /\ matrix[violinista,3] == 1;

% El zorro esta en una casa al lado de la del medico.
var int : casa_zorro;
var int : casa_medico;
constraint matrix[casa_zorro,2] == 3 /\ matrix[casa_medico,1] == 5;
constraint matrix[casa_zorro,5]+1 == matrix[casa_medico,5] \/ matrix[casa_zorro,5]-1 == matrix[casa_medico,5];

% El caballo esta en una casa al lado de la del diplomatico.
var int : casa_caballo;
constraint matrix[casa_caballo,2] == 4 /\ matrix[diplomatico,1] == 3;
constraint matrix[casa_caballo,5]+1 == matrix[diplomatico,5] \/ matrix[casa_caballo,5]-1 == matrix[diplomatico,5];


% Resultado:
output ["El \(regions[i]) es \(professions[fix(matrix[i,1])]), tiene \(animals[fix(matrix[i,2])]), bebe \(drinks[fix(matrix[i,3])]), su casa en \(colors[fix(matrix[i,4])]) y vive en la posicion \(positions[fix(matrix[i,5])])\n" | i in 1..5];