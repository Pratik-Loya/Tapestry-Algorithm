defmodule MainModule do
    def start(num_nodes, num_requests) do
        Registry.start_link(keys: :unique, name: :registry)
        {:ok, create_node_pid} = CreateNode.start_link()
        GenServer.call(create_node_pid,{:create_network, num_nodes},1000000)
    end
end