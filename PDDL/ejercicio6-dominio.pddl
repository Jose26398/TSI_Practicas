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

        ; Indica si la unidad ya esta investigada
        (investigado ?tipoU - tipoUnidades)
        
        
        ; MEJORAS DE OPTIMIZACION ;
        
        ; Indica si hay un edificio construido en una localizacion
        (hayEdificio ?loc - Localizaciones)

        ; Edificios que han sido construidos
        (construido ?edi - Edificios)

        ; Unidades que han sido reclutadas
        (reclutada ?uni - Unidades)

        ; Unidades que puede reclutar un tipo de edificio
        (puedeReclutarEn ?tipoU - tipoUnidades ?loc - Localizaciones)

        ; Recurso que esta extrayendo un VCE determinado
        (extrayendoRecurso ?vce - Unidades ?rec - tipoLocalizaciones)

        ; Indica si hay una bahia de ingenieria disponible para investigar
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
        :parameters (?vce - Unidades ?loc - Localizaciones ?rec - tipoLocalizaciones)
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
                        (not (= ?rec Gas))                  ; si no es un nodo de Gas
                        (exists (?ext - Edificios)          ; o si existe
                            (and (edificioEn ?ext ?loc)     ; un Extractor en la localizacion
                            (edificioTipo ?ext Extractor))
                        )
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
                (not (hayEdificio ?loc))        ; no puede haber un edificio en esa localizacion
                (not (construido ?edi))         ; el edificio a construir no puede estar ya construido
            )
        :effect
            ; Decrementamos la cantidad de recursos correspondiente a los distintos
            ; tipos de edificios (excepto el deposito que tambien aumenta la capacidad)
            (and
                (when
                    (and (edificioTipo ?edi CentroDeMando)
                        (>= (recursoAlmacenado Mineral) 150)
                        (>= (recursoAlmacenado Gas) 50)
                    )
                    (and (decrease (recursoAlmacenado Mineral) 150)
                         (decrease (recursoAlmacenado Gas) 50)
                         (puedeReclutarEn VCE ?loc)     ; unidad que se puede reclutar en ese edificio

                         ; Se construye el edificio correspondiente
                         (edificioEn ?edi ?loc) (hayEdificio ?loc) (construido ?edi))
                )

                (when
                    (and (edificioTipo ?edi Barracones)
                        (>= (recursoAlmacenado Mineral) 150)
                    )
                    (and (decrease (recursoAlmacenado Mineral) 150)
                         (puedeReclutarEn Marine ?loc)     ; unidades que se pueden reclutar en ese edificio
                         (puedeReclutarEn Segador ?loc)

                         ; Se construye el edificio correspondiente
                         (edificioEn ?edi ?loc) (hayEdificio ?loc) (construido ?edi))
                )

                (when
                    (and (edificioTipo ?edi Extractor)
                        (>= (recursoAlmacenado Mineral) 75)
                    )
                    (and (decrease (recursoAlmacenado Mineral) 75)

                         ; Se construye el edificio correspondiente                    
                         (edificioEn ?edi ?loc) (hayEdificio ?loc) (construido ?edi))
                )

                (when
                    (and (edificioTipo ?edi BahiaDeIngenieria)
                        (>= (recursoAlmacenado Mineral) 125)
                    )
                    (and (decrease (recursoAlmacenado Mineral) 125)
                         (investigacionDisponible)   ; ya se puede investigar
                         
                         ; Se construye el edificio correspondiente
                         (edificioEn ?edi ?loc) (hayEdificio ?loc) (construido ?edi))
                )

                (when 
                    (and (edificioTipo ?edi Deposito)
                        (>= (recursoAlmacenado Mineral) 75)
                        (>= (recursoAlmacenado Gas) 25)
                    )
                    (and (decrease (recursoAlmacenado Mineral) 75)
                         (decrease (recursoAlmacenado Gas) 25)
                         (increase (capacidadMaxima) 100)

                         ; Se construye el edificio correspondiente
                         (edificioEn ?edi ?loc) (hayEdificio ?loc) (construido ?edi))
                )
                
            )
    )

    ; ----------------------------------------------------------------------------- ;
    ; RECLUTAR. Crea nuevas unidades
    ; ----------------------------------------------------------------------------- ;
    (:action Reclutar
        :parameters (?tipoU - tipoUnidades ?uni - Unidades ?loc - Localizaciones)
        :precondition
            (and
                (unidadTipo ?uni ?tipoU)        ; obtenemos el tipo de la unidad
                (puedeReclutarEn ?tipoU ?loc)   ; comprobamos que el edificio que la recluta esta disponible
                (investigado ?tipoU)            ; la unidad ya ha sido investigada
                (not (reclutada ?uni))          ; y no ha sido reclutada previamente
            )
        :effect
            ; Decrementamos la cantidad de recursos correspondiente a los distintos
            ; tipos de unidades
            (and
                (when
                    (and (unidadTipo ?uni VCE)
                         (>= (recursoAlmacenado Mineral) 50)
                    )
                    (and (decrease (recursoAlmacenado Mineral) 50)
                         (unidadEn ?uni ?loc)   ; reclutamos la unidad
                         (reclutada ?uni)
                    )
                )

                (when
                    (and (unidadTipo ?uni Marine)
                         (>= (recursoAlmacenado Mineral) 50)
                    )
                    (and (decrease (recursoAlmacenado Mineral) 50)
                         (unidadEn ?uni ?loc)   ; reclutamos la unidad
                         (reclutada ?uni)
                    )
                )

                (when
                    (and (unidadTipo ?uni Segador)
                         (>= (recursoAlmacenado Mineral) 50)
                         (>= (recursoAlmacenado Gas) 50)
                    )
                    (and (decrease (recursoAlmacenado Mineral) 50)
                         (decrease (recursoAlmacenado Gas) 50)
                         (unidadEn ?uni ?loc)   ; recluta la unidad
                         (reclutada ?uni)
                    )
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
                (investigacionDisponible)   ; se puede investigar       
            )
        :effect
            ; Decrementamos la cantidad de recursos correspondiente a los distintos
            ; tipos de investigaciones
            (and
                (when
                    (and (= ?tipoU Segador)
                         (>= (recursoAlmacenado Mineral) 50)
                         (>= (recursoAlmacenado Gas) 200)
                    )
                    (and (decrease (recursoAlmacenado Mineral) 50)
                         (decrease (recursoAlmacenado Gas) 200)
                         (investigado ?tipoU)   ; investiga la unidad
                    )
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
                ; La recoleccion no sobrepasaria la capacidad maxima del almacenamiento
                (<= (+(recursoAlmacenado ?rec) 20) (capacidadMaxima))
            )
        :effect
            (and
                (forall(?uni - Unidades)    ; para todas las unidades creadas

                    ; Si es un VCE que esta extrayendo, incrementa su recurso almacenado en 20
                    (when (extrayendoRecurso ?uni ?rec)
                        (increase (recursoAlmacenado ?rec) 20)
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