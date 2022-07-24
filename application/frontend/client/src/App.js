import React, { Fragment } from "react";
import './App.css';

//components
import ListPosts from "./components/ListPosts";

function App() {
  return <Fragment>
    <div className="container">
      <h1 className="text-center mt-5">Top 500 most voted products on Product Hunt</h1>
      <ListPosts />
    </div>
  </Fragment>;
}

export default App;
