defmodule Server do

  def start() do
    dispatch_config = build_dispatch_config()
    { :ok, _ } = :cowboy.start_clear(:my_http_listener,
      [{:port, 8080}],
      %{ env: %{dispatch: dispatch_config}}
    )
  end

  def build_dispatch_config do
    :cowboy_router.compile([
      { :_,
        [
          {"/register", Elixir.Register, []},
          {"/login", Elixir.Login, []},
          {"/friend_request", Elixir.Friend_Request, []}
        ]}
    ])
  end

end
