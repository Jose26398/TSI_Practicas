package src_sanchez_guerrero_josemaria;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

import java.util.Collections;
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
    	Vector2d npcPosition = stateObs.getNPCPositions()[0].get(0).position;
    	npcPosition.x = Math.floor(npcPosition.x / fescala.x);
    	npcPosition.y = Math.floor(npcPosition.y / fescala.y);
    	
    	double actualDistance = distManhattan(ultimaPos, npcPosition);
    	for (int i = 1; i < stateObs.getNPCPositions()[0].size(); i++) {
    		npcPosition = stateObs.getNPCPositions()[0].get(0).position;
        	npcPosition.x = Math.floor(npcPosition.x / fescala.x);
        	npcPosition.y = Math.floor(npcPosition.y / fescala.y);
        	actualDistance *= distManhattan(ultimaPos, npcPosition);    
    	}

    	actualDistance = Math.pow(actualDistance, 1.0 / stateObs.getNPCPositions()[0].size());
    	
    	if (actualDistance <= 6) {
    		//Obtenemos la posicion del avatar
            Vector2d avatar = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);

            Types.ACTIONS siguienteAccion = sigMovimiento( simularAcciones(stateObs), avatar );

            //Se actualiza la ultima posicion del avatar
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
    		
    		if ( path.isEmpty() ) {
    			initialState = new Node(avatar);
    			ArrayList<Observation>[] posicionesGemas = stateObs.getResourcesPositions(stateObs.getAvatarPosition());
    			if (posicionesGemas != null) {
    				Collections.shuffle(posicionesGemas[0]);
    			}

    			if (posicionesGemas != null) {
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
    			}

    	        
    	        //Se crea una lista de observaciones de portales, ordenada por cercania al avatar
    	        ArrayList<Observation>[] posicionPortal = stateObs.getPortalsPositions(stateObs.getAvatarPosition());
    	        //Seleccionamos el portal mas proximo
    	        portal = posicionPortal[0].get(0).position;
    	        portal.x = Math.floor(portal.x / fescala.x);
    	        portal.y = Math.floor(portal.y / fescala.y);
    	        
//    	        initialState = new Node(ultimaPos);
    	    	goalState = new Node(portal);
    	        
    	        //Calculamos un camino desde la posicion del avatar a la posicion del portal
    	    	pf = new IDAStar(initialState, goalState, tiposObs);
    	        ArrayList<Node> aux = pf.getPath( pf.search() );
    	        aux.remove(0);
    	        path.addAll(aux);
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
            
        	Vector2d npcPositions = stateObs.getNPCPositions()[0].get(0).position;
        	npcPositions.x = Math.floor(npcPositions.x / fescala.x);
        	npcPositions.y = Math.floor(npcPositions.y / fescala.y);
        	double actualDistance = distManhattan( move, npcPositions );
        	int i = 1;
        	while( i < stateObs.getNPCPositions()[0].size() ) {
        		npcPositions = stateObs.getNPCPositions()[0].get(i).position;
	        	npcPositions.x = Math.floor(npcPositions.x / fescala.x);
	        	npcPositions.y = Math.floor(npcPositions.y / fescala.y);
        		actualDistance *= distManhattan( move, npcPositions );
        		i++;
        	} 

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
