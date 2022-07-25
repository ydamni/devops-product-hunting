import React, { Fragment, useEffect, useState } from "react";
import ShowDetails from "./ShowDetails";
import Pagination from "./Pagination";

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

    //Show all posts
    useEffect(() => {
        getPosts();
    }, []);

    //Show posts of current page
    const indexOfLastPost = currentPage * postsPerPage;
    const indexOfFirstPost = indexOfLastPost - postsPerPage;
    const currentPosts = posts.slice(indexOfFirstPost, indexOfLastPost);

    return (
        <Fragment>
            <table className="table table-striped table-bordered mt-5 text-center">
                <thead className="thead-light">
                    <tr>
                        <th>Rank</th>
                        <th>Name</th>
                        <th>Upvotes</th>
                        <th>Rating</th>
                        <th>Short Description</th>
                        <th>Details</th>
                        <th>Link</th>
                    </tr>
                </thead>
                <tbody>
                    {currentPosts.map(post => (
                        <tr key={post.post_id}>
                            <td>{post.id}</td>
                            <td>{post.name}</td>
                            <td>{post.votesCount}</td>
                            <td>{post.reviewsRating}/5</td>
                            <td>{post.tagline}</td>
                            <td><ShowDetails post={post} /></td>
                            <td><button className="btn btn-primary" onClick={() => getUrl(post)}>Go to Product page</button></td>
                        </tr>
                    ))}
                </tbody>
            </table>
            <Pagination posts={posts} postsPerPage={postsPerPage} totalPosts={totalPosts} currentPage={currentPage} setCurrentPage={setCurrentPage}/>
        </Fragment>
    );
};

export default ListPosts;
