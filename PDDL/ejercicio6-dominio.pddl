(define (domain ejercicio6)
    (:requirements :strips :typing :negative-preconditions :equality :conditional-effects :disjunctive-preconditions :fluents)
    
    (:types
        Unidades Edificios Localizaciones Cantidad - object
        tipoUnidades tipoEdificios tipoLocalizaciones - constants
    )
    (:constants 
        VCE Marine Segador - tipoUnidades
        CentroDeMando Barracones Extractor BahiaDeIngenieria Deposito - tipoEdificios
        Mineral Gas - tipoLocalizaciones
    )
    
    (:predicates
        ; Predicados para indicar que un objeto X es de un tipo Y
        (unidadTipo ?uni - Unidades ?tipo - tipoUnidades)
        (edificioTipo ?edi - Edificios ?tipo - tipoEdificios)
        (localizacionTipo ?loc - Localizaciones ?tipo - tipoLocalizaciones)

        ; Comprobar que un edificio o unidad esta en una localizacion concreta
        (unidadEn ?uni - Unidades ?loc - Localizaciones)
        (edificioEn ?edi - Edificios ?loc - Localizaciones)

        ; Comprobar que la primera y la segunda localizacion estan conectadas
        (existeCamino ?loc1 - Localizaciones ?loc2 - Localizaciones)

        ; Asignar un recurso concreto a una localizacion
        (asignadoRecursoEn ?rec - tipoLocalizaciones ?loc - Localizaciones)

        ; Indicar si un VCE esta extrayendo un recurso
        (extrayendoEn ?vce - Unidades ?loc - Localizaciones)
        (generando ?rec - tipoLocalizaciones)

        ; Recursos que necesita un edificio para ser construido
        (necesitaE ?edi - tipoEdificios ?rec - tipoLocalizaciones)
        ; Recursos que necesita una unidad para ser creada
        (necesitaU ?uni - tipoUnidades ?rec - tipoLocalizaciones)
        ; Recursos que necesita una unidad para ser investigada
        (necesitaI ?tipoU - tipoUnidades ?rec - tipoLocalizaciones)

        ; Asociar la unidad con el edificio en la que es creada
        (entrena ?tipoE - tipoEdificios ?tipoU - tipoUnidades)
        ; Indica si la unidad ya esta investigada
        (investigado ?tipoU - tipoUnidades)
        
        
        (hayEdificio ?loc - Localizaciones)
        (reclutada ?uni - Unidades)
        (extrayendoRecurso ?vce - Unidades ?rec - tipoLocalizaciones)
        (investigaciondisponible)
)

    (:functions 
        (recursoAlmacenado ?rec - tipoLocalizaciones)
        (capacidadMaxima)
    )
    
    ; ----------------------------------------------------------------------------- ;
    ; NAVEGAR. Mover una unidad entre una localizacion y otra ;
    ; ----------------------------------------------------------------------------- ;
    (:action Navegar
        :parameters (?uni - Unidades ?loc1 - Localizaciones ?loc2 - Localizaciones)
        :precondition
            (and
                (existeCamino ?loc1 ?loc2)      ; si existe un camino entre loc1 y loc2
                (unidadEn ?uni ?loc1)           ; la unidad se encuentra en loc1
                (not (extrayendoEn ?uni ?loc1)) ; y no esta ocupada extreyendo
            )
        :effect
            (and
                (unidadEn ?uni ?loc2)       ; aniade la nueva posicion
                (not (unidadEn ?uni ?loc1)) ; elimina la antigua
            )
    )

    ; ----------------------------------------------------------------------------- ;
    ; ASIGNAR. Pone a un VCE a extrear recursos de un nodo
    ; ----------------------------------------------------------------------------- ;
    (:action Asignar
        :parameters (?vce - Unidades ?loc - Localizaciones ?rec - tipoLocalizaciones ?ext - Edificios)
        :precondition 
            (and
                (unidadTipo ?vce VCE)           ; la unidad tiene que ser un VCE
                (unidadEn ?vce ?loc)            ; tiene que estar en la posicion del recurso
                (not (extrayendoEn ?vce ?loc))  ; y que no estuviese extrayendolo previamente
                
                ; Comprobamos el recurso asignado para posteriormente comprobar
                (asignadoRecursoEn ?rec ?loc)
            )
        :effect 
            (and
                (when (or
                        (not (= ?rec Gas))              ; si no es un nodo de Gas
                        (and (edificioEn ?ext ?loc)     ; o si hay un Extractor en la localizacion
                        (edificioTipo ?ext Extractor))
                    )
                    (and (extrayendoEn ?vce ?loc)   ; entonces asigna al VCE en la localizacion del recurso
                    (extrayendoRecurso ?vce ?rec))
                )
            )
    )

    ; ----------------------------------------------------------------------------- ;
    ; CONSTRUIR. Ordena a un trabajador libre que construya un edificio
    ; ----------------------------------------------------------------------------- ;
    (:action Construir
        :parameters (?vce - Unidades ?edi - Edificios ?loc - Localizaciones)
        :precondition
            (and
                (unidadTipo ?vce VCE)           ; la unidad tiene que ser un VCE
                (unidadEn ?vce ?loc)            ; la unidad tiene que estar en la localizacion requerida
                (not (extrayendoEn ?vce ?loc))  ; no puede estar ocupada extrayendo
                (not (hayEdificio ?loc))
            )
        :effect
            ; Decrementamos la cantidad de recursos correspondiente a los distintos
            ; tipos de edificios (excepto el deposito que tambien aumenta la capacidad)
            (and
                (hayEdificio ?loc)
                (when (and (edificioTipo ?edi CentroDeMando)
                           (>= (recursoAlmacenado Mineral) 150)
                           (>= (recursoAlmacenado Gas) 50))
                    (and (decrease (recursoAlmacenado Mineral) 150)
                    (decrease (recursoAlmacenado Gas) 50)
                    (edificioEn ?edi ?loc)
                    (hayEdificio ?loc))
                )
                (when (and (edificioTipo ?edi Barracones)
                           (>= (recursoAlmacenado Mineral) 150))
                    (and (decrease (recursoAlmacenado Mineral) 150)
                    (edificioEn ?edi ?loc)
                    (hayEdificio ?loc))
                )
                (when (and (edificioTipo ?edi Extractor)
                           (>= (recursoAlmacenado Mineral) 75))
                    (and (decrease (recursoAlmacenado Mineral) 75)
                    (edificioEn ?edi ?loc)
                    (hayEdificio ?loc))
                )
                (when (and (edificioTipo ?edi BahiaDeIngenieria)
                           (>= (recursoAlmacenado Mineral) 125))
                    (and (decrease (recursoAlmacenado Mineral) 125)
                    (investigacionDisponible)
                    (hayEdificio ?loc))
                )
                (when (and (edificioTipo ?edi Deposito)
                           (>= (recursoAlmacenado Mineral) 75)
                           (>= (recursoAlmacenado Gas) 25))
                    (and (decrease (recursoAlmacenado Mineral) 75)
                    (decrease (recursoAlmacenado Gas) 25)
                    (increase (capacidadMaxima) 100)
                    (edificioEn ?edi ?loc)
                    (hayEdificio ?loc))
                )
                ; Genera la unidad en la localizacion indicada
            )
    )

    ; ----------------------------------------------------------------------------- ;
    ; RECLUTAR. Crea nuevas unidades
    ; ----------------------------------------------------------------------------- ;
    (:action Reclutar
        :parameters (?tipoU - tipoUnidades ?uni - Unidades ?tipoE - tipoEdificios ?loc - Localizaciones)
        :precondition
            (and
                (entrena ?tipoE ?tipoU)     ; vemos que edificio entrena a la unidad
                (unidadTipo ?uni ?tipoU)
                (investigado ?tipoU)        ; la unidad ya ha sido investigada
                (not (reclutada ?uni))

                ; El tipo de unidad tiene que cumplir que
                (exists
                    (?edi - Edificios)
                    (and
                    (edificioEn ?edi ?loc)      ; exista un edificio que la entrene
                    (edificioTipo ?edi ?tipoE))
                )
            )
        :effect
            ; Decrementamos la cantidad de recursos correspondiente a los distintos
            ; tipos de unidades
            (and
                (reclutada ?uni)
                (when (and (unidadTipo ?uni VCE)
                           (>= (recursoAlmacenado Mineral) 50))
                    (and (decrease (recursoAlmacenado Mineral) 50)
                    (unidadEn ?uni ?loc))
                )
                (when (and (unidadTipo ?uni Marine)
                           (>= (recursoAlmacenado Mineral) 50))
                    (and (decrease (recursoAlmacenado Mineral) 50)
                    (unidadEn ?uni ?loc))
                )
                (when (and (unidadTipo ?uni Segador)
                           (>= (recursoAlmacenado Mineral) 50)
                           (>= (recursoAlmacenado Gas) 50))
                    (and (decrease (recursoAlmacenado Mineral) 50)
                    (decrease (recursoAlmacenado Gas) 50)
                    (unidadEn ?uni ?loc))
                )
            )
    )

    ; ----------------------------------------------------------------------------- ;
    ; INVESTIGAR. Permite investigar nuevas unidades para crearlas posteriormente
    ; ----------------------------------------------------------------------------- ;
    (:action Investigar
        :parameters (?tipoU - tipoUnidades)
        :precondition
            (and
                (not (investigado ?tipoU))  ; no esta  investigada
                (investigacionDisponible)          
            )
        :effect
            ; Decrementamos la cantidad de recursos correspondiente a los distintos
            ; tipos de investigaciones
            (and
                (when (and (= ?tipoU Segador)
                           (>= (recursoAlmacenado Mineral) 50)
                           (>= (recursoAlmacenado Gas) 200))
                    (and (decrease (recursoAlmacenado Mineral) 50)
                    (decrease (recursoAlmacenado Gas) 200)
                    (investigado ?tipoU))
                )
            )
    )

    ; ----------------------------------------------------------------------------- ;
    ; RECOLECTAR. Recolecta los recursos de un nodo y los almacena
    ; ----------------------------------------------------------------------------- ;
    (:action Recolectar
        :parameters (?rec - tipoLocalizaciones)
        :precondition
            (and
                (<= (+(recursoAlmacenado ?rec) 50) (capacidadMaxima))
            )
        :effect
            (and
                ; Para todas las unidades creadas
                (forall(?uni - Unidades)
                    ; si es un VCE que esta extrayendo mineral, incrementa el mineral almacenado en 10
                    (when (and (extrayendoRecurso ?uni ?rec)
                                ; (<= (mineralAlmacenado) (+ (capacidadMaxima) 10))
                          )
                        (increase (recursoAlmacenado ?rec) 50)
                    )
                )
            )
    )

    ; ----------------------------------------------------------------------------- ;
    ; DESASIGNAR. Un VCE deja de extraer recursos de un nodo
    ; ----------------------------------------------------------------------------- ;
    (:action Desasignar
        :parameters (?vce - Unidades ?loc - Localizaciones ?rec - tipoLocalizaciones)
        :precondition
            (and
                (extrayendoEn ?vce ?loc)         ; comprueba si esta extrayendo
                (asignadoRecursoEn ?rec ?loc)    ; y que recurso esta generando
            )
        :effect
            (and
                (and (not (extrayendoEn ?vce ?loc))  ; desasigna el vce del recurso en el que estaba
                (not (extrayendoRecurso ?vce ?rec)))
            )
    )
    
    
    
    
    
    
    
)