const express = require('express');
const mysql = require('mysql');
const app = express();
const port = 3000;

// Set up database connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'flutter_chat'
});

db.connect(err => {
  if (err) {
    console.error('Error connecting to the database: ' + err.stack);
    return;
  }
  console.log('Connected to the database with thread ID: ' + db.threadId);
});

app.post('/messages', (req, res) => {
  db.query('SELECT chat_messages.text, users.name FROM users RIGHT JOIN chat_messages ON users.user_id = chat_messages.user_id WHERE 1;', (err, results) => {
    if (err) throw err;
    res.send(results);
  });
});

app.post('/add_message', (req, res) => {
  console.log("req.body:", req.body);
  db.query('SELECT chat_messages.text, users.name FROM users RIGHT JOIN chat_messages ON users.user_id = chat_messages.user_id WHERE 1;', (err, results) => {
    if (err) throw err;
    res.send(results);
  });
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
