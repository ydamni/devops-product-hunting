import React, { Fragment } from "react";
import './App.css';

//components
import ListPosts from "./components/ListPosts";

function App() {
  return <Fragment>
    <div className="container">
      <ListPosts />
    </div>
  </Fragment>;
}

export default App;
