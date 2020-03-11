package src_sanchez_guerrero_josemaria;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

import java.util.ArrayList;

public class DeliberativoReactivo extends AbstractPlayer {

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
    

  	public DeliberativoReactivo(StateObservation stateObs, ElapsedCpuTimer elapsedTimer){
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
    	double actualDistance = distManhattan( stateObs.getAvatarPosition(), stateObs.getNPCPositions()[0].get(0).position );
    	for (int i = 1; i < stateObs.getNPCPositions()[0].size(); i++)
    		actualDistance *= distManhattan( stateObs.getAvatarPosition(), stateObs.getNPCPositions()[0].get(i).position );    

    	actualDistance = Math.pow(actualDistance, 1.0 / stateObs.getNPCPositions()[0].size());
    	
    	if (actualDistance/30 <= 6) { // wil die :(
    		//Obtenemos la posicion del avatar
            Vector2d avatar = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);

            Types.ACTIONS siguienteAccion = sigMovimiento( simularAcciones(stateObs), stateObs.getAvatarPosition() );

            //Se actualiza la ultima posici�n del avatar
            ultimaPos = avatar;
            
            path.clear();

            return siguienteAccion; 		
    	}
    	
    	else {
    		//Obtenemos la posicion del avatar
    		Vector2d avatar = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
    		
    		//Actualizamos el plan de ruta
    		if (((avatar.x != ultimaPos.x) || (avatar.y != ultimaPos.y)) && !path.isEmpty()) {
    			path.remove(0);
    		}
    		
    		if ( !path.isEmpty() ) {
    			
    		}
			Types.ACTIONS siguienteAccion;
			
			Node siguientePos = path.get(0);
			
			//Se determina el siguiente movimiento a partir de la posicion del avatar
			siguienteAccion = sigMovimiento(siguientePos.position, avatar);
			
			//Se actualiza la ultima posicion del avatar
			ultimaPos = avatar;
			
			return siguienteAccion;
    			
    	}

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
        	for (int i = 1; i < stateObs.getNPCPositions()[0].size(); i++)
        		actualDistance *= distManhattan( move, stateObs.getNPCPositions()[0].get(i).position );    

        	actualDistance = Math.pow(actualDistance, 1.0 / stateObs.getNPCPositions()[0].size()); 
        	
        	if (actualDistance > bestDistance) {
        		bestDistance = actualDistance;
        		bestMove = move;
        	}
            
        }
        return bestMove;
    }
    
    public double distManhattan(Vector2d pos1, Vector2d pos2) {
		return Math.abs(pos1.x-pos2.x) + Math.abs(pos1.y-pos2.y);
	}

}
