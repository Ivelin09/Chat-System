defmodule Register do


  require Mnesia_storage
  def init(req, _state) do
    {:cowboy_rest, req, :nostate}
  end

  def allowed_methods(req, state) do
    {["GET", "PUT", "POST", "PATCH", "DELETE"], req, state}
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

  def options(req, state) do
    req1 = :cowboy_req.set_resp_header(<<"access-control-allow-methods">>, <<"GET, OPTIONS">>, req)
    req2 = :cowboy_req.set_resp_header(<<"access-control-allow-origin">>, <<"*">>, req1)
    {:ok, req2, state}
  end

  def resource_exists(req, state) do
    IO.inspect(:cowboy_req.path(req))
    case :cowboy_req.method(req) do
      "POST" ->
        IO.inspect("here")
        {_, body, _Req} = :cowboy_req.read_body(req)
        content = Poison.decode!(body)
        IO.inspect(content)
        respond = Mnesia_storage.register(content["name"], content["email"], content["password"])
        req2 = :cowboy_req.set_resp_header(<<"access-control-allow-origin">>, <<"*">>, req)
        {:stop, :cowboy_req.reply(202, :cowboy_req.set_resp_body("token: \"#{respond.token}\" ", req2)), state}
      "GET" ->
        IO.inspect("here")
        req2 = :cowboy_req.set_resp_header(<<"access-control-allow-origin">>, <<"*">>, req)
        {:stop, :cowboy_req.reply(202, :cowboy_req.set_resp_body("No one to handle", req2)), state}
      _ ->
        IO.inspect("there")
        {:stop, :cowboy_req.reply(202, :cowboy_req.set_resp_body("No one to handle", req)), state}
      end
  end



  def home(request, state) do
    req1 = :cowboy_req.set_resp_header(<<"access-control-allow-methods">>, <<"GET, OPTIONS">>, request)
    req2 = :cowboy_req.set_resp_header(<<"access-control-allow-origin">>, <<"*">>, req1)
    {"home", req2, state}
  end

  def terminate(_reason, _request, _state), do:    :ok
end
