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
import java.util.List;

public class ReactivoSimple extends AbstractPlayer {

    private Vector2d ultimaPos;
    
    Node initialState;
    Node goalState;
    
  	Vector2d fescala;
  	ArrayList<Vector2d> tiposObs = new ArrayList();
  	
  	/**
  	 * initialize all variables for the agent
  	 * @param stateObs Observation of the current state.
       * @param elapsedTimer Timer when the action returned is due.
  	 */
  	public ReactivoSimple(StateObservation stateObs, ElapsedCpuTimer elapsedTimer){
  		//Calculamos el factor de escala entre mundos (pixeles -> grid)
        fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length , 
        		  stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);      
        

        //Ultima posicion del avatar
        ultimaPos = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
        initialState = new Node(ultimaPos);
        
        ArrayList<Observation>[] obstaculos = stateObs.getImmovablePositions();
        for (int i = 0; i < obstaculos[0].size(); i++) {
        	Vector2d aux = obstaculos[0].get(i).position;
            tiposObs.add( new Vector2d(aux.x, aux.y) );
        }

  	}

    
    @Override
    public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
        //Obtenemos la posicion del avatar
        Vector2d avatar = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);

        Types.ACTIONS siguienteAccion = sigMovimiento( simularAcciones(stateObs), stateObs.getAvatarPosition() );

        //Se actualiza la ultima posici�n del avatar
        ultimaPos = avatar;

        return siguienteAccion;


    }

    private Vector2d simularAcciones(StateObservation stateObs) {        
        ArrayList<Vector2d> moves = new ArrayList<Vector2d>();
        Vector2d top = new Vector2d(stateObs.getAvatarPosition().x, stateObs.getAvatarPosition().y-30);
        Vector2d bottom = new Vector2d(stateObs.getAvatarPosition().x, stateObs.getAvatarPosition().y+30);
        Vector2d left = new Vector2d(stateObs.getAvatarPosition().x-30, stateObs.getAvatarPosition().y);
        Vector2d right = new Vector2d(stateObs.getAvatarPosition().x+30, stateObs.getAvatarPosition().y);
        Vector2d idle = new Vector2d(stateObs.getAvatarPosition().x, stateObs.getAvatarPosition().y);
        
        if (!tiposObs.contains( top )) {
    		moves.add(top);
    	}
    	if (!tiposObs.contains( bottom )) {
    		moves.add(bottom);
    	}
    	if (!tiposObs.contains( left )) {
    		moves.add(left);
    	}
    	if (!tiposObs.contains( right )) {
    		moves.add(right);
    	}
    	moves.add(idle);
        
        //Guardamos la informaci�n sobre el estado inicial
        double bestDistance = 0;
        Vector2d bestMove = null;
                
        for (Vector2d move : moves) {
            
            double actualDistance = distManhattan( move, stateObs.getNPCPositions()[0].get(0).position );
            if (actualDistance > bestDistance) {
            	bestDistance = actualDistance;
            	bestMove = move;
            }
            
        }
        return bestMove;
    }

    private Types.ACTIONS sigMovimiento(Vector2d siguientePos, Vector2d avatar) {
        Types.ACTIONS siguienteAccion;
        if (siguientePos.x != avatar.x) {
            if (siguientePos.x > avatar.x) {
                siguienteAccion = Types.ACTIONS.ACTION_RIGHT;
            } else {
                siguienteAccion = Types.ACTIONS.ACTION_LEFT;
            }
        } else if (siguientePos.y == avatar.y){
        	siguienteAccion = Types.ACTIONS.ACTION_NIL;
        }
        else {
            if (siguientePos.y > avatar.y) {
                siguienteAccion = Types.ACTIONS.ACTION_DOWN;
            } else {
                siguienteAccion = Types.ACTIONS.ACTION_UP;
            }
        }
        return siguienteAccion;
    }
    
    public double distManhattan(Vector2d pos1, Vector2d pos2) {
		return Math.abs(pos1.x-pos2.x) + Math.abs(pos1.y-pos2.y);
	}

}
