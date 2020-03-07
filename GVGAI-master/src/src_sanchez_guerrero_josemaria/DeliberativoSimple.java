package src_sanchez_guerrero_josemaria;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;
import tools.pathfinder.PathFinder;
import src_sanchez_guerrero_josemaria.Node;

import java.util.ArrayList;
import java.util.List;

public class DeliberativoSimple extends AbstractPlayer {

    //Objeto de clase Pathfinder
    private IDAStar pf;
    private ArrayList<Node> path = new ArrayList<>();
    private Vector2d ultimaPos;
    
    long start;
    long end;    
    
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

        //Ultima posicion del avatar
        ultimaPos = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
        
        ArrayList<Observation>[] obstaculos = stateObs.getImmovablePositions();
        for (int i = 0; i < obstaculos[0].size(); i++) {
        	Vector2d aux = obstaculos[0].get(i).position;
            tiposObs.add( new Vector2d(Math.floor(aux.x / fescala.x), Math.floor(aux.y / fescala.y)) );
        }

        //Se inicializa el objeto del pathfinder con las ids de los obstaculos
        Node initialState = new Node(ultimaPos);
        Node goalState = new Node(portal);
        
        //Calculamos un camino desde la posicion del avatar a la posicion del portal
        pf = new IDAStar(initialState, goalState, tiposObs);
        path = pf.getPath( pf.search() );
        path.remove(0);
  	}

    
    @Override
    public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
    	start = System.currentTimeMillis();

        //Obtenemos la posicion del avatar
        Vector2d avatar = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
        
//        if (stateObs.getGameTick() == 4) {
//        	path.clear();
//        }
        
        //Actualizamos el plan de ruta
        if (((avatar.x != ultimaPos.x) || (avatar.y != ultimaPos.y)) && !path.isEmpty()) {
            path.remove(0);
        }

        if (path != null) {
            Types.ACTIONS siguienteAccion;
          
            Node siguientePos = path.get(0);

            //Se determina el siguiente movimiento a partir de la posicion del avatar
            siguienteAccion = sigMovimiento(siguientePos, avatar);

            //Se actualiza la ultima posicion del avatar
            ultimaPos = avatar;
            
    		end = System.currentTimeMillis();
    		System.out.println("tick: " + stateObs.getGameTick() + " -- milisegundos: " + (end-start));
            return siguienteAccion;

        } else {
    		end = System.currentTimeMillis();
            System.out.println("tick: " + stateObs.getGameTick() + " -- milisegundos: " + (end-start));
            
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
