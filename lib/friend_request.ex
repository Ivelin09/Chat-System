defmodule Friend_Request do
  require Mnesia_storage
  def init(req, _state) do
    {:cowboy_rest, req, :nostate}
  end

  def allowed_methods(req, state) do
    {["GET", "PUT", "POST", "PATCH", "DELETE", "OPTIONS"], req, state}
  end

  def content_types_provided(req, state) do
    {[{"application/json", :home}], req, state}
  end

  def set_headers(headers, req) do
    reqWithHeaders = List.foldl(headers, req, fn({header, value}, reqIn) ->
					 reqWithHeader = :cowboy_req.set_resp_header(header, value, reqIn)
				 end)
    {:ok, reqWithHeaders}
    end

  def options(req, state) do
    IO.inspect("fck")
    headers = [
      {<<"access-control-allow-origin">>, <<"*">>},
      {<<"access-control-allow-methods">>, <<"POST, GET, OPTIONS">>},
      {<<"access-control-allow-headers">>, <<"Origin, X-Requested-With, Content-Type, Accept, Set-Cookie">>},
      {<<"access-control-max-age">>, <<"1000">>}
  ]
    {:ok, req2} = set_headers(headers, req)
    {:ok, req2, state}
  end

  def resource_exists(req, state) do
    IO.inspect("asd")
    path = :cowboy_req.path(req)
    case :cowboy_req.method(req) do
      "POST" ->
        {:ok, body, _Req} = :cowboy_req.read_body(req)
        content = Poison.decode!(body)
        user = Mnesia_storage.authenticate_user(:cowboy_req.headers(req)["set-cookie"])
        IO.inspect(:cowboy_req.headers(req))
        response = cond do
          path == "/friend_request/send" ->
            Mnesia_storage.friend_request(user, content["recipient"])
          path == "/friend_request/deny" -> Mnesia_storage.deny_friend_request(content["sender"], content["recipient"])
          path == "/friend_request/accept" ->
            Mnesia_storage.accept_friend_request(user, content["recipient"])
          path == "/friend_request/deny" -> Mnesia_storage.deny_friend_request(content["sender"], content["recipient"])
          path == "friends_request/get" ->
            Mnesia_storage.get_friend_list(user)
        end
        {:ok, req1, _} = options(req, state)
        {:stop, :cowboy_req.reply(202, :cowboy_req.set_resp_body(Poison.encode!(response), req1)), state}
      "GET" ->
        headers = :cowboy_req.headers(req)
        respond = cond do
          path == "/friend_request/get_friends" ->
            Mnesia_storage.get_friend_list(Mnesia_storage.authenticate_user(headers["set-cookie"]))
          path == "/friend_request/get_pending" ->
            Mnesia_storage.get_friend_requests(Mnesia_storage.authenticate_user(headers["set-cookie"]))
          true ->
            :okay
        end
        {:ok, req1, _} = options(req, state)
        {:stop, :cowboy_req.reply(202, :cowboy_req.set_resp_body(Poison.encode!(respond), req1)), state}
      _ ->
          {:stop, :cowboy_req.reply(202, :cowboy_req.set_resp_body("No one to handle", req)), state}
      end
  end
  def home(request, state) do
    {"home", request, state}
  end

  def terminate(_reason, _request, _state), do:    :ok
end
