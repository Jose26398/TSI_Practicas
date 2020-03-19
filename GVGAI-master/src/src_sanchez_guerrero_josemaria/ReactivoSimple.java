package src_sanchez_guerrero_josemaria;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;
import java.util.ArrayList;

public class ReactivoSimple extends AbstractPlayer {

	// Declaracion de variables
    private Vector2d ultimaPos;
    
    Node initialState;
    Node goalState;
    
  	Vector2d fescala;
  	ArrayList<Vector2d> tiposObs = new ArrayList<>();
  	
  	
  	/**
  	 * initialize all variables for the agent
  	 * @param stateObs Observation of the current state.
     * @param elapsedTimer Timer when the action returned is due.
  	 */
  	public ReactivoSimple(StateObservation stateObs, ElapsedCpuTimer elapsedTimer){
  		// Calculamos el factor de escala entre mundos (pixeles -> grid)
        fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length , 
        		  stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);      
        
        // Ultima posicion del avatar
        ultimaPos = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
        initialState = new Node(ultimaPos);
        
        // Lista con las posiciones de los obstaculos
        ArrayList<Observation>[] obstaculos = stateObs.getImmovablePositions();
        for (int i = 0; i < obstaculos[0].size(); i++) {
        	Vector2d aux = obstaculos[0].get(i).position;
            tiposObs.add( new Vector2d(Math.floor(aux.x / fescala.x), Math.floor(aux.y / fescala.y)) );
        }

  	}

    
    @Override
    public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
    	
    	//Obtenemos la posicion del avatar
        Vector2d avatar = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);

        //Se determina el siguiente movimiento a partir de la posicion del avatar
        Types.ACTIONS siguienteAccion = sigMovimiento( simularAcciones(stateObs), avatar );

        //Se actualiza la ultima posici�n del avatar
        ultimaPos = avatar;

        return siguienteAccion;


    }
    

    /**
     * Funcion que determina el movimiento mas adecuado para alejarse del enemigo
     * partiendo de una posicion inicial. La funcion devolvera el mejor movimiento
     * posible dependiendo de la posicion de este, es decir, intentara maximizar
     * la distancia (Manhattan) entre este y el propio avatar.
     * 
     * @param stateObs estado del mapa para obtener las posiciones del avatar y enemigo.
     * @return Devuelve la siguiente posicion mas adecuada.
     */
    private Vector2d simularAcciones(StateObservation stateObs) {
    	
    	// Creamos un array de movimientos
    	ArrayList<Vector2d> moves = new ArrayList<Vector2d>();
    	
    	// Metemos en el todos los movimientos que puede hacer el avatar
        Vector2d top = stateObs.getAvatarPosition();
    	top.x = Math.floor(top.x / fescala.x);
    	top.y = Math.floor(top.y / fescala.y)-1;
    	
        Vector2d bottom = stateObs.getAvatarPosition();
        bottom.x = Math.floor(bottom.x / fescala.x);
    	bottom.y = Math.floor(bottom.y / fescala.y)+1;
    	
        Vector2d left = stateObs.getAvatarPosition();
        left.x = Math.floor(left.x / fescala.x)-1;
    	left.y = Math.floor(left.y / fescala.y);
    	
        Vector2d right = stateObs.getAvatarPosition();
        right.x = Math.floor(right.x / fescala.x)+1;
    	right.y = Math.floor(right.y / fescala.y);
    	
        Vector2d idle = stateObs.getAvatarPosition();
        idle.x = Math.floor(idle.x / fescala.x);
    	idle.y = Math.floor(idle.y / fescala.y);
        
    	// Comprobamos que ninguno de esos movimientos nos lleva a un obstaculo
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
        
        // Guardamos la informacion sobre el estado inicial
        double bestDistance = 0;
        Vector2d bestMove = null;
        
        // Para todos los movimientos posibles
        for (Vector2d move : moves) {
        
        	// Obtenemos la posicion del NPC
        	Vector2d npcPosition = stateObs.getNPCPositions()[0].get(0).position;
        	npcPosition.x = Math.floor(npcPosition.x / fescala.x);
        	npcPosition.y = Math.floor(npcPosition.y / fescala.y);
        
        	// Calculamos la distancia Manhattan
        	double actualDistance = Math.abs(move.x-npcPosition.x) + Math.abs(move.y-npcPosition.y);
            
        	// Comprobamos si la actual es mayor que la mejor
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
