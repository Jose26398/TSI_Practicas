(define (problem starcraft)
    (:domain ejercicio6)
    (:objects 
        loc1_1 loc1_2 loc1_3 loc1_4 loc1_5 loc2_1 loc2_2 loc2_3 loc2_4 loc2_5 loc3_1 loc3_2 loc3_3 loc3_4 loc3_5 loc4_1 loc4_2 loc4_3 loc4_4 loc4_5 loc5_1 loc5_2 loc5_3 loc5_4 loc5_5 - Localizaciones
        
        mando1 - Edificios
        vce1 vce2 vce3 marine1 marine2 segador1 - Unidades

        mineral1 mineral2 mineral3 - Localizaciones
        gas1 gas2 - Localizaciones
        
        barracon1 - Edificios
        extractor1 - Edificios
        bahia1 - Edificios
    )
    (:init
        (edificioTipo mando1 CentroDeMando)
        (unidadTipo vce1 VCE)
        (unidadTipo vce2 VCE)
        (unidadTipo vce3 VCE)
        (unidadTipo marine1 Marine)
        (unidadTipo marine2 Marine)
        (unidadTipo segador1 Segador)

        (localizacionTipo mineral1 Mineral)
        (localizacionTipo mineral2 Mineral)
        (localizacionTipo mineral3 Mineral)
        (localizacionTipo gas1 Gas)
        (localizacionTipo gas2 Gas)

        (edificioTipo barracon1 Barracones)
        (edificioTipo extractor1 Extractor)
        (edificioTipo bahia1 BahiaDeIngenieria)


        (existeCamino loc1_1 loc2_1)
        (existeCamino loc2_1 loc1_1)
        (existeCamino loc1_1 loc1_2)
        (existeCamino loc1_2 loc1_1)
        (existeCamino loc1_2 loc2_2)
        (existeCamino loc2_2 loc1_2)
        (existeCamino loc1_2 loc1_3)
        (existeCamino loc1_3 loc1_2)
        (existeCamino loc1_2 loc1_1)
        (existeCamino loc1_1 loc1_2)
        (existeCamino loc1_3 loc2_3)
        (existeCamino loc2_3 loc1_3)
        (existeCamino loc1_3 loc1_4)
        (existeCamino loc1_4 loc1_3)
        (existeCamino loc1_3 loc1_2)
        (existeCamino loc1_2 loc1_3)
        (existeCamino loc1_4 loc2_4)
        (existeCamino loc2_4 loc1_4)
        (existeCamino loc1_4 loc1_5)
        (existeCamino loc1_5 loc1_4)
        (existeCamino loc1_4 loc1_3)
        (existeCamino loc1_3 loc1_4)
        (existeCamino loc1_5 loc2_5)
        (existeCamino loc2_5 loc1_5)
        (existeCamino loc1_5 loc1_4)
        (existeCamino loc1_4 loc1_5)
        (existeCamino loc2_1 loc1_1)
        (existeCamino loc1_1 loc2_1)
        (existeCamino loc2_1 loc3_1)
        (existeCamino loc3_1 loc2_1)
        (existeCamino loc2_1 loc2_2)
        (existeCamino loc2_2 loc2_1)
        (existeCamino loc2_2 loc1_2)
        (existeCamino loc1_2 loc2_2)
        (existeCamino loc2_2 loc3_2)
        (existeCamino loc3_2 loc2_2)
        (existeCamino loc2_2 loc2_3)
        (existeCamino loc2_3 loc2_2)
        (existeCamino loc2_2 loc2_1)
        (existeCamino loc2_1 loc2_2)
        (existeCamino loc2_3 loc1_3)
        (existeCamino loc1_3 loc2_3)
        (existeCamino loc2_3 loc3_3)
        (existeCamino loc3_3 loc2_3)
        (existeCamino loc2_3 loc2_4)
        (existeCamino loc2_4 loc2_3)
        (existeCamino loc2_3 loc2_2)
        (existeCamino loc2_2 loc2_3)
        (existeCamino loc2_4 loc1_4)
        (existeCamino loc1_4 loc2_4)
        (existeCamino loc2_4 loc3_4)
        (existeCamino loc3_4 loc2_4)
        (existeCamino loc2_4 loc2_5)
        (existeCamino loc2_5 loc2_4)
        (existeCamino loc2_4 loc2_3)
        (existeCamino loc2_3 loc2_4)
        (existeCamino loc2_5 loc1_5)
        (existeCamino loc1_5 loc2_5)
        (existeCamino loc2_5 loc3_5)
        (existeCamino loc3_5 loc2_5)
        (existeCamino loc2_5 loc2_4)
        (existeCamino loc2_4 loc2_5)
        (existeCamino loc3_1 loc2_1)
        (existeCamino loc2_1 loc3_1)
        (existeCamino loc3_1 loc4_1)
        (existeCamino loc4_1 loc3_1)
        (existeCamino loc3_1 loc3_2)
        (existeCamino loc3_2 loc3_1)
        (existeCamino loc3_2 loc2_2)
        (existeCamino loc2_2 loc3_2)
        (existeCamino loc3_2 loc4_2)
        (existeCamino loc4_2 loc3_2)
        (existeCamino loc3_2 loc3_3)
        (existeCamino loc3_3 loc3_2)
        (existeCamino loc3_2 loc3_1)
        (existeCamino loc3_1 loc3_2)
        (existeCamino loc3_3 loc2_3)
        (existeCamino loc2_3 loc3_3)
        (existeCamino loc3_3 loc4_3)
        (existeCamino loc4_3 loc3_3)
        (existeCamino loc3_3 loc3_4)
        (existeCamino loc3_4 loc3_3)
        (existeCamino loc3_3 loc3_2)
        (existeCamino loc3_2 loc3_3)
        (existeCamino loc3_4 loc2_4)
        (existeCamino loc2_4 loc3_4)
        (existeCamino loc3_4 loc4_4)
        (existeCamino loc4_4 loc3_4)
        (existeCamino loc3_4 loc3_5)
        (existeCamino loc3_5 loc3_4)
        (existeCamino loc3_4 loc3_3)
        (existeCamino loc3_3 loc3_4)
        (existeCamino loc3_5 loc2_5)
        (existeCamino loc2_5 loc3_5)
        (existeCamino loc3_5 loc4_5)
        (existeCamino loc4_5 loc3_5)
        (existeCamino loc3_5 loc3_4)
        (existeCamino loc3_4 loc3_5)
        (existeCamino loc4_1 loc3_1)
        (existeCamino loc3_1 loc4_1)
        (existeCamino loc4_1 loc5_1)
        (existeCamino loc5_1 loc4_1)
        (existeCamino loc4_1 loc4_2)
        (existeCamino loc4_2 loc4_1)
        (existeCamino loc4_2 loc3_2)
        (existeCamino loc3_2 loc4_2)
        (existeCamino loc4_2 loc5_2)
        (existeCamino loc5_2 loc4_2)
        (existeCamino loc4_2 loc4_3)
        (existeCamino loc4_3 loc4_2)
        (existeCamino loc4_2 loc4_1)
        (existeCamino loc4_1 loc4_2)
        (existeCamino loc4_3 loc3_3)
        (existeCamino loc3_3 loc4_3)
        (existeCamino loc4_3 loc5_3)
        (existeCamino loc5_3 loc4_3)
        (existeCamino loc4_3 loc4_4)
        (existeCamino loc4_4 loc4_3)
        (existeCamino loc4_3 loc4_2)
        (existeCamino loc4_2 loc4_3)
        (existeCamino loc4_4 loc3_4)
        (existeCamino loc3_4 loc4_4)
        (existeCamino loc4_4 loc5_4)
        (existeCamino loc5_4 loc4_4)
        (existeCamino loc4_4 loc4_5)
        (existeCamino loc4_5 loc4_4)
        (existeCamino loc4_4 loc4_3)
        (existeCamino loc4_3 loc4_4)
        (existeCamino loc4_5 loc3_5)
        (existeCamino loc3_5 loc4_5)
        (existeCamino loc4_5 loc5_5)
        (existeCamino loc5_5 loc4_5)
        (existeCamino loc4_5 loc4_4)
        (existeCamino loc4_4 loc4_5)
        (existeCamino loc5_1 loc4_1)
        (existeCamino loc4_1 loc5_1)
        (existeCamino loc5_1 loc5_2)
        (existeCamino loc5_2 loc5_1)
        (existeCamino loc5_2 loc4_2)
        (existeCamino loc4_2 loc5_2)
        (existeCamino loc5_2 loc5_3)
        (existeCamino loc5_3 loc5_2)
        (existeCamino loc5_2 loc5_1)
        (existeCamino loc5_1 loc5_2)
        (existeCamino loc5_3 loc4_3)
        (existeCamino loc4_3 loc5_3)
        (existeCamino loc5_3 loc5_4)
        (existeCamino loc5_4 loc5_3)
        (existeCamino loc5_3 loc5_2)
        (existeCamino loc5_2 loc5_3)
        (existeCamino loc5_4 loc4_4)
        (existeCamino loc4_4 loc5_4)
        (existeCamino loc5_4 loc5_5)
        (existeCamino loc5_5 loc5_4)
        (existeCamino loc5_4 loc5_3)
        (existeCamino loc5_3 loc5_4)
        (existeCamino loc5_5 loc4_5)
        (existeCamino loc4_5 loc5_5)
        (existeCamino loc5_5 loc5_4)
        (existeCamino loc5_4 loc5_5)

        (edificioEn mando1 loc2_2)
        (unidadEn vce1 loc2_2)

        (asignadoRecursoEn Mineral loc4_2)
        (asignadoRecursoEn Mineral loc5_2)
        (asignadoRecursoEn Mineral loc5_3)

        (asignadoRecursoEn Gas loc3_4)
        (asignadoRecursoEn Gas loc3_5)

        (necesitaE CentroDeMando Gas)
        (necesitaE CentroDeMando Mineral)
        (necesitaE Barracones Mineral)
        (necesitaE Extractor Mineral)
        (necesitaE BahiaDeIngenieria Gas)
        (necesitaE BahiaDeIngenieria Mineral)

        (necesitaU VCE Mineral)
        (necesitaU Marine Mineral)
        (necesitaU Segador Mineral)
        (necesitaU Segador Gas)

        (entrena CentroDeMando VCE)
        (entrena Barracones Marine)
        (entrena Barracones Segador)

        (investigado VCE)
        (investigado Marine)

        (necesitaI Segador Gas)
        (necesitaI Segador Mineral)

        (= (mineralAlmacenado) 0)
        (= (gasAlmacenado) 0)   
    )
    
    (:goal
        (and
            (unidadEn marine1 loc1_1)
            ; (unidadEn marine2 loc5_1)
            ; (unidadEn segador1 loc5_1)
            ; (unidadEn vce2 loc5_5)
        )
    )
)