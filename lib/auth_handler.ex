defmodule Auth_Handler do
  def validate_token(body, headers) do
    Mnesia_storage.getToken(Poison.decode!(body)["sender"]) == headers["token"]
  end
end
