import React from "react";

const Pagination = ({ postsPerPage, totalPosts, paginate, paginatePrevious, paginateNext, currentPage }) => {
    const pageNumbers = [];

    for(let i = 1; i <= Math.ceil(totalPosts / postsPerPage); i++) {
        pageNumbers.push(i);
    }

    return (
        <nav>
            <ul class="pagination justify-content-center">
                <li class="page-item">
                    <a onClick={() => paginatePrevious()} href="#!" class="page-link">
                        Previous
                    </a>
                </li>
                {pageNumbers.map(number => (
                    <li key={number} class={currentPage === number ? 'active page-item' : 'page-item'}>
                        <a onClick={() => paginate(number)} href="#!" class="page-link">
                            {number}
                        </a>
                    </li>
                ))}
                <li class="page-item">
                    <a onClick={() => paginateNext()} href="#!" class="page-link">
                        Next
                    </a>
                </li>
            </ul>
        </nav>
    )
}

export default Pagination;
