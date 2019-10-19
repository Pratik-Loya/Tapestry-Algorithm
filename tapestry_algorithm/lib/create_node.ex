defmodule CreateNode do

    @crypto_function :sha
    @no_of_bits 4

    def start_link() do
        GenServer.start_link(__MODULE__, [], name: :create_node)
    end

    def init(state) do
        {:ok, state}
    end

    def handle_call({:create_network, num_nodes}, _from, state) do
        node_list = Enum.reduce(1..num_nodes, [], fn number,bucket->
            hash_value = get_hash_value(number,num_nodes,bucket)
            [hash_value | bucket]
        end)
        
        node_list = ["1001","5CFE","1222","FEBC","1235","1211","1167","1F98","11BC","1BDF"]
        node_hash = "1234"
        NetworkNode.start(node_list,node_hash)

        #NetworkNode.start(node_list,Enum.at(node_list,0))
        '''
        Enum.each(node_list, fn node_hash->
            NetworkNode.start(node_list,node_hash)
            #IO.inspect node_hash
            #IO.inspect getPid(node_hash)
        end)
        '''

        {:reply, state,state}
    end


    def getPid(node_id) do
        case Registry.lookup(:registry, node_id) do
        [{pid, _}] -> pid
        [] -> nil
        end
    end

    def get_hash_value(number,num_nodes,bucket) do
        hash_value = :crypto.hash(@crypto_function, Integer.to_string(number)) |> Base.encode16 |> String.slice(1..@no_of_bits)
        if(is_unique(hash_value,bucket)) do
            hash_value
        else
            get_hash_value(number+num_nodes,num_nodes,bucket)
        end
    end

    #Create hash values for the 80% of nodes
    def is_unique(new_hash_value,bucket) do
        if(new_hash_value in bucket) do
            :false
        else
            :true
        end
    end

end
