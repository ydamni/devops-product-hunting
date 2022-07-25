import React from "react";

const Pagination = ({ postsPerPage, totalPosts, currentPage, setCurrentPage }) => {
    
    //Define page numbers
    const pageNumbers = [];
    for(let i = 1; i <= Math.ceil(totalPosts / postsPerPage); i++) {
        pageNumbers.push(i);
    }

    //Change current page to selected page
    const paginate = (number) => setCurrentPage(number);

    //Change current page to previous page
    const paginatePrevious = () => {
        if (currentPage > 1) {
            setCurrentPage(currentPage - 1);
        }
    };

    //Change current page to next page
    const paginateNext = () => {
        if (currentPage < Math.ceil(totalPosts / postsPerPage)) {
            setCurrentPage(currentPage + 1);
        }
    };

    return (
        <nav>
            <ul className="pagination justify-content-center">
                <li className="page-item">
                    <a onClick={() => paginatePrevious()} href="#!" className="page-link">
                        Previous
                    </a>
                </li>
                {pageNumbers.map(number => (
                    <li key={number} className={currentPage === number ? 'active page-item' : 'page-item'}>
                        <a onClick={() => paginate(number)} href="#!" className="page-link">
                            {number}
                        </a>
                    </li>
                ))}
                <li className="page-item">
                    <a onClick={() => paginateNext()} href="#!" className="page-link">
                        Next
                    </a>
                </li>
            </ul>
        </nav>
    )
}

export default Pagination;
