(define (domain ejercicio2)
    (:requirements :strips :typing :negative-preconditions :equality :conditional-effects :disjunctive-preconditions)

    (:types
        Unidades Edificios Localizaciones - object
        tipoUnidades tipoEdificios tipoLocalizaciones - constants
    )
    (:constants 
        VCE - tipoUnidades
        CentroDeMando Barracones Extractor - tipoEdificios
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
        (necesita ?edi - tipoEdificios ?rec - tipoLocalizaciones)
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

                ; Tiene que existir otra unidad distinta tal que,
                (exists (?vce2 - Unidades ?rec - tipoLocalizaciones ?loc2 - Localizaciones ?tipoE - tipoEdificios)
                    (and
                        (extrayendoEn ?vce2 ?loc2)         ; este extrayendo en una localizacion
                        (asignadoRecursoEn ?rec ?loc2)     ; la cual este asignada a un recurso
                        (necesita ?tipoE ?rec)             ; y que el edificio a construir lo necesite
                        (edificioTipo ?edi ?tipoE)
                    )
                )
            )
        :effect
            (and
                (edificioEn ?edi ?loc)  ; construye el edificio en la localizacion indicada
            )
    )
    
    
    
)