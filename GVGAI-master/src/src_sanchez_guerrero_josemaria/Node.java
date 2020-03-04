package src_sanchez_guerrero_josemaria;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import tools.Vector2d;

/**
 * Abstract class that is extended to create problems that are solvable by A* search variants.
 *
 * @param <T> the type of the node's stored state
 */
public class Node implements Comparable<Node> {
	
	Node(Vector2d position){
		this.position = position;
	}
	

    /**
     * Node's h() heuristic value.
     */
    double hScore = Double.MIN_VALUE;

    /**
     * Node's g() graph cost value.
     */
    double gScore = 0.0;

    /**
     * Node's f() total score value. This is h() + g().
     */
    double fScore = 0.0;

    /**
     * Node's parent.
     */
    Node parent;
    
    public Vector2d position;
    
    public int id;

    /**
     * Returns the heuristic score h() for the node. You MUST call calcH() before attempting to retrieve the heuristic
     * score, otherwise h() = Integer.MIN_VALUE.
     *
     * @return the heuristic score h() for the node
     */
    public double getH() {
        return this.hScore;
    }

    /**
     * Sets the node's heuristic score h(). Get h() from A IHeuristicFunction object then store the value using this
     * method.
     *
     * @param hScore the heuristic score h() of the node
     */
    public void setH(double hScore) {
        this.hScore = hScore;
    }

    /**
     * Returns the graph link score g(). The total path cost accumulated so far to reach current node.
     *
     * @return returns graph link score g()
     */
    public double getG() {
        return this.gScore;
    }

    /**
     * Set the node's path cost g(). The total path cost accumulated so far to reach current node.
     *
     * @param gScore the node's path cost g()
     */
    public void setG(double gScore) {
        this.gScore = gScore;
    }

    /**
     * Gets the node's parents. Initial nodes should have parent equal to NULL.
     *
     * @return returns the node's parent
     */
    public Node getParent() {
        return this.parent;
    }

    /**
     * Sets the node's parent. Initial nodes should have parent equal to NULL.
     *
     * @param parent the node's parent
     */
    public void setParent(Node parent) {
        this.parent = parent;
    }

    /**
     * Returns the f() value of the node. Note it does not do the f() calculation you must store it in the node using
     * setF().
     *
     * @return the f() value of the node
     */
    public double getF() {
        return this.fScore;
    }

    /**
     * Sets the node's f() value.
     *
     * @param fScore the f() value of the node
     */
    public void setF(double fScore) {
        this.fScore = fScore;
    }

    /**
     * Returns the node's state
     *
     * @return the node's state
     */
    public Vector2d getPosition() {
        return this.position;
    }

    /**
     * Sets the node's state.
     *
     * @param state the state of the node
     */
    public void setState(Vector2d position) {
        this.position = position;
    }

    /**
     * Compares two AStarNodes' f() values. Used in priority queue.
     *
     * @param node1 a AbstractAStarNode - treated as primary
     * @param node2 another AbstractAStarNode - treated as secondary
     * @return negative if node1 LT node2; zero if node1==node2; positive if node1 GT node2;
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
     * Determine if another node equals the current node. Equality(just like the hashCode()) should be determined by
     * node state. That is two nodes are equal if their states are the same(not f()).
     *
     * @param otherNode node to compare with
     * @return true if other node is equal, false otherwise
     */
    @Override
    public boolean equals(Object o)
    {
        return this.position.equals(((Node)o).position);
    }
    
    /**
     * Generates a list of successor nodes.
     *
     * @return list of successor nodes
     */
    public List<Node> getSuccessors(ArrayList<Vector2d> tiposObs){
    	List<Node> successors = new ArrayList<Node>();
    	Node top = new Node( new Vector2d(this.position.x, this.position.y-1) );
    	top.setParent(this);
    	Node bottom = new Node( new Vector2d(position.x, position.y+1) );
    	bottom.setParent(this);
    	Node left = new Node( new Vector2d(position.x-1, position.y) );
    	left.setParent(this);
    	Node right = new Node( new Vector2d(position.x+1, position.y) );
    	right.setParent(this);
    	
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
     * Returns the distance from the node to its parent.
     *
     * @return returns distance to node's parent
     */
    public double distFromParent() {
    	return 1;
    }
}