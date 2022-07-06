const express = require("express");
const app = express();
const cors = require("cors");
const pool = require("./db");

//Middleware
app.use(cors())
app.use(express.json()); //req.body

//GET all posts
app.get("/posts", async(req, res) => {
    try {
        const allPosts = await pool.query("SELECT * FROM posts");
        res.json(allPosts.rows)
    } catch (err) {
        console.error(err.message);
    }
})

//GET a post based on its rank
app.get("/posts/:id", async(req, res) => {
    try {
        const { id } = req.params;
        const aPost = await pool.query(
            "SELECT * FROM posts WHERE id = $1",
            [id]
        );
        res.json(aPost.rows[0])
    } catch (err) {
        console.error(err.message);
    }
})

//Listen on port 5000
app.listen(5000, () => {
    console.log("Server has started on port 5000");
})