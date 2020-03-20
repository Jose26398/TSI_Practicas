package src_sanchez_guerrero_josemaria;

import java.util.ArrayList;
import java.util.List;
import tools.Vector2d;


public class Node implements Comparable<Node> {
	

	// Valor heuristico del nodo actual
    private double hScore = Double.MIN_VALUE;
    // Coste del camino recorrido
    private double gScore = 0.0;
    // La suma de los valores anteriores
    private double fScore = 0.0;

    // Padre del nodo actual
    private Node parent;
    // Posicion en coordenadas (x,y) del nodo actual
    private Vector2d position;
    	
	
	/**
	 * Constructor a partir de una posicion (x,y) del mapa.
	 * 
	 * @param position
	 */
	Node(Vector2d position){
		this.position = position;
	}
	    
    /**
     * Devuelve el valor heuristico
     * @return hScore
     */
    public double getH() {
        return this.hScore;
    }
    
    /**
     * Asigna un valor heuristico.
     * @param hScore
     */
    public void setH(double hScore) {
        this.hScore = hScore;
    }

    /**
     * Devuelve el costo del camino recorrido
     * @return gScore
     */
    public double getG() {
        return this.gScore;
    }

    /**
     * Asigna un costo del camino recorrido.
     * @param gScore
     */
    public void setG(double gScore) {
        this.gScore = gScore;
    }

    /**
     * Devuelve la suma de costos
     * @return fScore
     */
    public double getF() {
        return this.fScore;
    }

    /**
     * Asigna el valor de la suma de costos
     * @param fScore
     */
    public void setF(double fScore) {
        this.fScore = fScore;
    }

    /**
     * Devuelve el nodo padre del nodo actual
     * @return parent
     */
    public Node getParent() {
    	return this.parent;
    }
    
    /**
     * Asigna un nuevo padre al nodo actual
     * @param parent
     */
    public void setParent(Node parent) {
    	this.parent = parent;
    }

    /**
     * Devuelve la posicion del nodo actual
     * @return position
     */
    public Vector2d getPosition() {
        return this.position;
    }

    /**
     * Asigna una nueva posicion al nodo actual
     * @param position
     */
    public void setPosition(Vector2d position) {
        this.position = position;
    }

    /**
     * Compara el valor de f() del nodo actual con otro.
     * 
     * @param n Nodo a comparar.
     * @return -1 si el actual es menor que n,
    			0 si actual es igual que n,
    			1 si actual es mayor que n.
     */
    @Override
    public int compareTo(Node n) {
        if(this.fScore < n.fScore)
            return -1;
        if(this.fScore > n.fScore)
            return 1;
        return 0;
    }


    /**
     * Determina si otro nodo es igual al nodo actual. Dos nodos son iguales si
     * sus estados son iguales (no f ()).
     * 
     * @param otro nodo Nodo a comparar.
     * @return true si el otro nodo es igual, false en caso contrario.
     */
    @Override
    public boolean equals(Object o)
    {
        return this.position.equals(((Node)o).position);
    }
    
    
    /**
     * Genera una lista de los nodos sucesores al nodo actual. Devolvemos cada una
     * de las casillas que rodean a la actual, comprobando antes que esta casilla
     * sea transitable, es decir, no sea un obstaculo.
     *
     * @param tiposObs son las casillas no transitables del mapa.
     * @return lista de nodos sucesores.
     */
    public List<Node> getSuccessors(ArrayList<Vector2d> tiposObs){
    	
    	// Declaromos una lista para los nodos
    	List<Node> successors = new ArrayList<Node>();
    	
    	// Insertamos en ella las casillas que rodean a la actual
    	Node top = new Node( new Vector2d(this.position.x, this.position.y-1) );
    	top.setParent(this);
    	Node bottom = new Node( new Vector2d(position.x, position.y+1) );
    	bottom.setParent(this);
    	Node left = new Node( new Vector2d(position.x-1, position.y) );
    	left.setParent(this);
    	Node right = new Node( new Vector2d(position.x+1, position.y) );
    	right.setParent(this);
    	
    	// Comprobamos que no son casillas no transitables
    	if (!tiposObs.contains( top.position )) {
    		successors.add(top);
    	}
    	if (!tiposObs.contains( bottom.position )) {
    		successors.add(bottom);
    	}
    	if (!tiposObs.contains( left.position )) {
    		successors.add(left);
    	}
    	if (!tiposObs.contains( right.position )) {
    		successors.add(right);
    	}
    	
    	return successors;
    }
    
    
    /**
     * Devuelve la distancia entre el nodo actual y el padre.
     *
     * @return 1, porque estamos en un mapa cuadriculado.
     */
    public double distFromParent() {
    	
    	return 1;
    	
    }
}