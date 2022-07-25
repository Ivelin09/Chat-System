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

  def resource_exists(req, state) do
    case :cowboy_req.method(req) do
      "POST" ->
        {_, body, _Req} = :cowboy_req.read_body(req)
        content = Poison.decode!(body)
        IO.inspect(content)
        respond = Mnesia_storage.register(content["name"], content["email"], content["password"])
        {:stop, :cowboy_req.reply(202, :cowboy_req.set_resp_body("token: \"#{respond.token}\" ", req)), State}

      _ ->
        {:stop, :cowboy_req.reply(202, :cowboy_req.set_resp_body("No one to handle", req)), State}
      end
  end



  def home(request, state) do
    {"home", request, state}
  end

  def terminate(_reason, _request, _state), do:    :ok
end
