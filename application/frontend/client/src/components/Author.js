import React, { Fragment } from "react";

//Import react-icons
import { FaGithub } from "react-icons/fa";

const Author = () => {
    return (
        <Fragment>
            <div className="mt-4">made by <a href="https://github.com/ydamni">ydamni</a></div>
            <h5><a href="https://github.com/ydamni/devops-product-hunting"><FaGithub /> Github</a></h5>
        </Fragment>
    )
}

export default Author;
