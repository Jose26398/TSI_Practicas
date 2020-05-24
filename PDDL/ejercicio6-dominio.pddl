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
    )

    (:functions 
        (mineralAlmacenado)
        (gasAlmacenado)
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
                    (generando ?rec))               ; aniadimos que se esta generando el recurso
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
                (not (exists (?otraLoc - Localizaciones) (edificioEn ?edi ?loc)) )  ; y no puede existir un edificio en
                                                                                    ; esa localizacion previamente
                (not (exists (?otroEd - Edificios)(edificioEn ?otroEd ?loc)) )

                ; El tipo de edificio tiene que cumplir que
                (exists
                    (?tipoE - tipoEdificios)
                    (and
                    (edificioTipo ?edi ?tipoE)
                    (forall (?rec - tipoLocalizaciones)  ; para todos los recursos existentes
                        (or
                            (not (necesitaE ?tipoE ?rec))    ; o bien, no necesita el recurso
                            (and (necesitaE ?tipoE ?rec)     ; o lo necesita
                                 (generando ?rec))           ; pero lo esta generando
                        )
                    )
                    )
                )
            )
        :effect
            ; Decrementamos la cantidad de recursos correspondiente a los distintos
            ; tipos de edificios (excepto el deposito que tambien aumenta la capacidad)
            (and
                (when (and (edificioTipo ?edi CentroDeMando)
                           (>= (mineralAlmacenado) 150)
                           (>= (gasAlmacenado) 50))
                    (and (decrease (mineralAlmacenado) 150)
                    (decrease (gasAlmacenado) 50)
                    (edificioEn ?edi ?loc))
                )
                (when (and (edificioTipo ?edi Barracones)
                           (>= (mineralAlmacenado) 150))
                    (and (decrease (mineralAlmacenado) 150)
                    (edificioEn ?edi ?loc))
                )
                (when (and (edificioTipo ?edi Extractor)
                           (>= (mineralAlmacenado) 75))
                    (and (decrease (mineralAlmacenado) 75)
                    (edificioEn ?edi ?loc))
                )
                (when (and (edificioTipo ?edi BahiaDeIngenieria)
                           (>= (mineralAlmacenado) 125))
                    (and (decrease (mineralAlmacenado) 125)
                    (edificioEn ?edi ?loc))
                )
                (when (and (edificioTipo ?edi Deposito)
                           (>= (mineralAlmacenado) 75)
                           (>= (gasAlmacenado) 25))
                    (and (decrease (mineralAlmacenado) 75)
                    (decrease (gasAlmacenado) 25)
                    (increase (capacidadMaxima) 100)
                    (edificioEn ?edi ?loc))
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

                ; Comprobamos que esta unidad no esta ya creada
                (not (exists (?loc2 - Localizaciones) (unidadEn ?uni ?loc2)))

                ; El tipo de unidad tiene que cumplir que
                (exists
                    (?edi - Edificios)
                    (and
                    (edificioEn ?edi ?loc)      ; exista un edificio que la entrene
                    (edificioTipo ?edi ?tipoE)

                    (forall (?rec - tipoLocalizaciones)  ; para todos los recursos existentes
                        (or
                            (not (necesitaU ?tipoU ?rec))    ; o bien, no necesita el recurso
                            (and (necesitaU ?tipoU ?rec)     ; o lo necesita
                                 (generando ?rec))           ; pero lo esta generando
                        )
                    )
                    )
                )
            )
        :effect
            ; Decrementamos la cantidad de recursos correspondiente a los distintos
            ; tipos de unidades
            (and
                (when (unidadTipo ?uni VCE)
                    (and (decrease (mineralAlmacenado) 50)
                    (unidadEn ?uni ?loc))
                )
                (when (unidadTipo ?uni Marine)
                    (and (decrease (mineralAlmacenado) 50)
                    (unidadEn ?uni ?loc))
                )
                (when (unidadTipo ?uni Segador)
                    (and (decrease (mineralAlmacenado) 50)
                    (decrease (gasAlmacenado) 50)
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
                
                (exists (?edi - Edificios ?loc - Localizaciones)
                    (and (edificioEn ?edi ?loc)
                    (edificioTipo ?edi BahiaDeIngenieria))  ; hay una bahia de ingenieria
                )

                (forall (?rec - tipoLocalizaciones)  ; para todos los recursos existentes
                        (or
                            (not (necesitaI ?tipoU ?rec))    ; o bien, no necesita el recurso
                            (and (necesitaI ?tipoU ?rec)     ; o lo necesita
                                 (generando ?rec))           ; pero lo esta generando
                        )
                    )
                            
            )
        :effect
            ; Decrementamos la cantidad de recursos correspondiente a los distintos
            ; tipos de investigaciones
            (and
                (when (and (= ?tipoU Segador)
                           (>= (mineralAlmacenado) 50)
                           (>= (gasAlmacenado) 200))
                    (and (decrease (mineralAlmacenado) 50)
                    (decrease (gasAlmacenado) 200)
                    (investigado ?tipoU))
                )
            )
    )

    ; ----------------------------------------------------------------------------- ;
    ; RECOLECTAR. Recolecta los recursos de un nodo y los almacena
    ; ----------------------------------------------------------------------------- ;
    (:action Recolectar
        :parameters (?loc - Localizaciones ?rec - tipoLocalizaciones)
        :precondition
            (and
                (exists (?vce - Unidades)               ; si existe una unidad vce
                    (and (extrayendoEn ?vce ?loc)       ; extrayendo un recurso en una localizacion
                    (asignadoRecursoEn ?rec ?loc))
                )
            )
        :effect
            (and
                ; Para todas las unidades creadas
                (forall(?uni - Unidades)
                    ; si es un VCE que esta extrayendo mineral, incrementa el mineral almacenado en 10
                    (when (and (= ?rec Mineral) (extrayendoEn ?uni ?loc) (unidadTipo ?uni VCE))
                        (increase (mineralAlmacenado) 10)
                    )
                )
                ; Para todas las unidades creadas
                (forall(?uni - Unidades)
                    ; si es un VCE que esta extrayendo gas, incrementa el gas almacenado en 10
                    (when (and (= ?rec Gas) (extrayendoEn ?uni ?loc) (unidadTipo ?uni VCE))
                        (increase (gasAlmacenado) 10)
                    )
                )
            )
    )

    ; ----------------------------------------------------------------------------- ;
    ; DESASIGNAR. Un VCE deja de extraer recursos de un nodo
    ; ----------------------------------------------------------------------------- ;
    (:action Desasignar
        :parameters (?vce - Unidades ?loc - Localizaciones)
        :precondition
            (and
                (extrayendoEn ?vce ?loc)    ; comprueba si esta extrayendo
            )
        :effect
            (and
                (not (extrayendoEn ?vce ?loc))
            )
    )
    
    
    
    
    
    
    
)