package src_sanchez_guerrero_josemaria;

import java.util.ArrayList;
import java.util.List;

import tools.Vector2d;


public class IDAStar {

	// Creamos las variables para los nodos
    private Node initialState;
    private Node goalState;
    private ArrayList<Vector2d> tiposObs;


    public IDAStar(Node initialState, Node goalState, ArrayList<Vector2d> tiposObs) {
        this.initialState = initialState;
        this.goalState = goalState;
        this.tiposObs = tiposObs;
    }

    
    public Node search() {

        // Encontrar cota de F inicial
        double currentFBound = Math.abs(this.goalState.getPosition().x-this.initialState.getPosition().x)
        					 + Math.abs(this.goalState.getPosition().y-this.initialState.getPosition().y);

        // Creamos el path y aniadimos la posicion inicial
        ArrayList<Node> path = new ArrayList<>();
        path.add(0, this.initialState);

        // Repetimos el bucle con un nuevo F más grande hasta que:
        // - Se devuelve 0, es decir, hemos encontrado la ruta mas optima
        // - Double.MAX_Value - No se encontro ningun con una F mayor que el F limite, es decir, no hay solucion
        double smallestNewFBound;
        
        do {
            // Comienzo de la busqueda recursiva
            smallestNewFBound = recursive_search(path, 0, currentFBound);

            // Comprobamos si hemos llegado al final
            if (smallestNewFBound == 0.0)
                return path.get(path.size() - 1);

            // Si no hemos llegado establecemos una nueva cota para F
            currentFBound = smallestNewFBound;
        } while (currentFBound != Double.MAX_VALUE);

        return null;
    }

    
    private double recursive_search(ArrayList<Node> path, double graphCost, double currentFBound) {

        // Establece las G, H, y F del nodo actual
        Node currentNode = path.get(path.size() - 1);
        currentNode.setH(Math.abs(this.goalState.getPosition().x-currentNode.getPosition().x)
				 	   + Math.abs(this.goalState.getPosition().y-currentNode.getPosition().y));
        currentNode.setG(graphCost);
        currentNode.setF(graphCost + currentNode.getH());

        // Si el nodo actual tiene una F mayor que la cota actual
        if (currentNode.getF() > currentFBound)
            return currentNode.getF();

        // Comprueba si el nodo actual es igual que el nodo objetivo
        if (currentNode.equals(this.goalState))
            return 0;

        // Inicializamos el valor minimo de F encontrado
        double minFFound = Double.MAX_VALUE;

        List<Node> children = currentNode.getSuccessors(tiposObs);
        // Expandimos el nodo actual en cada uno de sus hijo
        for (Node child : children) {

            // Comprobamos que no estan ya en el path
            if (!path.contains(child)) {

                // Aniadimos el hijo al path
                path.add(child);
                double minFOverBound;
                // Y continuamos la busqueda recursiva, aumentando la G en 1 (en nuestro caso)
                if (currentNode.getParent() != null &&
                	currentNode.parent.getPosition().x != child.getPosition().x &&
                	currentNode.parent.getPosition().y != child.getPosition().y) {
                	minFOverBound = recursive_search(path, currentNode.getG() + child.distFromParent()+1, currentFBound);
                }
                else {                	
                	minFOverBound = recursive_search(path, currentNode.getG() + child.distFromParent(), currentFBound);
                }

                // Terminamos si hemos encontrado el nodo objetivo
                if (minFOverBound == 0.0)
                    return 0.0;

                // Guardamos el valor de la F mas pequenia encontrada entre todas las cotas de los hijos generados
                if (minFOverBound < minFFound)
                    minFFound = minFOverBound;

                // Eliminamos al hijo del path antes de explorar el siguiente
                path.remove(path.size() - 1);
            }
        }

        return minFFound;
    }
    
    // Devolvemos el path completo para que pueda ser leido por nuestro agente
    public ArrayList<Node> getPath(Node endPathNode) {
        ArrayList<Node> path = new ArrayList<>();
        path.add(endPathNode);

        while (endPathNode.getParent() != null) {
            path.add(0, endPathNode.getParent());
            endPathNode = endPathNode.getParent();
        }

        return path;
    }
    

}