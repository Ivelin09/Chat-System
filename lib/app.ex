defmodule Mnesia_storage do
  use GenServer, Amnesia.Database
  require Amnesia
  require Amnesia.Helper
  require Database.User

  alias Database.User

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(args) do
    {:ok, args}
  end

  def read(tag) do
    Amnesia.transaction do
      User.read(tag)
    end
  end


  def generate_token() do
    :base64.encode(:crypto.strong_rand_bytes(32))
  end

  def register(name, mail, pass) do
    token = generate_token()
    Amnesia.transaction do
        %User{username: name, email: mail, password: pass, failed_login_attemps: 0, available_time: Time.utc_now(), auth_token: token} |> User.write()
    end
    %{token: token} # RESPOND
  end


  def login(username, pass) do
    acc = Amnesia.transaction do
      User.read(username)
    end

    too_soon = Time.compare(acc.available_time, Time.utc_now)
    cond do
      too_soon == :gt -> "you should WAIT"
      acc.password == pass -> "success"
      acc.failed_login_attemps == 3 ->
        Amnesia.transaction do
          %User{
            username: username,
            email: acc.email,
            password: acc.password,
            failed_login_attemps: 0,
            available_time: Time.add(Time.utc_now(), 60000, :millisecond)
          } |> User.write()
        end
      true ->
        Amnesia.transaction do
          %User{
            username: username,
            email: acc.email,
            password: acc.password,
            failed_login_attemps: acc.failed_login_attemps+1,
            available_time: acc.available_time
          } |> User.write()
        end
    end


  end

  def handle_cast({:attempted, pass}, _from, state) do
    Amnesia.transaction(
      User.read(state.username)
    )
  end

  def handle_call(logout, _from, [head | tail]) do
    {:reply, head, tail}
  end
end