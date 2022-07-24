import React, { Fragment } from "react";

const ShowDetails = ({post}) => {
    return (
        <Fragment>
            <button type="button" class="btn btn-warning" data-toggle="modal" data-target={`#id${post.id}`}>
                Show more
            </button>
            <div class="modal" id={`id${post.id}`}>
            <div class="modal-dialog">
                <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title">{post.name} - Rank {post.id}</h4>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <div class="modal-body">
                    <br />
                    <h5>{post.tagline}</h5>
                    <div class="text-left font-weight-light">Publish date: {post.createdAt}</div>
                    <br />
                    <div>{post.description}</div><br />
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-danger" data-dismiss="modal">
                        Close
                    </button>
                </div>

                </div>
            </div>
            </div>
        </Fragment>
    );
};

export default ShowDetails;
