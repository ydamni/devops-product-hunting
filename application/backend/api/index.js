const express = require("express");
const app = express();
const cors = require("cors");
const pool = require("./db");

//Middleware
app.use(cors())
app.use(express.json()); //req.body

//GET API health
app.get("/health", async(req, res) => {
    try {
        const start = process.hrtime(); //Start request time
        const healthcheck = {
            message: 'OK',
            uptime: process.uptime(),
            timestamp: Date.now(),
            responsetime: process.hrtime(start) // Calculate response time based on request time
        };
        res.json(healthcheck)
    } catch (err) {
        console.error(err.message);
    }
})

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