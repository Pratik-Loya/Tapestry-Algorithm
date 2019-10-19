defmodule NetworkNode do
    def start(node_list,node_hash) do
        GenServer.start_link(__MODULE__, {node_list -- [node_hash],node_hash}, name: {:via, Registry, {:registry, node_hash}})
    end

    def init({node_list,node_hash}) do
        #routing table for 4 levels
        routing_table = %{
            1 => %{0 => "",1 => "",2 => "",3 => "",4 => "",5 => "",6 => "",7 => "",8 => "",9 => "",'a' => "",'b' => "",'c' => "",'d' => "",'e' => "",'f' => ""},
            2 => %{0 => "",1 => "",2 => "",3 => "",4 => "",5 => "",6 => "",7 => "",8 => "",9 => "",'a' => "",'b' => "",'c' => "",'d' => "",'e' => "",'f' => ""},
            3 => %{0 => "",1 => "",2 => "",3 => "",4 => "",5 => "",6 => "",7 => "",8 => "",9 => "",'a' => "",'b' => "",'c' => "",'d' => "",'e' => "",'f' => ""},
            4 => %{0 => "",1 => "",2 => "",3 => "",4 => "",5 => "",6 => "",7 => "",8 => "",9 => "",'a' => "",'b' => "",'c' => "",'d' => "",'e' => "",'f' => ""}
            #5 => %{0 => "",1 => "",2 => "",3 => "",4 => "",5 => "",6 => "",7 => "",8 => "",9 => "",'a' => "",'b' => "",'c' => "",'d' => "",'e' => "",'f' => ""},
            #6 => %{0 => "",1 => "",2 => "",3 => "",4 => "",5 => "",6 => "",7 => "",8 => "",9 => "",'a' => "",'b' => "",'c' => "",'d' => "",'e' => "",'f' => ""},
            #7 => %{0 => "",1 => "",2 => "",3 => "",4 => "",5 => "",6 => "",7 => "",8 => "",9 => "",'a' => "",'b' => "",'c' => "",'d' => "",'e' => "",'f' => ""},
            #8 => %{0 => "",1 => "",2 => "",3 => "",4 => "",5 => "",6 => "",7 => "",8 => "",9 => "",'a' => "",'b' => "",'c' => "",'d' => "",'e' => "",'f' => ""}
        }
        IO.inspect node_hash
        filled_table = change_routing_table(routing_table,node_list,node_hash,4) #changeto8
        IO.inspect filled_table
        {:ok, filled_table}
    end

    def change_routing_table(routing_table,node_list,node_hash,0), do: routing_table

    def change_routing_table(routing_table,node_list,node_hash,row_num) do
        nth_row_list = Enum.filter(node_list,fn(nodes) -> String.slice(nodes,0,row_num-1)==String.slice(node_hash,0,row_num-1) end)
        #IO.inspect row_num
        #IO.inspect nth_row_list
        row_map = %{"0" => "","1" => "","2" => "","3" => "","4" => "","5" => "","6" => "","7" => "","8" => "","9" => "","A" => "","B" => "","C" => "","D" => "","E" => "","F" => ""}
        nth_row_map = get_row_map(row_map,nth_row_list,node_hash,row_num,15)
        #IO.inspect nth_row_map
        node_list = node_list -- nth_row_list
        routing_table = put_in(routing_table[row_num],nth_row_map)
        change_routing_table(routing_table,node_list,node_hash,row_num-1)
    end

    def get_row_map(row_map,nth_row_list,node_hash,row_num,-1), do: row_map

    def get_row_map(row_map,nth_row_list,node_hash,row_num,col_num) do
        #IO.inspect nth_row_list
        hex_value = "0123456789ABCDEF"
        #finding list of values eligible for 1 column
        value = Enum.filter(nth_row_list, fn(x) ->  String.at(x,row_num-1) == String.at(hex_value,col_num) end)

        #find distance
        int_hashvalue = Integer.parse(node_hash,16)

        IO.inspect value, label: "value of row"

        if(value != []) do
          int_value = Enum.min_by(Enum.map(value, fn x -> {x, List.to_integer(x |> to_charlist(),16) - int_hashvalue } end), fn({x,y}) -> abs(x) end)
          #IO.inspect int_value, label: "if part cleared"
          row_map = put_in(row_map[String.at(hex_value,col_num)],int_value)
        else
          IO.puts "in else part"
          row_map = put_in(row_map[String.at(hex_value,col_num)],value)
        end
        '''
        value = Enum.filter(nth_row_list,[], fn(x,acc) ->
            last_char = String.at(String.slice(x,0,row_num),-1)
            if(get_in(row_map,[last_char]) == "" ) do
                row_map = put_in(row_map[last_char], x)
                IO.inspect x
                [x | acc ]
            end
        end)
        '''
        #IO.inspect row_map
        #row_map = put_in(row_map[String.at(hex_value,col_num)],int_value)
        get_row_map(row_map,nth_row_list,node_hash,row_num,col_num-1)
    end
end
