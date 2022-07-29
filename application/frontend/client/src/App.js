import React, { Fragment } from "react";
import './App.css';

//components
import ListPosts from "./components/ListPosts";
import Title from "./components/Title";
import Author from "./components/Author";

function App() {
    return (
        <Fragment>
            <div className="container">
                <Author />
                <Title />
                <ListPosts />
            </div>
        </Fragment>
    );
};

export default App;
