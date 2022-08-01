defmodule Mnesia_storage do
  use GenServer, Amnesia.Database
  require Amnesia
  require Amnesia.Helper
  require Database.User
  require Database.Chat

  alias Database.User
  alias Database.Chat

  alias Amnesia.Seletion

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(args) do
    {:ok, args}
  end

  def read(tag) do
    Amnesia.transaction do
      User.read(tag)
    end
  end

  def friend_request(sender, recipient) do
    sender_obj = User.read!(sender)
    recipient_obj = User.read!(recipient)

    Amnesia.transaction do
      %{recipient_obj | pending_invites: MapSet.put(recipient_obj.pending_invites, sender_obj.username)} |> User.write()
    end
  end

  def create_chat(username, friend_username) do
    Amnesia.transaction do
      %Chat{
        name: "#{username} #{friend_username}",
        participations:
          [
            %People{username: username, last_message_seen: false},
            %People{username: friend_username, last_message_seen: false}
          ]
        } |> Chat.write
    end
  end

  def accept_friend_request(username, friend) do
      user_obj = User.read!(username)
      friend_obj = User.read!(friend)

      Amnesia.transaction do
        %{user_obj | friend_list: MapSet.put(user_obj.friend_list, friend_obj.username),
          pending_invites: MapSet.delete(user_obj.pending_invites, friend_obj.username)} |> User.write

        %{friend_obj | friend_list: MapSet.put(friend_obj.friend_list, user_obj.username)} |> User.write
      end
      create_chat(username, friend)
  end

  def deny_friend_request(username, friend) do
    user_obj = User.read!(username)
    friend_obj = User.read!(friend)

    Amnesia.transaction do
      %{user_obj | pending_invites: MapSet.delete(user_obj.pending_invites, friend_obj.username)} |> User.write
    end
  end

  def log do
    Mnesia_storage.register("iv", "@", "1")
    Mnesia_storage.register("jr", "@", "1")
    Mnesia_storage.friend_request("iv", "jr")
    Mnesia_storage.accept_friend_request("jr", "iv")
  end

  def send_message(sender, recipient, message) do
    chat_obj = Chat.read!("#{sender} #{recipient}")
    chat_obj = if chat_obj == nil, do: Chat.read!("#{recipient} #{sender}"), else: chat_obj

    Amnesia.transaction do
      %{chat_obj | messages: [
         %Message{user_id: sender, content: message, send_time: Time.utc_now()} | chat_obj.messages
        ], participations:  List.update_at(chat_obj.participations, find_index(Enum.map(chat_obj.participations,
        fn x ->
          x.username
        end), sender), fn x ->
          %{x | last_message_seen: true}
        end)} |> Chat.write

    end
  end

  def edit_message(chat_name, id, content) do
    chat_obj = Chat.read!(chat_name)
    message = Enum.at(chat_obj.messages, id)
    cond do
      Time.diff(Time.utc_now(), message.send_time, :second) > 60*60 ->
        %{message: "You can edit message only within a minute"}
      true ->
      %{ chat_obj  | messages: List.update_at(chat_obj.messages, id, fn(x) ->
          %{message | content: content}
        end) } |> Chat.write!()
      end
  end

  def authenticate_user(token) do
    [res = {_, username, _, _, _, _, _, friendList,_}] = User.match!(auth_token: token).values
    username
  end

  defp isSeen(chat_obj, from) do
    IO.inspect(Enum.map(chat_obj.participations, fn x -> x.last_message_seen end))
    val = find_index(Enum.map(chat_obj.participations,
      fn x ->
        case x.username != from do
          true ->
            x.last_message_seen
          false ->
            false
        end
      end), true)
    if val == -1, do: false, else: true
  end

  def get_friend_list(username), do: %{response: MapSet.to_list(User.read!(username).friend_list)}

  def get_friend_requests(username), do: User.read!(username).pending_invites

  def remove_friend(client, friend) do
    chat_obj = Chat.read!("#{client} #{friend}")
    chat_obj = if chat_obj == nil, do: Chat.read!("#{friend} #{client}"), else: chat_obj

    client_obj = User.read!(client)
    friend_obj = User.read!(friend)

    %{client_obj | friend_list: MapSet.delete(client_obj.friend_list, friend)} |> User.write!
    %{friend_obj | friend_list: MapSet.delete(friend_obj.friend_list, client)} |> User.write!

    Chat.delete!(chat_obj.name)
  end

  def unreaded_messages(user) do
    Amnesia.transaction do
      Chat.foldl(0,
      fn (rec, accm) ->
        {_chat, _chatName, participations, messages} = rec
        case Enum.any?(participations, &(&1.username == user and &1.last_message_seen == false)) do
          true ->
            accm + Enum.reduce_while(messages, 0, fn (x,acc) ->
              if x.user_id != user, do:
                {:cont, acc + 1},
              else:
                {:halt, acc}
            end)
          false ->
            accm
        end
      end)
    end
  end

  def delete_message(chat_name, id) do
    chat_obj = Chat.read!(chat_name)
    message = Enum.at(chat_obj.messages, id)

    case isSeen(chat_obj, message.user_id) do
      true ->
        %{message: "You can't delete message that had already been seen"}
      false ->
        %{chat_obj | messages: List.delete_at(chat_obj.messages, id)} |> Chat.write!
    end
  end

  def getToken(username) do
    User.read!(username).auth_token
  end

  def read_users do
    Amnesia.transaction do
      User.foldl([], fn(rec, _Acc) -> IO.inspect(rec) end)
    end
  end
  # mix amnesia.create -d Database --disk

  defp find_index(arr, key) do
    res = Enum.with_index((arr)) |>
        Enum.filter_map(
          fn {x, _} -> x == key end, fn {_, i} -> i
        end)
    if Enum.count(res) == 1 do
        [k] = res
        k
     else
       -1
     end
  end

  def load_chat(username, chat_name) do
      chat_obj = Chat.read!(chat_name)
      IO.inspect(find_index(Chat.read!(chat_name).participations, username))
      %{chat_obj | participations: List.update_at(
        Chat.read!(chat_name).participations,
        find_index(
          Enum.map(chat_obj.participations,
            fn x ->
              x.username
          end), username),
            fn x ->
              %People{username: x.username, last_message_seen: true}
            end) } |> Chat.write!()
  end

  def generate_token() do
    :base64.encode(:crypto.strong_rand_bytes(32))
  end

  def register(name, mail, pass) do
    token = generate_token()
    Amnesia.transaction do
        %User{username: name, email: mail, password: pass, failed_login_attemps: 0,
          available_time: Time.utc_now(), auth_token: token} |> User.write()
    end
    %{token: token} # RESPOND
  end


  def login(username, pass) do
    acc = Amnesia.transaction do
      User.read(username)
    end

    too_soon = Time.compare(acc.available_time, Time.utc_now)
    cond do
      too_soon == :gt -> %{err: "You should wait"}
      acc.password == pass -> %{token: acc.auth_token}
      acc.failed_login_attemps == 3 ->
        Amnesia.transaction do
          %{ acc |
            failed_login_attemps: 0,
            available_time: Time.add(Time.utc_now(), 60000, :millisecond)
          } |> User.write()
        end
        %{err: "Too many requests"}
      true ->
        Amnesia.transaction do
          %{acc |
            failed_login_attemps: acc.failed_login_attemps+1,
            available_time: acc.available_time
           } |> User.write()
        %{err: "wrong password or username"}
        end
    end
  end

end
