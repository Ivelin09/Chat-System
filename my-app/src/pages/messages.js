import { useEffect, useState } from 'react';
import './friends.css';

import { useNavigate } from 'react-router-dom'

function App() {
    const [friendList, addFriend] = useState([])

    const navigate = useNavigate()

    useEffect(() => {
        async function fetchData() {
        
        let friendsApi = await fetch("http://localhost:8080/friend_request/get_friends", {
            method: "GET",
            headers: {
            "Content-Type": "application/json",
            "Set-Cookie": localStorage.getItem("token")
            }
        }).then((res) => res.json())

        addFriend(
            ...friendList, friendsApi.response
        )
    }
    fetchData()
  }, [])

  function openChat(user) {
    console.log(user)

    navigate(`/chat/${user}`)
  }

  return (
    <div className="" color="color: black">
        {friendList.map(item => <button key={item} onClick={() => openChat(item)}>{item}</button>)}
    </div>
  );
}

export default App;
