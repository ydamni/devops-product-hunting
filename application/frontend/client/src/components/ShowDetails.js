import React, { Fragment } from "react";

const ShowDetails = ({post}) => {
    return (
        <Fragment>
            <button type="button" className="btn btn-warning" data-toggle="modal" data-target={`#id${post.id}`}>
                Show more
            </button>
            <div className="modal" id={`id${post.id}`}>
            <div className="modal-dialog">
                <div className="modal-content">
                <div className="modal-header">
                    <h4 className="modal-title">{post.name} - Rank {post.id}</h4>
                    <button type="button" className="close" data-dismiss="modal">&times;</button>
                </div>
                <div className="modal-body">
                    <br />
                    <h5>{post.tagline}</h5>
                    <div className="text-left font-weight-light">Publish date: {post.createdAt}</div>
                    <br />
                    <div>{post.description}</div><br />
                </div>
                <div className="modal-footer">
                    <button type="button" className="btn btn-danger" data-dismiss="modal">
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
