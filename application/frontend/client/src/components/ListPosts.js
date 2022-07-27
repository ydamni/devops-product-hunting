import React, { Fragment, useEffect, useState } from "react";
import ShowDetails from "./ShowDetails";
import Pagination from "./Pagination";
import SearchBar from "./SearchBar";

//Import FontAwesome
import { library } from '@fortawesome/fontawesome-svg-core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faSort } from '@fortawesome/free-solid-svg-icons'
library.add(faSort)

const API_URL = process.env.REACT_APP_API_URL;

const ListPosts = () => {
    const [posts, setPosts] = useState([]);
    const [allPosts, setAllPosts] = useState([]);
    const [currentPage, setCurrentPage] = useState(1);
    const [postsPerPage] = useState(25);
    const totalPosts = posts.length;
    const [order, setOrder] = useState("desc");
    const [searchValue, setSearchValue] = useState("");

    //GET request from API to get posts
    const getPosts = async() => {
        const response = await fetch(API_URL);
        const jsonData = await response.json();
        setAllPosts(jsonData);
    }

    //Get all posts once
    useEffect(() => {
        getPosts();
    }, []);

    //Add posts when allPosts variable is filled
    useEffect(() => {
        setPosts(allPosts);
    }, [allPosts]); // eslint-disable-line react-hooks/exhaustive-deps

    //Sort posts
    const sortPosts = (header) => {
        if (order === "asc") {
            setOrder("desc");
            setPosts(posts.sort((a, b) => {
                if (typeof a[header] === 'number' || a[header] instanceof Number) {
                    return b[header] - a[header];
                }
                else {
                    return b[header].toLowerCase() > a[header].toLowerCase() ? 1 : -1;
                }
            }));
        }
        else {
            setOrder("asc");
            setPosts(posts.sort((a, b) => {
                if (typeof a[header] === 'number' || a[header] instanceof Number) {
                    return a[header] - b[header];
                }
                else {
                    return a[header].toLowerCase() > b[header].toLowerCase() ? 1 : -1;
                }
            }));
        }
    }

    //Show posts of current page
    const indexOfLastPost = currentPage * postsPerPage;
    const indexOfFirstPost = indexOfLastPost - postsPerPage;
    const currentPosts = posts.slice(indexOfFirstPost, indexOfLastPost);

    //Filter posts based on search value inside search bar
    const filterPosts = (searchValue) => {
        if (searchValue === "") {
            return allPosts;
        }
        else {
            return allPosts.filter((post) =>
                post.id.toString() === searchValue ||
                post.name.toLowerCase().includes(searchValue.toLowerCase()) ||
                post.tagline.toLowerCase().includes(searchValue.toLowerCase())
            );
        }
    }

    //Apply posts filtering when search bar is used
    useEffect(() => {
        setCurrentPage(1);
        const filteredPosts = filterPosts(searchValue);
        setPosts(filteredPosts);
    }, [searchValue]); // eslint-disable-line react-hooks/exhaustive-deps

    //Redirect to URL onclick
    const getUrl = (post) => {
        window.open(post.url, '_blank');
    }

    return (
        <Fragment>
            <Pagination posts={posts} postsPerPage={postsPerPage} totalPosts={totalPosts} currentPage={currentPage} setCurrentPage={setCurrentPage}/>
            <br></br>
            <SearchBar callback={(searchValue) => setSearchValue(searchValue)}/>
            <table className="table table-fixed table-striped table-bordered mt-5 text-center">
                <thead className="thead-light">
                    <tr>
                        <th className="align-top" onClick={() => sortPosts("id")}>Rank<br></br><FontAwesomeIcon icon="fas fa-sort" /></th>
                        <th className="align-top w-25" onClick={() => sortPosts("name")}>Name<br></br><FontAwesomeIcon icon="fas fa-sort" /></th>
                        <th className="align-top" onClick={() => sortPosts("votesCount")}>Upvotes<br></br><FontAwesomeIcon icon="fas fa-sort" /></th>
                        <th className="align-top" onClick={() => sortPosts("reviewsRating")}>Rating<br></br><FontAwesomeIcon icon="fas fa-sort" /></th>
                        <th className="align-top w-25">Short Description</th>
                        <th className="align-top">Details</th>
                        <th className="align-top">Link</th>
                    </tr>
                </thead>
                <tbody>
                    {currentPosts.map(post => (
                        <tr key={post.id}>
                            <td className="col-1">{post.id}</td>
                            <td className="col-3">{post.name}</td>
                            <td className="col-1">{post.votesCount}</td>
                            <td className="col-1">{post.reviewsRating}/5</td>
                            <td className="col-3">{post.tagline}</td>
                            <td className="col-1"><ShowDetails post={post} /></td>
                            <td className="col-1"><button className="btn btn-primary" onClick={() => getUrl(post)}>Go to Product page</button></td>
                        </tr>
                    ))}
                </tbody>
            </table>
            <Pagination posts={posts} postsPerPage={postsPerPage} totalPosts={totalPosts} currentPage={currentPage} setCurrentPage={setCurrentPage}/>
        </Fragment>
    );
};

export default ListPosts;
