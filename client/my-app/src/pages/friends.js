import './register.css'
import { useState } from 'react'

import { useNavigate } from 'react-router-dom'

async function App() {
  const [name, setName] = useState("")
  const [errorMessage, setErrorMessage] = useState("")

  const friends = await fetch("http://localhost:8080/friends/get", {
        method: "GET",
        headers: {
            "Set-Cookie": localStorage.getItem("token")
        }
    })
  const [friendList, addFriend] = useState(
    ...friends.response
  )

  async function func() {
    const res = await fetch("http://localhost:8080/friend_request/send", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },       
      body: JSON.stringify({
        sender: localStorage.read("token"),
        recipient: name
      })
    }).then((res) => res.json())

    if(res.err)
      setErrorMessage(res.err)

    addFriend([...friendList, res.friend])

    console.log(res)
  }
  return (
    <div className="App" color="color: black">
      {errorMessage && <p>{errorMessage}</p>}
      <p>Username</p>
      <input type="text" name="username" onChange={(username) => setName(username.target.value)}/>
      <input  onClick={func} type="submit" value="submit"/> 
      <ul>
        {friendList.map(item => <li key={item}>{item}</li>)}
      </ul>
    </div>
  );
}

export default App;
