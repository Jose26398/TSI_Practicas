(define (domain ejercicio1)
    (:requirements :strips :typing :negative-preconditions)
    (:types
        Unidades Edificios Localizaciones - object
        tipoUnidades tipoEdificios tipoLocalizaciones - constants
    )
    (:constants 
        VCE - tipoUnidades
        CentroDeMando Barracones - tipoEdificios
        Mineral Gas - tipoLocalizaciones
    )
    (:predicates
        (unidadTipo ?uni - Unidades ?tipo - tipoUnidades)
        (edificioTipo ?edi - Edificios ?tipo - tipoEdificios)
        (localizacionTipo ?loc - Localizaciones ?tipo - tipoLocalizaciones)

        (unidadEn ?uni - Unidades ?loc - Localizaciones)
        (edificioEn ?edi - Edificios ?loc - Localizaciones)

        (existeCamino ?loc1 - Localizaciones ?loc2 - Localizaciones)

        (asignarRecursoEn ?rec - tipoLocalizaciones ?loc - Localizaciones)

        (extrayendoEn ?vce - Unidades ?loc - Localizaciones)

        (necesitaRecurso ?edi - Edificios ?rec - tipoLocalizaciones)
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
        :parameters (?vce - Unidades ?loc - Localizaciones)
        :precondition 
            (and
                (unidadTipo ?vce VCE)
                (unidadEn ?vce ?loc)
                (not (extrayendoEn ?vce ?loc))
            )
        :effect 
            (and
                (extrayendoEn ?vce ?loc)
            )
    )

    (:action Construir
        :parameters (?vce - Unidades ?edi - Edificios ?loc - Localizaciones)
        :precondition
            (and
                (unidadTipo ?vce VCE)
                (unidadEn ?vce ?loc)
                (not (extrayendoEn ?vce ?loc))
                (exists (?vce2 - Unidades ?rec - Localizaciones ?loc2 - Localizaciones)
                        (and(extrayendoEn ?vce2 ?loc2)
                        (asignarRecursoEn Mineral ?loc2)
                        )
                )
            )
        :effect
            (and
                (edificioEn ?edi ?loc)
            )
    )
    
    
    
)