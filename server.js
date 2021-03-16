const express = require('express');

const app = express();
const PORT = 5000;

app.use(express.json());

app.listen(PORT, () => {
  console.log(`Listening in on port ${PORT}`)
});