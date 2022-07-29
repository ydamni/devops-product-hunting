import React, { Fragment } from "react";

const ShowDetails = ({post}) => {

    //Redirect to URL onclick
    const getUrl = () => {
        window.open(post.url, '_blank');
    }

    //Format date YYYY-MM-DDThh:mm:ssZ to YYYY-MM-DD (ISO 8601 international date format)
    const formatDate = () => {
        return new Date(post.createdAt).toISOString().split('T')[0];
    }

    return (
        <Fragment>
            <button type="button" className="btn btn-primary" data-bs-toggle="modal" data-bs-target={`#id${post.id}`}>More</button>
            <div className="modal fade" tabIndex="-1" id={`id${post.id}`}>
                <div className="modal-dialog">
                    <div className="modal-content">
                        <div className="modal-header">
                            <h4 className="modal-title">Rank {post.id} - {post.name}</h4>
                            <button type="button" className="btn-close" data-bs-dismiss="modal">&times;</button>
                        </div>
                        <div className="modal-body mt-3">
                            <h4 className="fw-bold">{post.tagline}</h4>
                            <div className="text-left font-weight-light mt-2 fw-light">Published: {formatDate()}</div>
                            <div className="mt-4 mb-4">{post.description !== null ? post.description : "This product has no description."}</div>
                        </div>
                        <div className="modal-footer">
                            <button className="btn btn-primary" onClick={() => getUrl()}>Go to Product page</button>
                            <button type="button" className="btn btn-danger" data-bs-dismiss="modal">Close</button>
                        </div>
                    </div>
                </div>
            </div>
        </Fragment>
    );
};

export default ShowDetails;
