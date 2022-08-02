import './register.css'
import { useState } from 'react'

import { useNavigate } from 'react-router-dom'

function App() {
  const [name, setName] = useState("")
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")

  const navigate = useNavigate();
  
  async function func() {

    const res = await fetch("http://localhost:8080/register", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        username: name,
        email: email, 
        password: password
      })
    }).then((res) => res.json())

    localStorage.setItem("token", res.token)

    navigate("/home")
    console.log(res)
  }
  return (
    <div className="App" color="color: black">
      <p>Username</p>
      <input type="text" name="username" onChange={(currName) => setName(currName.target.value)}/>
      <p>email</p> 
      <input type="text" name="email" onChange={(currEmail) => setEmail(currEmail.target.value)}/>
      <p> password </p>
      <input type="text" name="password" onChange={(currPassowrd) => setPassword(currPassowrd.target.value)}/>
      <input  onClick={func} type="submit" value="submit"/> 
    </div>
  );
}

export default App;
