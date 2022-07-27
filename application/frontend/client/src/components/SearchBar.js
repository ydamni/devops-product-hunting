import React, { useState } from "react"

const SearchBar = ({callback}) => {
    const [innerValue, setInnerValue] = useState("");
    const handleSubmit = e => {
        e.preventDefault();
        callback(innerValue);
    };

    return (
        <form onSubmit={handleSubmit}>
            <label htmlFor="search">Search a product</label>
            <input type="text" name="search" className="form-control" value={innerValue} onChange={(e) => setInnerValue(e.target.value)}/>
        </form>
    )
}

export default SearchBar;
