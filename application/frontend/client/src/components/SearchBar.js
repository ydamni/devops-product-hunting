import React, { useEffect, useState } from "react";

const SearchBar = ({callback}) => {
    const [innerValue, setInnerValue] = useState("");

    const refreshSearch = () => {
        callback(innerValue);
    };

    //Refresh search when search bar value changes
    useEffect(() => {
        refreshSearch();
    }, [innerValue]); // eslint-disable-line react-hooks/exhaustive-deps

    return (
        <div className="searchBar">
                <input type="text" name="search" className="form-control mt-5 mb-4" value={innerValue} onChange={(e) => setInnerValue(e.target.value)} placeholder="Search a product"/>
        </div>
    );
};

export default SearchBar;
