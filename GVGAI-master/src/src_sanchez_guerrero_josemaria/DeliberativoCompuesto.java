package src_sanchez_guerrero_josemaria;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

import java.util.ArrayList;

public class DeliberativoCompuesto extends AbstractPlayer {

    //Objeto de clase Pathfinder
    private IDAStar pf;
    private ArrayList<Node> path = new ArrayList<>();
    private Vector2d ultimaPos;
    
    Node initialState;
    Node goalState;

  	Vector2d fescala;
  	Vector2d gema;
  	Vector2d portal;
  	ArrayList<Vector2d> tiposObs = new ArrayList();
  	
  	/**
  	 * initialize all variables for the agent
  	 * @param stateObs Observation of the current state.
       * @param elapsedTimer Timer when the action returned is due.
  	 */
  	public DeliberativoCompuesto(StateObservation stateObs, ElapsedCpuTimer elapsedTimer){
  		//Calculamos el factor de escala entre mundos (pixeles -> grid)
        fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length , 
        		  stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);      
        

        //Ultima posicion del avatar
        ultimaPos = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
        initialState = new Node(ultimaPos);
        
        ArrayList<Observation>[] obstaculos = stateObs.getImmovablePositions();
        for (int i = 0; i < obstaculos[0].size(); i++) {
        	Vector2d aux = obstaculos[0].get(i).position;
            tiposObs.add( new Vector2d(Math.floor(aux.x / fescala.x), Math.floor(aux.y / fescala.y)) );
        }

        ArrayList<Observation>[] posicionesGemas = stateObs.getResourcesPositions(stateObs.getAvatarPosition());

        for (int i=0; i < posicionesGemas[0].size(); i++) {
        	gema = posicionesGemas[0].get(i).position;
        	gema.x = Math.floor(gema.x / fescala.x);
        	gema.y = Math.floor(gema.y / fescala.y);

        	//Se inicializa el objeto del pathfinder con las ids de los obstaculos
        	goalState = new Node(gema);
        	
        	//Calculamos un camino desde la posicion del avatar a la posicion del portal
            pf = new IDAStar(initialState, goalState, tiposObs);
            ArrayList<Node> aux = pf.getPath( pf.search() );
            aux.remove(0);
            path.addAll(aux);

            initialState = goalState;
        }

        
        //Se crea una lista de observaciones de portales, ordenada por cercania al avatar
        ArrayList<Observation>[] posicionPortal = stateObs.getPortalsPositions(stateObs.getAvatarPosition());
        //Seleccionamos el portal mas proximo
        portal = posicionPortal[0].get(0).position;
        portal.x = Math.floor(portal.x / fescala.x);
        portal.y = Math.floor(portal.y / fescala.y);
        
//        initialState = new Node(ultimaPos);
    	goalState = new Node(portal);
        
        //Calculamos un camino desde la posicion del avatar a la posicion del portal
    	pf = new IDAStar(initialState, goalState, tiposObs);
        ArrayList<Node> aux = pf.getPath( pf.search() );
        aux.remove(0);
        path.addAll(aux);
        
  	}

    
    @Override
    public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {

        //Obtenemos la posicion del avatar
        Vector2d avatar = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
        
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
