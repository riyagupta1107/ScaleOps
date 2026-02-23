const express = require('express');
const app = express();

app.use(express.json());

// The Health Check Route (Our Dummy Gate)
app.get('/api/health', (req, res) => {
    res.status(200).json({ status: 'success', message: 'API is ready for AWS!' });
});

module.exports = app;