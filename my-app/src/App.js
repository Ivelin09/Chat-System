import ReactDOM from "react-dom/client";
import { BrowserRouter, Routes, Route } from "react-router-dom";

import Register from './pages/register'
import Home from './pages/home'
import Login from './pages/login'
import Friends from './pages/friends'
import Chats from './pages/messages'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/register" element={<Register />}/>
        <Route path="/login" element={<Login/>}/>
        <Route path="/home" element={<Home/>}/>
        <Route path ="/friends" element={<Friends/>}/>
        <Route path="/messages" element={<Chats/>}/>
      </Routes>
    </BrowserRouter>
  );
}

