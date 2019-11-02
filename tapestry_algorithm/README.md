## Team Members:
Pratik Loya <br>
Kirti Desai

## Procedure to run the file:
-	Go to Path “tapestry_algorithm/”
-	Run command on terminal
“mix run project3.exs number_of_nodes number_of_requests”

## What is working:
-	Static routing table creation for 80% nodes of the network
-	20% of the remaining nodes are inserted dynamically and the presence of the new node is multicast to all the Need-to-know nodes
-	Calculation  of maximum hop count among all of the requests done by all the nodes.

## Largest  Network Tested: 
Number of Nodes: 10,000 , Number of Request: 10
 
## Working of Tapestry Model:
#### Static-Network Creation:
This model first creates a network of static nodes which is appended to a global list of all the nodes. They create their routing table based on this global list.

#### Dynamic Node Addition:
Whenever a new node joins the network, it first finds the node which is nearest to it (also called root node) and copies the routing table of that node till the level n (where n is the longest common prefix between the new node and the nearest node). It also notifies its presence by multicasting to all the Need-to-know nodes. The multicast is a recursive call — the nearest node contacts all nodes on levels ≥ n of its routing table; those nodes contact all nodes on levels ≥ n + 1 of their routing tables; and so on. This way all the Need-to-know nodes gets notified of the presence of the new node.
Note: Using this method it was observed that the overall time required to add a new node into the network was decreased as compared to the method where we had to notify all the nodes in the network about the presence of the new node.

## Route from source to destination node:
Every node starts requesting once all the nodes are added to the network. A source node chooses a random destination node and check for the destination node or the nearest to the destination node. If it doesn’t find the destination node in its own routing table, it hops into the nearest nodes routing table and check for the destination, if not then next nearest neighbor and increase the count of hop by one. On the final call, it returns the maximum number of hops it took to reach the destination node to the source node. Source Node maintains a list of counts it took for each request and sends the max hop to the main node after all the requests are completed. The main node on receiving the max counts from each individual nodes than prints the max hop from the network.
