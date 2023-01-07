const app = require('express')();

app.get('/', (req, res) => {
  res.send('Hello, World!\n');
});

app.listen(80, '0.0.0.0');