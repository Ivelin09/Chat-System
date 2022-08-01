import { useNavigate } from "react-router-dom";


function App() {
    const navigate = useNavigate();

    async function load() {
        const res = await fetch("http://localhost:8080/home", {
            headers: {
                "Content-Type": "application/json",
                "Set-Cookie": localStorage.getItem("token")
            }
        }).then((res) => res.json())
    
        return res
    }
  return (
    <div className="">
        <p onClick={load}>here</p>
        <button onClick={() => navigate("/friends")}>Friends</button>
    </div>
  );
}

export default App;
