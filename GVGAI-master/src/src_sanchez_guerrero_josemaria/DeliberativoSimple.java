package src_sanchez_guerrero_josemaria;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;
import src_sanchez_guerrero_josemaria.Node;

import java.util.ArrayList;
import java.util.List;

public class DeliberativoSimple extends AbstractPlayer {

    //Objeto de clase Pathfinder
    private IDAStar pf;
    private ArrayList<Node> path = new ArrayList<>();
    private Vector2d ultimaPos;
    
    
    
    
  //Greedy Camel: 
  	// 1) Busca la puerta mas cercana. 
  	// 2) Escoge la accion que minimiza la distancia del camello a la puerta.

  	Vector2d fescala;
  	Vector2d portal;
    ArrayList<Vector2d> tiposObs = new ArrayList();
  	
  	/**
  	 * initialize all variables for the agent
  	 * @param stateObs Observation of the current state.
     * @param elapsedTimer Timer when the action returned is due.
  	 */
  	public DeliberativoSimple(StateObservation stateObs, ElapsedCpuTimer elapsedTimer){
  		//Calculamos el factor de escala entre mundos (pixeles -> grid)
        fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length , 
        		  stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);      
        
        //Se crea una lista de observaciones de portales, ordenada por cercania al avatar
        ArrayList<Observation>[] posiciones = stateObs.getPortalsPositions(stateObs.getAvatarPosition());
        //Seleccionamos el portal mas proximo
        portal = posiciones[0].get(0).position;
        portal.x = Math.floor(portal.x / fescala.x);
        portal.y = Math.floor(portal.y / fescala.y);

        //Ultima posición del avatar
        ultimaPos = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
        
        ArrayList<Observation>[] obstaculos = stateObs.getImmovablePositions();
        for (int i = 0; i < obstaculos[0].size(); i++) {
        	Vector2d aux = obstaculos[0].get(i).position;
            tiposObs.add( new Vector2d(Math.floor(aux.x / fescala.x), Math.floor(aux.y / fescala.y)) );
        }

        //Se lanza el algoritmo de pathfinding para poder ser usado en la función ACT
//        pf.search();
      
        //Se inicializa el objeto del pathfinder con las ids de los obstaculos
        Node initialState = new Node(ultimaPos);
        Node goalState = new Node(portal);
        
        //Calculamos un camino desde la posición del avatar a la posición del portal
        pf = new IDAStar(initialState, goalState, tiposObs);
        path = pf.getPath( pf.search() );
        path.remove(0);
        
  	}

    
    @Override
    public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
        //Obtenemos la posicion del avatar
        Vector2d avatar = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
        //System.out.println("Posición del avatar: " + avatar.toString());
        //System.out.println("Ultima posición: " + ultimaPos);
        //System.out.println("Ultima acción: " + ultimaAccion);
        
//        if (stateObs.getGameTick() == 5) {
//        	path.clear();
//        }
        
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
            //Se inicializa el objeto del pathfinder con las ids de los obstaculos
            Node initialState = new Node(ultimaPos);
            Node goalState = new Node(portal);
            
            //Calculamos un camino desde la posición del avatar a la posición del portal
            pf = new IDAStar(initialState, goalState, tiposObs);
            path = pf.getPath( pf.search() );            
        }

        if (path != null) {
            Types.ACTIONS siguienteAccion;
          
            Node siguientePos = path.get(0);

            //Se determina el siguiente movimiento a partir de la posición del avatar
            siguienteAccion = sigMovimiento(siguientePos, avatar);

            //Se actualiza la ultima posición del avatar
            ultimaPos = avatar;

            return siguienteAccion;

        } else {
            //Salida por defecto
            return Types.ACTIONS.ACTION_NIL;
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
