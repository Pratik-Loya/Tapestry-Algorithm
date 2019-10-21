defmodule MainModule do
    def start(num_nodes, num_requests) do
        Registry.start_link(keys: :unique, name: :registry)
        {:ok, create_node_pid} = CreateNode.start_link()
        #Create 80% Network
        network_nodes = floor(num_nodes*0.8)
        GenServer.call(create_node_pid,{:create_network, network_nodes},1000000)
        
        manual_network_nodes = floor(num_nodes*0.2)
        Enum.each(1..1,fn(node)-> 
            node_number = network_nodes+node
            GenServer.call(create_node_pid,{:add_node_to_network,num_nodes, node_number},100000)
        end)
        
        node_list = GenServer.call(create_node_pid,{:get_node_list})
        {:ok, message_hop_pid} = MessageHoping.start()
        GenServer.call(message_hop_pid,{start_connections, node_list, num_nodes}, :infinite)
        #GenServer.call(create_node_pid,{:print_state},1000)
        
    end
end