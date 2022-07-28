import React, { useState } from "react";

const SearchBar = ({callback}) => {
    const [innerValue, setInnerValue] = useState("");
    const handleSubmit = e => {
        e.preventDefault();
        callback(innerValue);
    };

    return (
        <div className="searchBar">
            <form onSubmit={handleSubmit}>
                <input type="text" name="search" className="form-control mt-5 mb-4" value={innerValue} onChange={(e) => setInnerValue(e.target.value)} placeholder="Search a product"/>
            </form>
        </div>
    )
}

export default SearchBar;
