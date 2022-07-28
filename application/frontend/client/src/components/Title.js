import React from "react";

//Import react-icons
import { FaGithub } from "react-icons/fa";

const Title = () => {
    return (
        <div>
            <div className="mt-4">made by <a href="https://github.com/ydamni">ydamni</a></div>
            <h5><a href="https://github.com/ydamni/devops-product-hunting"><FaGithub /> Github</a></h5>
            <h1 className="text-center mt-5">Product Hunting</h1>
            <h3 className="text-center">Find the best products from Product Hunt in a few seconds</h3>
        </div>
    )
}

export default Title;
