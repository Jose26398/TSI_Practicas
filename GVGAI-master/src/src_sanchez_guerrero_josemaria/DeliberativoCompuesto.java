package src_sanchez_guerrero_josemaria;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;
import java.util.ArrayList;


public class DeliberativoCompuesto extends AbstractPlayer {

	// Declaracion de variables
    private IDAStar pf;
    private ArrayList<Node> path = new ArrayList<>();
    private Vector2d ultimaPos;
    
    Node initialState;
    Node goalState;

  	Vector2d fescala;
  	Vector2d gema;
  	Vector2d portal;
  	ArrayList<Vector2d> tiposObs = new ArrayList<>();
  	
  	/**
  	 * initialize all variables for the agent
  	 * @param stateObs Observation of the current state.
     * @param elapsedTimer Timer when the action returned is due.
  	 */
  	public DeliberativoCompuesto(StateObservation stateObs, ElapsedCpuTimer elapsedTimer){
  		
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

        // Se crea una lista de observaciones de gemas, ordenada por cercania al avatar
        ArrayList<Observation>[] posicionesGemas = stateObs.getResourcesPositions(stateObs.getAvatarPosition());

        for (int i=0; i < posicionesGemas[0].size(); i++) {
        	// Seleccionamos las gemas una a una
        	gema = posicionesGemas[0].get(i).position;
        	gema.x = Math.floor(gema.x / fescala.x);
        	gema.y = Math.floor(gema.y / fescala.y);

        	goalState = new Node(gema);
        	
        	// Se inicializa el objeto del pathfinder con las ids de los obstaculos
            pf = new IDAStar(initialState, goalState, tiposObs);
            // Calculamos un camino desde la posicion del avatar a la posicion de la gema
            ArrayList<Node> aux = pf.getPath( pf.search() );
            // Quitamos el primero, ya que estamos en el
            aux.remove(0);
            // Lo aniadimos al path completo que pasa por todas las gemas
            path.addAll(aux);
            
            // Actualizamos la posicion
            initialState = goalState;
        }

        // Se crea una lista de observaciones de portales, ordenada por cercania al avatar
        ArrayList<Observation>[] posicionPortal = stateObs.getPortalsPositions(stateObs.getAvatarPosition());

        // Seleccionamos el portal mas proximo
        portal = posicionPortal[0].get(0).position;
        portal.x = Math.floor(portal.x / fescala.x);
        portal.y = Math.floor(portal.y / fescala.y);
        
        // Creamos nodo con la posicion obtenida
    	goalState = new Node(portal);
        
    	// Se inicializa el objeto del pathfinder con las ids de los obstaculos
        pf = new IDAStar(initialState, goalState, tiposObs);
        // Calculamos un camino desde la posicion del avatar a la posicion de la gema
        ArrayList<Node> aux = pf.getPath( pf.search() );
        // Quitamos el primero, ya que estamos en el
        aux.remove(0);
        // Lo aniadimos al path completo que pasa por todas las gemas
        path.addAll(aux);
        
  	}

    
    @Override
    public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
    	
        // Obtenemos la posicion del avatar
        Vector2d avatar = new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y);
                
        // Actualizamos el plan de ruta
        if (((avatar.x != ultimaPos.x) || (avatar.y != ultimaPos.y)) && !path.isEmpty()) {
            path.remove(0);
        }

        // Si el path no esta vacio
        if (path != null) {
            Types.ACTIONS siguienteAccion;
            
            // Obtenemos la primera posicion registrada en el path
            Node siguientePos = path.get(0);

            //Se determina el siguiente movimiento a partir de la posicion del avatar
            siguienteAccion = sigMovimiento(siguientePos.getPosition(), avatar);

            //Se actualiza la ultima posicion del avatar
            ultimaPos = avatar;
            
            return siguienteAccion;

        // Si el path esta vacio, el personaje no se mueve
        } else {            
            // Salida por defecto
            return Types.ACTIONS.ACTION_NIL;
        }
        
    }


    /**
     * Funcion que determina la siguiente accion a partir del siguiente nodo.
     * 
     * @param siguientePos Posicion de la siguiente accion.
     * @param avatar Posicion actual del avatar.
     * @return Tipo accion que lee el agente GVGAI.
     */
    private Types.ACTIONS sigMovimiento(Vector2d siguientePos, Vector2d avatar) {
        
    	Types.ACTIONS siguienteAccion;
        
        // Basandose en las coordenada de la posicion actual y la siguiente,
    	// devuelve una accion u otra
        if (siguientePos.x != avatar.x) {
            if (siguientePos.x > avatar.x) {
                siguienteAccion = Types.ACTIONS.ACTION_RIGHT;
            } else {
                siguienteAccion = Types.ACTIONS.ACTION_LEFT;
            }
        } else {
            if (siguientePos.y > avatar.y) {
                siguienteAccion = Types.ACTIONS.ACTION_DOWN;
            } else {
                siguienteAccion = Types.ACTIONS.ACTION_UP;
            }
        }
        
        return siguienteAccion;
    }

}
