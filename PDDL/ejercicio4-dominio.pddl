(define (domain ejercicio4)
    (:requirements :strips :typing :negative-preconditions :equality :conditional-effects :disjunctive-preconditions)

    (:types
        Unidades Edificios Localizaciones - object
        tipoUnidades tipoEdificios tipoLocalizaciones - constants
    )
    (:constants 
        VCE Marine Segador - tipoUnidades
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
        (necesitaE ?edi - tipoEdificios ?rec - tipoLocalizaciones)
        ; Recursos que necesita una unidad para ser creada
        (necesitaU ?uni - tipoUnidades ?rec - tipoLocalizaciones)

        ; Asociar la unidad con el edificio en la que es creada
        (entrena ?tipoE - tipoEdificios ?tipoU - tipoUnidades)
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
            (and
                (edificioEn ?edi ?loc)  ; construye el edificio en la localizacion indicada
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
            (and
                (unidadEn ?uni ?loc)    ; genera la unidad en la localizacion indicada
            )
    )
    
    
    
    
)