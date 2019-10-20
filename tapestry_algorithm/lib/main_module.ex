defmodule MainModule do
    def start(num_nodes, num_requests) do
        Registry.start_link(keys: :unique, name: :registry)
        {:ok, create_node_pid} = CreateNode.start_link()
        #Create 80% Network
        network_nodes = floor(num_nodes*0.8)
        GenServer.call(create_node_pid,{:create_network, network_nodes},1000000)

        manual_network_nodes = floor(num_nodes*0.2)
        GenServer.call(create_node_pid,{:add_nodes_to_network, manual_network_nodes,network_nodes},1000000)
    end
end