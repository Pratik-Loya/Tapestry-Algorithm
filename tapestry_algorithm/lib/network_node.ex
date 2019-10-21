defmodule NetworkNode do
    @no_of_bits 4
    def start(node_hash) do
        GenServer.start_link(__MODULE__,[], name: {:via, Registry, {:registry, node_hash}})
    end

    def init(state) do
        {:ok, state}
    end

    def handle_call({:generate_routing_table,node_list,node_hash},_from, state)do
        #routing table for 4 levels
        routing_table = %{}
        filled_table = change_routing_table(routing_table,node_list,node_hash,4) #changeto8
        {:reply, state,filled_table}
    end

    def change_routing_table(routing_table,node_list,node_hash,0), do: routing_table

    def change_routing_table(routing_table,node_list,node_hash,row_num) do
        nth_row_list = Enum.filter(node_list,fn(nodes) -> String.slice(nodes,0,row_num-1)==String.slice(node_hash,0,row_num-1) end)
        row_map = %{}
        nth_row_map = get_row_map(row_map,nth_row_list,node_hash,row_num,15)
        node_list = node_list -- nth_row_list
        routing_table = put_in(routing_table[row_num],nth_row_map)
        change_routing_table(routing_table,node_list,node_hash,row_num-1)
    end

    def get_row_map(row_map,nth_row_list,node_hash,row_num,-1), do: row_map

    def get_row_map(row_map,nth_row_list,node_hash,row_num,col_num) do
        hex_value = "0123456789ABCDEF"
        #finding list of values eligible for 1 column
        value = Enum.filter(nth_row_list, fn(x) ->  String.at(x,row_num-1) == String.at(hex_value,col_num) end)

        #find the node that is nearest
        int_hashvalue = List.to_integer(node_hash |> Kernel.to_charlist(),16)
         if(value != []) do
          {hash_value,_diff} = Enum.min_by(Enum.map(value, fn x -> {x, abs(List.to_integer(x |> to_charlist(),16) - int_hashvalue) } end), fn({x,y}) -> y end)
          #IO.inspect value, label: "from value"
          #IO.inspect hash_value
          row_map = put_in(row_map[String.at(hex_value,col_num)],hash_value)
          get_row_map(row_map,nth_row_list,node_hash,row_num,col_num-1)
        else
          row_map = put_in(row_map[String.at(hex_value,col_num)],value)
          get_row_map(row_map,nth_row_list,node_hash,row_num,col_num-1)
        end
    end

    def handle_cast({:multicast_presence,node_list,node_hash},state) do
        temp_list = node_list -- [node_hash]
        Enum.each(temp_list,fn(node) -> 
            IO.inspect node
            GenServer.cast(getPid(node),{:update_routing_table,node_hash,node})
        end)

        {:noreply,state}
    end

    def handle_cast({:update_routing_table,new_node,node},routing_table) do
        IO.inspect new_node, label: "new node"
        index = Enum.find(1..@no_of_bits, fn x -> (String.at(node,x - 1) != String.at(new_node,x-1)) end)
        IO.inspect index, label: "Unmatched bit"
        temp  = routing_table[index][String.at(new_node, index)]
        IO.puts "temp #{temp} = #{node}, NEW NODE #{new_node}"
        if(temp != [] && temp != nil) do
            int_node = List.to_integer(node |> Kernel.to_charlist(),16)
            int_new_node = List.to_integer(new_node |> Kernel.to_charlist(),16)
            int_temp = List.to_integer(temp |> Kernel.to_charlist(),16)
            if(abs(int_new_node - int_node) < abs(int_temp - int_node)) do
                GenServer.cast(self(),{:nearest,index,new_node})
            end
        else
            GenServer.cast(self(),{:nearest,index,new_node})
        end
        {:noreply,routing_table}
    end

    def handle_cast({:nearest,index,new_node},routing_table) do
        routing_table = put_in(routing_table[index][String.at(new_node, index)],new_node)
        {:noreply, routing_table}
    end


    def getPid(node_id) do
        case Registry.lookup(:registry, node_id) do
        [{pid, _}] -> pid
        [] -> nil
        end
    end

    def handle_call({:print_routing_table},_from,state)do
        IO.inspect state
        {:reply,state,state}
    end
end
