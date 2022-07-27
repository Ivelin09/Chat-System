use Amnesia

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
end
