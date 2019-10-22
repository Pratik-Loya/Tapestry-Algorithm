defmodule MessageHoping do
    def start() do
        GenServer.start_link(__MODULE__, [], name: {:via, Registry, {:registry, :message_hops}})
    end

    def init(state) do
        {:ok, state}
    end


    def handle_call({:start_connections, node_list, num_requests},_from,state) do
        #node = "1222"
        #GenServer.cast(CreateNode.getPid(node), {:start_searching,node_list--[node],node, num_requests})
        
        Enum.each(node_list, fn(node) -> 
            IO.inspect node
            GenServer.cast(CreateNode.getPid(node), {:start_searching,node_list--[node],node, num_requests})
        end)
        receive_wrapper(length(node_list),0)
        {:reply, :ok, state}
    end

    def receive_wrapper(0,max), do: IO.inspect max, label: "Max of network"
        
    def receive_wrapper(num_nodes,max) do
        receive do
            {:max, count} ->
                IO.inspect count, label: "got it"
                if(count>max) do
                    receive_wrapper(num_nodes-1,count)
                else
                    receive_wrapper(num_nodes-1,max)
                end
        end
    end
end