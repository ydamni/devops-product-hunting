import React, { Fragment, useEffect, useState } from "react";
import ShowDetails from "./ShowDetails";
import Pagination from "./Pagination";

//Import FontAwesome
import { library } from '@fortawesome/fontawesome-svg-core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faSort } from '@fortawesome/free-solid-svg-icons'
library.add(faSort)

const API_URL = process.env.REACT_APP_API_URL;

//Redirect to URL onclick
const getUrl = (post) => {
    try {
        window.open(post.url, '_blank');
    } catch (err) {
        console.error(err.message);
    }
}

const ListPosts = () => {
    const [posts, setPosts] = useState([]);
    const [currentPage, setCurrentPage] = useState(1);
    const [postsPerPage] = useState(25);
    const totalPosts = posts.length;
    const [order, setOrder] = useState("desc");

    //GET all posts
    const getPosts = async() => {
        try {
            const response = await fetch(API_URL);
            const jsonData = await response.json();
            setPosts(jsonData);
        } catch (err) {
            console.error(err.message);
        }
    }

    //Sort posts
    const sortPosts = (val) => {
        if (order === "asc") {
            setOrder("desc");
            setPosts(posts.sort((a, b) => {
                if (typeof a[val] === 'number' || a[val] instanceof Number) {
                    return b[val] - a[val]
                }
                else {
                    return b[val].toLowerCase() > a[val].toLowerCase() ? 1 : -1
                }
            }));
        }
        else {
            setOrder("asc");
            setPosts(posts.sort((a, b) => {
                if (typeof a[val] === 'number' || a[val] instanceof Number) {
                    return a[val] - b[val]
                }
                else {
                    return a[val].toLowerCase() > b[val].toLowerCase() ? 1 : -1
                }
            }));
        }
    }

    //Show posts of current page
    const indexOfLastPost = currentPage * postsPerPage;
    const indexOfFirstPost = indexOfLastPost - postsPerPage;
    const currentPosts = posts.slice(indexOfFirstPost, indexOfLastPost);

    useEffect(() => {
        getPosts();
        sortPosts("id");
    }, []);

    return (
        <Fragment>
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
                        <tr key={post.post_id}>
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
