package src_sanchez_guerrero_josemaria;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;
import java.util.ArrayList;


public class Agent extends AbstractPlayer {

	// Declaracion de variables
    private IDAStar pf;
    private ArrayList<Node> path = new ArrayList<>();
    private Vector2d lastPos;
    
    Node initialState;
    Node goalState;

  	Vector2d fescala;
  	Vector2d gem;
  	
  	boolean onlyEnemies = false;
  	boolean notEnemies = false;
  	
  	Vector2d portal;
  	ArrayList<Vector2d> obstacles = new ArrayList<>();
    

  	public Agent(StateObservation stateObs, ElapsedCpuTimer elapsedTimer){
  		
  		// Calculamos el factor de escala entre mundos (pixeles -> grid)
        fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length , 
        		  stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);      
        
        // Ultima posicion del avatar
        lastPos = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
        initialState = new Node(lastPos);
        
        // Obtenemos el array con los muros del mapa
        ArrayList<Observation>[] obs = stateObs.getImmovablePositions();
        for (int i = 0; i < obs[0].size(); i++) {
        	Vector2d aux = obs[0].get(i).position;
            obstacles.add( new Vector2d(Math.floor(aux.x / fescala.x), Math.floor(aux.y / fescala.y)) );
        }

        // Comprobamos si en el mapa solo hay enemigos (sin gemas)
    	if ( stateObs.getNPCPositions() != null && stateObs.getResourcesPositions() == null ) {
    		onlyEnemies = true;
    	}
    	
    	// Comprobamos si hay enemigos o no
    	if (stateObs.getNPCPositions() == null) {
    		notEnemies = true;
    	}

    	
    	// Se crea una lista de observaciones de gemas, ordenada por cercania al avatar
        ArrayList<Observation>[] gemsPositions = stateObs.getResourcesPositions(stateObs.getAvatarPosition());
        
        if (gemsPositions != null) {

        	// Guardo las gemas obtenidas para ir por el camino optimo
	        ArrayList<Vector2d> gemsVisited = new ArrayList<Vector2d>();
	        int numGems = new Integer(gemsPositions[0].size());
        
	        for (int i=0; i < numGems; i++) {
	        	
	        	// Elegimos la mas cercana a la posicion relativa
	        	gem = gemsPositions[0].get(0).position;
	        	// Aniadimos al array de gemsVisited
	        	gemsVisited.add(new Vector2d(gemsPositions[0].get(0).position));
	        	
	        	gem.x = Math.floor(gem.x / fescala.x);
	        	gem.y = Math.floor(gem.y / fescala.y);
	        	
	        	// Se inicializa el objeto del pathfinder con las ids de los obstaculos
	        	goalState = new Node(gem);
	        	
	        	//Se inicializa el objeto del pathfinder con las ids de los obstaculos
	            pf = new IDAStar(initialState, goalState, obstacles);
	            //Calculamos un camino desde la posicion del avatar a la posicion de la gema
	            ArrayList<Node> aux = pf.getPath( pf.search() );
	            // Quitamos el primero, ya que estamos en el
	            aux.remove(0);
	            // Lo aniadimos al path completo que pasa por todas las gemas
	            path.addAll(aux);
	            
	            // Actualizamos la posicion
	            initialState = goalState;
	            
	            // Actualizamos posicion relativa y eliminamos las ya visitadas
	            gemsPositions = stateObs.getResourcesPositions( goalState.getPosition() );
	            while( gemsVisited.contains(gemsPositions[0].get(0).position) && i!=(numGems-1) ){
	            	gemsPositions[0].remove(0);
	            }
	            
	        }
        }
        
        //Se crea una lista de observaciones de portales, ordenada por cercania al avatar
        ArrayList<Observation>[] portalPosition = stateObs.getPortalsPositions(stateObs.getAvatarPosition());

        //Seleccionamos el portal mas proximo
        portal = portalPosition[0].get(0).position;
        portal.x = Math.floor(portal.x / fescala.x);
        portal.y = Math.floor(portal.y / fescala.y);
        
        // Creamos nodo con la posicion obtenida
    	goalState = new Node(portal);
        
    	//Se inicializa el objeto del pathfinder con las ids de los obstaculos
        pf = new IDAStar(initialState, goalState, obstacles);
        //Calculamos un camino desde la posicion del avatar a la posicion de la gema
        ArrayList<Node> aux = pf.getPath( pf.search() );
        // Quitamos el primero, ya que estamos en el
        aux.remove(0);
        // Lo aniadimos al path completo que pasa por todas las gemas
        path.addAll(aux);
        
  	}

    
    @Override
    public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
    	
    	// REACTIVOS -- SOLO HAY ENEMIGOS
    	if (onlyEnemies) {
    		// Obtenemos la posicion del avatar
            Vector2d avatar = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);

            // Se determina el siguiente movimiento a partir de la posicion del avatar
            Types.ACTIONS nextAction = nextMove( simulateActions(stateObs), avatar );

            // Se actualiza la ultima posici�n del avatar
            lastPos = avatar;

            return nextAction;
    	}
    	
    	// DELIBERATIVOS -- SIN ENEMIGOS
    	else if (notEnemies) {
    		// Obtenemos la posicion del avatar
            Vector2d avatar = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
                    
            // Actualizamos el plan de ruta
            if (((avatar.x != lastPos.x) || (avatar.y != lastPos.y)) && !path.isEmpty()) {
                path.remove(0);
            }
            
    		Types.ACTIONS nextAction;
            
            // Obtenemos la primera posicion registrada en el path
            Node nextPos = path.get(0);

            //Se determina el siguiente movimiento a partir de la posicion del avatar
            nextAction = nextMove(nextPos.getPosition(), avatar);

            //Se actualiza la ultima posicion del avatar
            lastPos = avatar;

            return nextAction;
    	}
    	
    	// COMPUESTO -- ENEMIGOS O NO
    	else{	
	    	// Antes de realizar la siguiente accion del path, calculamos la distancia a los enemigos
	    	// Obtenemos las posiciones del primer NPC
	    	Vector2d npcPositions = stateObs.getNPCPositions()[0].get(0).position;
	    	npcPositions.x = Math.floor(npcPositions.x / fescala.x);
	    	npcPositions.y = Math.floor(npcPositions.y / fescala.y);
	    	
	    	// Calculamos la distancia
	    	double actualDistance = Math.abs(lastPos.x-npcPositions.x) + Math.abs(lastPos.y-npcPositions.y);
	    	
	    	for (int i = 1; i < stateObs.getNPCPositions()[0].size(); i++) {
	    		npcPositions = stateObs.getNPCPositions()[0].get(i).position;
	        	npcPositions.x = Math.floor(npcPositions.x / fescala.x);
	        	npcPositions.y = Math.floor(npcPositions.y / fescala.y);
	    		actualDistance *= Math.abs(lastPos.x-npcPositions.x) + Math.abs(lastPos.y-npcPositions.y);    
	    	}
	
	    	// Hacemos la media geometrica
	    	actualDistance = Math.pow(actualDistance, 1.0 / stateObs.getNPCPositions()[0].size());
	    	
	    	// Comprobamos si estamos a una distancia considerable del enemigo
	    	if (actualDistance <= (6*stateObs.getNPCPositions()[0].size()) ) {
	    		
	    		// Obtenemos la posicion del avatar
	            Vector2d avatar = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
	
	            // Se determina el siguiente movimiento a partir de la posicion del avatar
	            Types.ACTIONS nextAction = nextMove( simulateActions(stateObs), avatar );
	
	            // Se actualiza la ultima posicion del avatar
	            lastPos = avatar;
	            
	            // Limpiamos el path actual
	            path.clear();
	            
	            return nextAction;		
	    	}
	    	
	    	else {
	    		//Obtenemos la posicion del avatar
	    		Vector2d avatar = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
	    		
	    		//Actualizamos el plan de ruta
	    		if (((avatar.x != lastPos.x) || (avatar.y != lastPos.y)) && !path.isEmpty()) {
	    			path.remove(0);
	    		}
	    		
	    		// Si el path esta vacio
	    		if ( path.isEmpty() ) {
	    			
	    			initialState = new Node(avatar);
	    			
	    			// Se crea una lista de observaciones de gemas, ordenada por cercania al avatar
	    	        ArrayList<Observation>[] gemsPositions = stateObs.getResourcesPositions(stateObs.getAvatarPosition());
	    	        
	    	        if (gemsPositions != null) {

	    	        	// Guardo las gemas obtenidas para ir por el camino optimo
	    		        ArrayList<Vector2d> gemsVisited = new ArrayList<Vector2d>();
	    		        int numGems = new Integer(gemsPositions[0].size());
	    	        
	    		        for (int i=0; i < numGems; i++) {
	    		        	
	    		        	// Elegimos la mas cercana a la posicion relativa
	    		        	gem = gemsPositions[0].get(0).position;
	    		        	// Aniadimos al array de gemsVisited
	    		        	gemsVisited.add(new Vector2d(gemsPositions[0].get(0).position));
	    		        	
	    		        	gem.x = Math.floor(gem.x / fescala.x);
	    		        	gem.y = Math.floor(gem.y / fescala.y);
	    		        	
	    		        	// Se inicializa el objeto del pathfinder con las ids de los obstaculos
	    		        	goalState = new Node(gem);
	    		        	
	    		        	//Se inicializa el objeto del pathfinder con las ids de los obstaculos
	    		            pf = new IDAStar(initialState, goalState, obstacles);
	    		            //Calculamos un camino desde la posicion del avatar a la posicion de la gema
	    		            ArrayList<Node> aux = pf.getPath( pf.search() );
	    		            // Quitamos el primero, ya que estamos en el
	    		            aux.remove(0);
	    		            // Lo aniadimos al path completo que pasa por todas las gemas
	    		            path.addAll(aux);
	    		            
	    		            // Actualizamos la posicion
	    		            initialState = goalState;
	    		            
	    		            // Actualizamos posicion relativa y eliminamos las ya visitadas
	    		            gemsPositions = stateObs.getResourcesPositions( goalState.getPosition() );
	    		            while( gemsVisited.contains(gemsPositions[0].get(0).position) && i!=(numGems-1) ){
	    		            	gemsPositions[0].remove(0);
	    		            }
	    		            
	    		        }
	    	        }
	
	    	        
	    			//Se crea una lista de observaciones de portales, ordenada por cercania al avatar
	    	        ArrayList<Observation>[] portalPosition = stateObs.getPortalsPositions(stateObs.getAvatarPosition());
	
	    	        //Seleccionamos el portal mas proximo
	    	        portal = portalPosition[0].get(0).position;
	    	        portal.x = Math.floor(portal.x / fescala.x);
	    	        portal.y = Math.floor(portal.y / fescala.y);
	    	        
	    	        // Creamos nodo con la posicion obtenida
	    	    	goalState = new Node(portal);
	    	        
	    	    	//Se inicializa el objeto del pathfinder con las ids de los obstaculos
	    	        pf = new IDAStar(initialState, goalState, obstacles);
	    	        //Calculamos un camino desde la posicion del avatar a la posicion de la gema
	    	        ArrayList<Node> aux = pf.getPath( pf.search() );
	    	        // Quitamos el primero, ya que estamos en el
	    	        aux.remove(0);
	    	        // Lo aniadimos al path completo que pasa por todas las gemas
	    	        path.addAll(aux);
	    		}
	    		
	    		Types.ACTIONS nextAction;
	            
	            // Obtenemos la primera posicion registrada en el path
	            Node nextPos = path.get(0);
	
	            //Se determina el siguiente movimiento a partir de la posicion del avatar
	            nextAction = nextMove(nextPos.getPosition(), avatar);
	
	            //Se actualiza la ultima posicion del avatar
	            lastPos = avatar;

	            return nextAction;
	    			
	    	}
    	
    	}

    }

    
    /**
     * Funcion que determina la siguiente accion a partir del siguiente nodo.
     * @param nextPos Posicion de la siguiente accion.
     * @param avatar Posicion actual del avatar.
     * @return Tipo accion que lee el agente GVGAI.
     */
    private Types.ACTIONS nextMove(Vector2d nextPos, Vector2d avatar) {
        Types.ACTIONS nextAction;
        if (nextPos.x != avatar.x) {
            if (nextPos.x > avatar.x) {
                nextAction = Types.ACTIONS.ACTION_RIGHT;
            } else {
                nextAction = Types.ACTIONS.ACTION_LEFT;
            }
            
        } else if (nextPos.y == avatar.y){
        	nextAction = Types.ACTIONS.ACTION_NIL;
        }
        
        else {
            if (nextPos.y > avatar.y) {
                nextAction = Types.ACTIONS.ACTION_DOWN;
            } else {
                nextAction = Types.ACTIONS.ACTION_UP;
            }
        }
        
        return nextAction;
    }
    
    
    /**
     * Funcion que determina el movimiento mas adecuado para alejarse de los enemigos
     * partiendo de una posicion inicial. La funcion devolvera el mejor movimiento
     * posible dependiendo de la posicion de estos, es decir, intentara maximizar
     * la distancia (Manhattan) entre estos y el propio avatar.
     * 
     * @param stateObs estado del mapa para obtener las posiciones del avatar y enemigo.
     * @return Devuelve la siguiente posicion mas adecuada.
     */
    private Vector2d simulateActions(StateObservation stateObs) { 
    	
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
        if (!obstacles.contains( top )) {
    		moves.add(top);
    	}
    	if (!obstacles.contains( bottom )) {
    		moves.add(bottom);
    	}
    	if (!obstacles.contains( left )) {
    		moves.add(left);
    	}
    	if (!obstacles.contains( right )) {
    		moves.add(right);
    	}
    	if (distManhattan(idle, stateObs.getNPCPositions(idle)[0].get(0).position) > 4)
    		moves.add(idle);
        
        // Guardamos la informacion sobre el estado inicial
        double bestDistance = 0;
        Vector2d bestMove = null;
                
        // Para todos los movimientos posibles
        for (Vector2d move : moves) {
        
        	// Obtenemos las posiciones del primer NPC
        	// Lo hacemos asi ya que utilizamos la media geometrica
        	Vector2d npcPositions = stateObs.getNPCPositions()[0].get(0).position;
        	npcPositions.x = Math.floor(npcPositions.x / fescala.x);
        	npcPositions.y = Math.floor(npcPositions.y / fescala.y);
        	
        	// Calculamos la distancia
        	double actualDistance = distManhattan( move, npcPositions );
        	
        	// Repetimos para el resto de enemigos que haya en el mapa
        	int i = 1;
        	while( i < stateObs.getNPCPositions()[0].size() ) {
        		npcPositions = stateObs.getNPCPositions()[0].get(i).position;
	        	npcPositions.x = Math.floor(npcPositions.x / fescala.x);
	        	npcPositions.y = Math.floor(npcPositions.y / fescala.y);
        		actualDistance *= distManhattan( move, npcPositions );
        		i++;
        	} 

        	// Hacemos la media geometrica
        	actualDistance = Math.pow(actualDistance, 1.0 / stateObs.getNPCPositions()[0].size());
        	        	
        	// Comprobamos si la actual es mayor que la mejor
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