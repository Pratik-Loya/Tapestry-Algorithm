defmodule MessageHoping do
    def start() do
        GenServer.start_link(__MODULE__, [], name: :message_hops)
    end

    def init(state) do
        {:ok, state}
    end
end