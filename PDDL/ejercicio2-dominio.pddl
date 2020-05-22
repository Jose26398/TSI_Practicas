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
        (unidadTipo ?uni - Unidades ?tipo - tipoUnidades)
        (edificioTipo ?edi - Edificios ?tipo - tipoEdificios)
        (localizacionTipo ?loc - Localizaciones ?tipo - tipoLocalizaciones)

        (unidadEn ?uni - Unidades ?loc - Localizaciones)
        (edificioEn ?edi - Edificios ?loc - Localizaciones)

        (existeCamino ?loc1 - Localizaciones ?loc2 - Localizaciones)

        (asignadoRecursoEn ?rec - tipoLocalizaciones ?loc - Localizaciones)

        (extrayendoEn ?vce - Unidades ?loc - Localizaciones)
        (generando ?rec - tipoLocalizaciones)

        (necesita ?edi - tipoEdificios ?rec - tipoLocalizaciones)
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
                (unidadTipo ?vce VCE)   ; la unidad tiene que ser un VCE
                (unidadEn ?vce ?loc)    ; la unidad tiene que estar en la localizacion requerida
                (not (extrayendoEn ?vce ?loc))  ; no puede estar ocupada extrayendo
                (not (exists (?otraLoc - Localizaciones) (edificioEn ?edi ?loc)) )
                
                (exists (?vce2 - Unidades ?rec - tipoLocalizaciones ?loc2 - Localizaciones ?tipoE - tipoEdificios)
                    (and
                        (extrayendoEn ?vce2 ?loc2)
                        (asignadoRecursoEn ?rec ?loc2)
                        (necesita ?tipoE ?rec)
                        (edificioTipo ?edi ?tipoE)
                    )
                )
            )
        :effect
            (and
                (edificioEn ?edi ?loc)
            )
    )
    
    
    
)