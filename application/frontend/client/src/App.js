import React, { Fragment } from "react";
import './App.css';

//components
import ListPosts from "./components/ListPosts";
import Title from "./components/Title";

function App() {
    return <Fragment>
        <div className="container">
            <Title />
            <ListPosts />
        </div>
    </Fragment>;
}

export default App;
