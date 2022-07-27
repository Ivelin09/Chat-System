defmodule Friend_Request do
  require Mnesia_storage
  def init(req, _state) do
    {:cowboy_rest, req, :nostate}
  end

  def allowed_methods(req, state) do
    {["GET", "PUT", "POST", "PATCH", "DELETE"], req, state}
  end

  def content_types_provided(req, state) do
    {[{"application/json", :home}], req, state}
  end

  def resource_exists(req, state) do
    case :cowboy_req.method(req) do
      "POST" ->
        {:ok, body, _Req} = :cowboy_req.read_body(req)
        content = Poison.decode!(body)

        path = :cowboy_req.path(req)
        IO.inspect(content)
        cond do
          path == "/friend_request" ->
            Mnesia_storage.friend_request(content["sender"], content["recipient"])
          path == "/friend_request/deny" -> Mnesia_storage.deny_friend_request(content["sender"], content["recipient"])
          path == "/friend_request/accept" -> Mnesia_storage.accept_friend_request(content["sender"], content["recipient"])
          path == "/friend_request/deny" -> Mnesia_storage.deny_friend_request(content["sender"], content["recipient"])
        end
        {:stop, :cowboy_req.reply(202, :cowboy_req.set_resp_body("Friend requested accepted", req)), state}
      _ ->
        {:stop, :cowboy_req.reply(202, :cowboy_req.set_resp_body("No one to handle", req)), state}
      end
  end
  def home(request, state) do
    {"home", request, state}
  end

  def terminate(_reason, _request, _state), do:    :ok
end
