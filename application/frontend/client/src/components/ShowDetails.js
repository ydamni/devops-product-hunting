import React, { Fragment } from "react";

const ShowDetails = ({post}) => {
    return (
        <Fragment>
            <button type="button" className="btn btn-primary" data-bs-toggle="modal" data-bs-target={`#id${post.id}`}>
                More
            </button>
            <div className="modal fade" tabindex="-1" id={`id${post.id}`}>
                <div className="modal-dialog">
                    <div className="modal-content">
                        <div className="modal-header">
                            <h4 className="modal-title">{post.name} - Rank {post.id}</h4>
                            <button type="button" className="btn-close" data-bs-dismiss="modal">&times;</button>
                        </div>
                        <div className="modal-body">
                            <br />
                            <h5>{post.tagline}</h5>
                            <div className="text-left font-weight-light">Publish date: {post.createdAt}</div>
                            <br />
                            <div>{post.description}</div><br />
                        </div>
                        <div className="modal-footer">
                            <button type="button" className="btn btn-danger" data-bs-dismiss="modal">
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
