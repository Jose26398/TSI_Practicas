package src_sanchez_guerrero_josemaria;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import tools.Vector2d;


public class Node implements Comparable<Node> {
	
	Node(Vector2d position){
		this.position = position;
	}
	
    double hScore = Double.MIN_VALUE;
    double gScore = 0.0;
    double fScore = 0.0;

    Node parent;
    public Vector2d position;
    
    
    public double getH() {
        return this.hScore;
    }

    public void setH(double hScore) {
        this.hScore = hScore;
    }

    public double getG() {
        return this.gScore;
    }

    public void setG(double gScore) {
        this.gScore = gScore;
    }

    public double getF() {
        return this.fScore;
    }

    public void setF(double fScore) {
        this.fScore = fScore;
    }

    public Node getParent() {
    	return this.parent;
    }
    
    public void setParent(Node parent) {
    	this.parent = parent;
    }

    public Vector2d getPosition() {
        return this.position;
    }

    public void setState(Vector2d position) {
        this.position = position;
    }

    
    @Override
    public int compareTo(Node n) {
        if(this.fScore < n.fScore)
            return -1;
        if(this.fScore > n.fScore)
            return 1;
        return 0;
    }


    @Override
    public boolean equals(Object o)
    {
        return this.position.equals(((Node)o).position);
    }
    
    
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
    
    
    public double distFromParent() {
    	
    	return 1;
    	
    }
}