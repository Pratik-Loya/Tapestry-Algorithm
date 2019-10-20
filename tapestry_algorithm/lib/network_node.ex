defmodule NetworkNode do
    def start(node_list,node_hash) do
        GenServer.start_link(__MODULE__, {node_list -- [node_hash],node_hash}, name: {:via, Registry, {:registry, node_hash}})
    end

    def init({node_list,node_hash}) do
        #routing table for 4 levels
        routing_table = %{}
        filled_table = change_routing_table(routing_table,node_list,node_hash,4) #changeto8
        {:ok, filled_table}
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
        int_hashvalue = List.to_integer(node_hash |> to_char_list(),16)
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

    def handle_call({:print_routing_table},_from,state)do
        IO.inspect state
        {:reply,state,state}
    end
end
