const express = require('express');
const mysql = require('mysql');
const app = express();
const port = 3000;

// Middleware to parse JSON bodies
app.use(express.json());

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
  let text = req.body.body.text;
  let name = req.body.body.user;
  db.query("INSERT INTO chat_messages (text, user_id) VALUES (?, (SELECT user_id FROM `users` WHERE users.name = ?) );", [text, name], (err, results) => {
    if (err) {
      console.error('Error inserting message: ' + err);
      res.status(500).send('Error inserting message');
      return;
    }
    res.send("[{'Message added successfully'}]");
  });
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
