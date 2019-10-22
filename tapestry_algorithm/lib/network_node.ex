defmodule NetworkNode do
    @no_of_bits 8

    def start(node_hash) do
        GenServer.start_link(__MODULE__,[], name: {:via, Registry, {:registry, node_hash}})
    end

    def init(state) do
        {:ok, state}
    end

    def handle_call({:generate_routing_table,node_list,node_hash},_from, state)do
        #routing table for 4 levels
        routing_table = %{}
        filled_table = change_routing_table(routing_table,node_list,node_hash,@no_of_bits) #changeto8
        {:reply, state,{filled_table,[]}}
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
            GenServer.cast(getPid(node),{:update_routing_table,node_hash,node})
        end)

        {:noreply,state}
    end

    def handle_cast({:update_routing_table,new_node,node},{routing_table,count_list}) do
        
        index = Enum.find(1..@no_of_bits, fn x -> (String.at(node,x - 1) != String.at(new_node,x-1)) end)
        temp  = routing_table[index][String.at(new_node, index-1)]
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
        {:noreply,{routing_table,count_list}}
    end

    def handle_cast({:nearest,index,new_node},{routing_table,count_list}) do
        routing_table = put_in(routing_table[index][String.at(new_node, index-1)],new_node)
        {:noreply, {routing_table,count_list}}
    end

    def handle_cast({:start_searching,node_list,source_node, num_request},{routing_table,count_list}) do
        #IO.inspect self(), label: "source pid"
        #IO.inspect routing_table, label: source_node
        Enum.each(1..num_request, fn(request_number) -> 
            #IO.inspect self(), label: "source pid in task"
            #IO.puts "#{source_node} - #{request_number}"
            GenServer.cast(self(),{:send_request,source_node,source_node,Enum.random(node_list),0,num_request})
        end)
        {:noreply,{routing_table,count_list}}
    end

    def handle_cast({:send_request,source_node,current_node,destination_node,count,num_request},{routing_table,count_list}) do
        if(current_node == destination_node) do
            GenServer.cast(getPid(source_node),{:connection_complete, count,num_request})
        else
            index = Enum.find(1..@no_of_bits, fn x -> (String.at(current_node,x - 1) != String.at(destination_node,x-1)) end)
            node_in_rt  = routing_table[index][String.at(destination_node, index-1)]
            GenServer.cast(getPid(node_in_rt),{:send_request,source_node,node_in_rt,destination_node,count+1,num_request})
        end
        {:noreply,{routing_table,count_list}}
    end

    def handle_cast({:connection_complete, count,num_request}, {routing_table,count_list}) do
        #IO.inspect count_list, label: "hop count"
        if(length(count_list) == num_request-1) do
            count_list = [count|count_list]
            #IO.inspect Enum.max(count_list), label: "max count"
            #IO.inspect getPid(:message_hops), label: "max hop pid"
            send(getPid(:message_hops), {:max,Enum.max(count_list)})
        end
        {:noreply,{routing_table, [count|count_list]}}
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
