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
        (unidadTipo ?uni - Unidades ?tipo - tipoUnidades)
        (edificioTipo ?edi - Edificios ?tipo - tipoEdificios)
        (localizacionTipo ?loc - Localizaciones ?tipo - tipoLocalizaciones)

        (unidadEn ?uni - Unidades ?loc - Localizaciones)
        (edificioEn ?edi - Edificios ?loc - Localizaciones)

        (existeCamino ?loc1 - Localizaciones ?loc2 - Localizaciones)

        (asignadoRecursoEn ?rec - tipoLocalizaciones ?loc - Localizaciones)

        (extrayendoEn ?vce - Unidades ?loc - Localizaciones)
        (generando ?rec - tipoLocalizaciones)

        (necesitaE ?tipoE - tipoEdificios ?rec - tipoLocalizaciones)
        (necesitaU ?uni - tipoUnidades ?rec - tipoLocalizaciones)

        (entrena ?tipoE - tipoEdificios ?tipoU - tipoUnidades)
)
    
    (:action Navegar
        :parameters (?uni - Unidades ?loc1 - Localizaciones ?loc2 - Localizaciones)
        :precondition
            (and
                (existeCamino ?loc1 ?loc2)
                (unidadEn ?uni ?loc1)
                (not (extrayendoEn ?uni ?loc1))
            )
        :effect
            (and
                (unidadEn ?uni ?loc2)
                (not (unidadEn ?uni ?loc1))
            )
    )

    (:action Asignar
        :parameters (?vce - Unidades ?loc - Localizaciones ?rec - tipoLocalizaciones ?ext - Edificios)
        :precondition 
            (and
                (unidadTipo ?vce VCE)
                (unidadEn ?vce ?loc)
                (not (extrayendoEn ?vce ?loc))
                (asignadoRecursoEn ?rec ?loc)
            )
        :effect 
            (and
                (when (or
                        (not (= ?rec Gas))
                        (and (edificioEn ?ext ?loc)
                        (edificioTipo ?ext Extractor))
                    )
                    (and (extrayendoEn ?vce ?loc)
                    (generando ?rec))
                )
            )
    )

    (:action Construir
        :parameters (?vce - Unidades ?edi - Edificios ?loc - Localizaciones)
        :precondition
            (and
                (unidadTipo ?vce VCE)           ; la unidad tiene que ser un VCE
                (unidadEn ?vce ?loc)            ; la unidad tiene que estar en la localizacion requerida
                (not (extrayendoEn ?vce ?loc))  ; no puede estar ocupada extrayendo
                (not (exists (?otraLoc - Localizaciones) (edificioEn ?edi ?loc)) )
                (not (exists (?otroEd - Edificios)(edificioEn ?otroEd ?loc)) )

                (exists
                    (?tipoE - tipoEdificios)
                    (and
                        (edificioTipo ?edi ?tipoE)
                        (forall (?rec - tipoLocalizaciones)
                            (or
                            (not (necesitaE ?tipoE ?rec))
                            (and
                                (necesitaE ?tipoE ?rec)
                                (generando ?rec)
                            )
                            )
                        )
                    )
                )
            )
        :effect
            (and
                (edificioEn ?edi ?loc)  ; construye el edificio
            )
    )

    (:action Reclutar
        :parameters (?tipoU - tipoUnidades ?uni - Unidades ?tipoE - tipoEdificios ?loc - Localizaciones)
        :precondition
            (and
                (entrena ?tipoE ?tipoU)
                (unidadTipo ?uni ?tipoU)

                ; Comprobamos que esta unidad no esta ya creada
                (not (exists (?loc2 - Localizaciones) (unidadEn ?uni ?loc2)))

                (exists
                    (?edi - Edificios)
                    (and
                        (edificioTipo ?edi ?tipoE)
                        (edificioEn ?edi ?loc)
                        (forall (?rec - tipoLocalizaciones)
                            (or
                            (not (necesitaU ?tipoU ?rec))
                            (and
                                (necesitaU ?tipoU ?rec)
                                (generando ?rec)
                            )
                            )
                        )
                    )
                )
            )
        :effect
            (and
                (unidadEn ?uni ?loc)
            )
    )
    
    
    
    
)