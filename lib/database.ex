use Amnesia

defmodule Message do
  defstruct user_id: nil, content: nil, send_time: nil
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
        :participations,
        messages: [Message]
      ],
      type: :ordered_set
    )
end
