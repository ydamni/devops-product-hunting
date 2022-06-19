import React, { Fragment, useEffect, useState } from "react";
import ShowDetails from "./ShowDetails";

const API_URL = process.env.REACT_APP_API_URL;

const ListPosts = () => {
    const [posts, setPosts] = useState([]);

    //GET all posts
    const getPosts = async() => {
        try {
            const response = await fetch(API_URL)
            const jsonData = await response.json()
            setPosts(jsonData);
        } catch (err) {
            console.error(err.message);
        }
    }

    //Show all posts
    useEffect(() => {
        getPosts();
    }, []);

    console.log(posts);
    return (
        <Fragment>
        <h1 className="text-center mt-5">Top 500 most voted products on Product Hunt</h1>
            <table class="table table-striped table-bordered mt-5 text-center">
                <thead class="thead-light">
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
                    {posts.map(post => (
                        <tr key={post.post_id}>
                            <td>{post.id}</td>
                            <td>{post.name}</td>
                            <td>{post.votesCount}</td>
                            <td>{post.reviewsRating}/5</td>
                            <td>{post.tagline}</td>
                            <td><ShowDetails post = {post} /></td>
                            <td><button class="btn btn-primary" onClick={() => getUrl(post)}>Go to Product page</button></td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </Fragment>
        
    );
};

//Redirect to URL onclick
const getUrl = (post) => {
    try {
        window.open(post.url, '_blank');
        console.log(post.url)
    } catch (err) {
        console.error(err.message);
    }
}

export default ListPosts;
