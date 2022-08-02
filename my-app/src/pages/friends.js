import { useEffect, useState } from 'react';
import './friends.css';

function App() {
  const [username, setUsername] = useState("")
  const [friendList, addFriend] = useState([])
  const [requestList, addRequest] = useState([])

  useEffect(() => {
    async function fetchData() {
    
      let friendsApi = await fetch("http://localhost:8080/friend_request/get_friends", {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          "Set-Cookie": localStorage.getItem("token")
        }
      }).then((res) => res.json())

      let pendingApi = await fetch("http://localhost:8080/friend_request/get_pending", {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          "Set-Cookie": localStorage.getItem("token")
        }
      }).then((res) => res.json())

      addFriend(
        ...friendList, friendsApi.response
      )

      addRequest(
        ...requestList, pendingApi.response
      )

    }
    fetchData()
  }, [])

  function handleSubmit() {
    let apiRequest = fetch("http://localhost:8080/friend_request/send", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Set-Cookie": localStorage.getItem("token")
      },
      body: JSON.stringify({
        recipient: username 
      })
    })

    return apiRequest.response
  }

  function acceptFriendRequest(username) {
    console.log("here")
    let apiRequest = fetch("http://localhost:8080/friend_request/accept", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Set-Cookie": localStorage.getItem("token")
      },
      body: JSON.stringify({
        recipient: username
      })
    })
  }

  return (
    <div className="" color="color: black">
      <div className="container">
        <div className="item-1">
          <h1> friend request </h1>
          <input type="text" name="password" onChange={(username) => setUsername(username.target.value)}/>
          <input  onClick={handleSubmit} type="submit" value="submit"/> 
        </div>
        <div className="item-2">
          <h2>friends</h2>
            {friendList.map(item => <p key={item}>{item}</p>)}
        </div>
        <div className="item-3">
          <h2> pending </h2>
          {requestList.map(item => <p key={item} onClick={() => acceptFriendRequest(item)}>{item}</p>)}
        </div>
      </div>
      
    </div>
  );
}

export default App;
