package src_sanchez_guerrero_josemaria;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;
import tools.pathfinder.Node;
import tools.pathfinder.PathFinder;

import java.util.ArrayList;


public class Agent extends AbstractPlayer {

    //Objeto de clase Pathfinder
    private PathFinder pf;
    private ArrayList<Node> path = new ArrayList<>();
    private Vector2d ultimaPos;
    
    public long start;
    public long end;
    
    
    
    
  //Greedy Camel: 
  	// 1) Busca la puerta mas cercana. 
  	// 2) Escoge la accion que minimiza la distancia del camello a la puerta.

  	Vector2d fescala;
  	Vector2d portal;
  	
  	/**
  	 * initialize all variables for the agent
  	 * @param stateObs Observation of the current state.
       * @param elapsedTimer Timer when the action returned is due.
  	 */
  	public Agent(StateObservation stateObs, ElapsedCpuTimer elapsedTimer){
  		ArrayList<Integer> tiposObs = new ArrayList();
        ArrayList<Observation>[] obstaculos = stateObs.getImmovablePositions();
        for (ArrayList<Observation> obs : obstaculos) {
            tiposObs.add(obs.get(0).obsID);
        }
        tiposObs.add((int) 'o');

        //Se inicializa el objeto del pathfinder con las ids de los obstaculos
        pf = new PathFinder(tiposObs);
        pf.VERBOSE = false; // <- Activa o desactiva el modo la impresi�n del log

        //Se lanza el algoritmo de pathfinding para poder ser usado en la funci�n ACT
        pf.run(stateObs);
        
  		//Calculamos el factor de escala entre mundos (pixeles -> grid)
          fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length , 
          		stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);      
        
          //Se crea una lista de observaciones de portales, ordenada por cercania al avatar
          ArrayList<Observation>[] posiciones = stateObs.getPortalsPositions(stateObs.getAvatarPosition());
          //Seleccionamos el portal mas proximo
          portal = posiciones[0].get(0).position;
          portal.x = Math.floor(portal.x / fescala.x);
          portal.y = Math.floor(portal.y / fescala.y);

          //Ultima posici�n del avatar
          ultimaPos = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
  	}

    
    @Override
    public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
    	start = java.lang.System.currentTimeMillis();
        //Obtenemos la posicion del avatar
        Vector2d avatar = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
        //System.out.println("Posici�n del avatar: " + avatar.toString());
        //System.out.println("Ultima posici�n: " + ultimaPos);
        //System.out.println("Ultima acci�n: " + ultimaAccion);

        //Actualizamos el plan de ruta
        if (((avatar.x != ultimaPos.x) || (avatar.y != ultimaPos.y)) && !path.isEmpty()) {
            path.remove(0);
        }

        //Calculamos el numero de gemas que lleva encima
        int nGemas = 0;
        if (stateObs.getAvatarResources().isEmpty() != true) {
            nGemas = stateObs.getAvatarResources().get(6);
        }

        //Si no hay un plan de ruta calculado...
        if (path.isEmpty()) {
            //Si ya tiene todas las gemas se calcula uno al portal m�s cercano. Si no se calcula a la gema m�s cercana
            if (nGemas == 0) {
                Vector2d portal;

                //Se crea una lista de observaciones de portales, ordenada por cercania al avatar
                ArrayList<Observation>[] posiciones = stateObs.getPortalsPositions(stateObs.getAvatarPosition());

                //Se seleccionan el portal m�s cercano
                portal = posiciones[0].get(0).position;

                //Se le aplica el factor de escala para que las coordenas de pixel coincidan con las coordenadas del grig
                portal.x = portal.x / fescala.x;
                portal.y = portal.y / fescala.y;

                //Calculamos un camino desde la posici�n del avatar a la posici�n del portal
                path = pf.getPath(avatar, portal);
            } else {
                Vector2d gema;

                //Se crea una lista de observaciones, ordenada por cercania al avatar
                ArrayList<Observation>[] posiciones = stateObs.getResourcesPositions(stateObs.getAvatarPosition());

                //Se selecciona la gema m�s cercana
                gema = posiciones[0].get(0).position;

                //Se le aplica el factor de escala para que las coordenas de pixel coincidan con las coordenadas del grig
                gema.x = gema.x / fescala.x;
                gema.y = gema.y / fescala.y;

                //Calculamos un camino desde la posici�n del avatar a la posici�n de la gema
                path = pf.getPath(avatar, gema);
            }
        }

        if (path != null) {
            Types.ACTIONS siguienteAccion;
            Node siguientePos = path.get(0);

            //Se determina el siguiente movimiento a partir de la posici�n del avatar
            siguienteAccion = sigMovimiento(siguientePos, avatar);

            //Se actualiza la ultima posici�n del avatar
            ultimaPos = avatar;
            end = java.lang.System.currentTimeMillis();
            System.out.println("inicio " + start);
            System.out.println("final " + end + "\n");
            return siguienteAccion;

        } else {
            //Salida por defecto
            end = java.lang.System.currentTimeMillis();
            long total = end - start;
            System.out.println("inicio " + start);
            System.out.println("final " + end + "\n");
            return Types.ACTIONS.ACTION_NIL;
        }

    }

    private void simularAcciones(StateObservation stateObs) {
        //Obtenemos la lista de acciones disponible
        ArrayList<Types.ACTIONS> acciones = stateObs.getAvailableActions();

        //Guardamos la informaci�n sobre el estado inicial
        StateObservation viejoEstado = stateObs;

        for (Types.ACTIONS accion : acciones) {
            //Avanzamos el estado tras aplicarle una acci�n
            viejoEstado.advance(accion);

            //viejoEstado.somethingsomething(parametros);  <- Hacemos lo que queramos con el estado avanzado
            //Restauramos el estado para avanzarlo con otra de las acciones disponibles.
            viejoEstado = stateObs;
        }
    }

    private Types.ACTIONS sigMovimiento(Node siguientePos, Vector2d avatar) {
        Types.ACTIONS siguienteAccion;
        if (siguientePos.position.x != avatar.x) {
            if (siguientePos.position.x > avatar.x) {
                siguienteAccion = Types.ACTIONS.ACTION_RIGHT;
            } else {
                siguienteAccion = Types.ACTIONS.ACTION_LEFT;
            }
        } else {
            if (siguientePos.position.y > avatar.y) {
                siguienteAccion = Types.ACTIONS.ACTION_DOWN;
            } else {
                siguienteAccion = Types.ACTIONS.ACTION_UP;
            }
        }
        return siguienteAccion;
    }

}
