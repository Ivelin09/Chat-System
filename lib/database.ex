use Amnesia

defmodule Message do
  defstruct [:user_id, :content, :send_time]
end

defmodule People do
  defstruct [:username, last_message_seen: false]
end

defdatabase Database do
    deftable(
      User,
      [
        :username,
        :email,
        :password,
        failed_login_attemps: 0,
        available_time: Time.utc_now(),
        auth_token: nil,
        friend_list: MapSet.new(),
        pending_invites: MapSet.new()
      ],
      type: :ordered_set
    )
    deftable(
      Chat,
      [
        :name,
        participations: [%People{}],
        messages: [%Message{}]
      ],
      type: :ordered_set
    )
end
