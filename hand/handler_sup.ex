defmodule Handler.Supervisor do
    use Supervisor

    alias Handler
  def start_link(args \\ []) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_init_args) do
    children = [
      [Handler, []]
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
