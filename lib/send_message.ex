defmodule Send_Message do

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

        cond do
          Auth_Handler.validate_token(body, :cowboy_req.headers(req)) == true ->
            content = Poison.decode!(body)
            Mnesia_storage.send_message(content["sender"], content["recipient"], content["message"])
            {:stop, :cowboy_req.reply(202, :cowboy_req.set_resp_body("Message successfuly sended", req)), state}
          true ->
            {:stop, :cowboy_req.reply(401, :cowboy_req.set_resp_body("Authentication failed", req)), state}
          end
      _ ->
        {:stop, :cowboy_req.reply(202, :cowboy_req.set_resp_body("No one to handle", req)), state}

      end
  end



  def home(request, state) do
    {"home", request, state}
  end

  def terminate(_reason, _request, _state), do:    :ok
end
