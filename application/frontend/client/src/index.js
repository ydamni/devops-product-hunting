import React from 'react';
import ReactDOM from 'react-dom/client';
import "bootswatch/dist/lumen/bootstrap.min.css"; //Bootstrap theme
import './index.css';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
