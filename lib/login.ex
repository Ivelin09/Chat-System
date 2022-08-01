defmodule Login do


  require Mnesia_storage
  def init(req, _state) do
    {:cowboy_rest, req, :nostate}
  end

  def allowed_methods(req, state) do
    {["GET", "PUT", "POST", "PATCH", "DELETE", "OPTIONS"], req, state}
  end

  def allow_missing_post(req, state) do
    {false, req, state}
  end
  # GET / HEAD requests => no body
  def content_types_provided(req, state) do
    {[{"application/json", :home}], req, state}
  end
  def content_types_accepted(req, state) do
    {[{"application/json", :home}], req, state}
  end

  def set_headers(headers, req) do
    reqWithHeaders = List.foldl(headers, req, fn({header, value}, reqIn) ->
					 reqWithHeader = :cowboy_req.set_resp_header(header, value, reqIn)
				 end)
    {:ok, reqWithHeaders}
    end

  def options(req, state) do
    headers = [
      {<<"access-control-allow-origin">>, <<"*">>},
      {<<"access-control-allow-methods">>, <<"POST, GET, OPTIONS">>},
      {<<"access-control-allow-headers">>, <<"Origin, X-Requested-With, Content-Type, Accept">>},
      {<<"access-control-max-age">>, <<"1000">>}
  ]
    {:ok, req2} = set_headers(headers, req)
    {:ok, req2, state}
  end

  def resource_exists(req, state) do

    case :cowboy_req.method(req) do
      "POST" ->
        {_, body, _Req} = :cowboy_req.read_body(req)
        content = Poison.decode!(body)
        respond = Mnesia_storage.login(content["username"], content["password"])
        {:ok, req2, _} = options(req, state)
        {:stop, :cowboy_req.reply(202, :cowboy_req.set_resp_body(Poison.encode!(respond), req2)), state}
      _ ->
        IO.inspect("there")
        {:stop, :cowboy_req.reply(202, :cowboy_req.set_resp_body("No one to handle", req)), state}
      end
  end



  def home(request, state) do
    IO.inspect("asd")
    req1 = :cowboy_req.set_resp_header(<<"access-control-allow-methods">>, <<"GET, OPTIONS">>, request)
    req2 = :cowboy_req.set_resp_header(<<"access-control-allow-origin">>, <<"*">>, req1)
    {"home", req2, state}
  end

  def terminate(_reason, _request, _state), do:    :ok
end
