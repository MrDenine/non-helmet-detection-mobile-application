const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
    res.json({status : true, data : 'Api Works' });
})

module.exports = router;