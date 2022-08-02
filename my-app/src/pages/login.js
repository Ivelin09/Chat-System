import './register.css'
import { useState } from 'react'

import { useNavigate } from 'react-router-dom'

function App() {
  const [name, setName] = useState("")
  const [errorMessage, setErrorMessage] = useState("")

  const [password, setPassword] = useState()

  const navigate = useNavigate();
  

  async function func() {

    const res = await fetch("http://localhost:8080/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        username: name,
        password: password
      })
    }).then((res) => res.json())

    if(res.err)
      setErrorMessage(res.err)
    else {
      localStorage.setItem("token", res.token)
      navigate("/home")
    }
    console.log(res)
  }
  return (
    <div className="App" color="color: black">
      {errorMessage && <p>{errorMessage}</p>}
      <p>Username</p>
      <input type="text" name="username" onChange={(currName) => setName(currName.target.value)}/>
      <p> password </p>
      <input type="text" name="password" onChange={(currPassowrd) => setPassword(currPassowrd.target.value)}/>
      <input  onClick={func} type="submit" value="submit"/> 
    </div>
  );
}

export default App;
