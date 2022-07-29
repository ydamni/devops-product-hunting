import React from "react";

const Pagination = ({ postsPerPage, totalPosts, currentPage, setCurrentPage }) => {
    
    const maxPage = Math.ceil(totalPosts / postsPerPage);

    //Define page numbers
    const pageNumbers = [];
    for(let i = 1; i <= maxPage; i++) {
        pageNumbers.push(i);
    };

    //Change current page to selected page
    const paginate = (number) => setCurrentPage(number);

    //Change current page to previous page
    const paginatePrevious = () => {
        if (currentPage > 1) {
            setCurrentPage(currentPage - 1);
        };
    };

    //Change current page to next page
    const paginateNext = () => {
        if (currentPage < maxPage) {
            setCurrentPage(currentPage + 1);
        };
    };

    return (
        <nav>
            <ul className="pagination justify-content-center">
                <li className="page-item">
                    <a onClick={() => paginatePrevious()} href="#!" className="page-link">
                        Previous
                    </a>
                </li>
                {pageNumbers.map(number => {
                    //Show page numbers based on currentPage + Add "..." when large number of pages
                    if ((number < currentPage + 2 && number > currentPage - 2) || number <= 1 || number > maxPage - 1){
                        return (
                            <li key={number} className={currentPage === number ? 'active page-item' : 'page-item'}>
                                <a onClick={() => paginate(number)} href="#!" className="page-link">{number}</a>
                            </li>
                        );
                    } else if ((number === 2 && currentPage > 2) || (number === maxPage - 1 && currentPage < maxPage - 1)) {
                        return (
                            <li key={number} className="page-item">
                                <a href="#!" className="page-link">...</a>
                            </li>
                        );
                    } else {
                        return null;
                    };
                })}
                <li className="page-item">
                    <a onClick={() => paginateNext()} href="#!" className="page-link">
                        Next
                    </a>
                </li>
            </ul>
        </nav>
    );
};

export default Pagination;
