const mysql = require('mysql');
const WebSocket = require('ws');
const crypto = require('crypto');
const port = 8080;

// Set up database connection (XAMPP)
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

function messagePackGen(messages, path, author) {
  return '{ "messages": ' + JSON.stringify(messages) + ', "path": ' + JSON.stringify(path) + ', "messageAuthor": '+ JSON.stringify(author) +' }'
}

const wss = new WebSocket.Server({ port: port });
function broadcastMessage(message) {
  wss.clients.forEach(function each(client) {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
    }
  });
}
wss.on('connection', function connection(ws) {
  console.log('Client connected');
  ws.on('message', function incoming(messagePack) {
    console.log('Received message from client: %s', messagePack);
    messagePack = JSON.parse(messagePack);
    let messages = messagePack.messages; let message;

    switch (messagePack.path) {
      case '/getMessages':
        message = messages[0];
        console.log(message.text, messagePack.messageAuthor);
        db.query('SELECT chat_messages.text, users.name FROM users RIGHT JOIN chat_messages ON users.user_id = chat_messages.user_id WHERE 1;', (err, results) => {
          if (err) throw err;
          ws.send(messagePackGen(results, messagePack.path, messagePack.messageAuthor));
        });
        break;
      case '/addMessage':
        message = messages[0];
        textValue = message.text.value;
        sessionID = message.text.sessionID;
        console.log(textValue, messagePack.messageAuthor);
        db.query("INSERT INTO chat_messages (text, user_id) VALUES (?, (SELECT user_id FROM `users` WHERE users.name = ? AND users.session_id = ?) );", [textValue, messagePack.messageAuthor, sessionID], (err, results) => {
          if (err) {
            console.error('Error inserting message: ' + err); return;
          }
          broadcastMessage(messagePackGen([{ "text": textValue }], messagePack.path, messagePack.messageAuthor));
          console.log('Message added successfully');
        });
        break;
      case '/register':
        message = messages[0];
        console.log(message.username, message.password, message.email);
        const server_salt = crypto.randomBytes(16).toString('hex'); console.log(server_salt);
        const serverHashedPassword = crypto.createHash('sha256').update(server_salt + message.password).digest('hex');
        // generate random hex string
        let sessionID = crypto.randomBytes(16).toString('hex');
        db.query("INSERT INTO `users`(`name`, `password`, `email`, `client_salt`, `server_salt`, `session_id`) VALUES (?, ?, ?, ?, ?, ?);", 
          [message.username, serverHashedPassword, message.email, message.client_salt, server_salt, sessionID], (err, results) => {
          if (err) {
            console.error('Error inserting message: ' + err);
            return;
          }
          console.log('User registered successfully');
        });
        break;
      case '/askSalt':
        message = messages[0];
        // let username = message.text;
        console.log(message.text);
        db.query("SELECT `users`.`client_salt` FROM `users` WHERE `users`.`name`=?;", [message.text], (err, results) => {
          if (err) {
            console.error('Error inserting message: ' + err);
            return;
          }
          console.log('Salt asked successfully');
          ws.send(messagePackGen(results, messagePack.path, messagePack.messageAuthor));
        });
        break;
      case '/login':
        message = JSON.parse(messages[0]["text"]);
        db.query("SELECT `users`.`server_salt` FROM `users` WHERE `users`.`name`=?", 
        [message.username], (err, results) => {
        if (err) { console.error('Error getting server_salt: ' + err); return; }
        console.log('Got server salt successfully', results);
        let serverHashedPassword = crypto.createHash('sha256').update(results[0]['server_salt'] + message.password).digest('hex');
        console.log(serverHashedPassword);
        
        db.query("SELECT COUNT(`user_id`) as count, `users`.`session_id`  FROM `users` WHERE `users`.`name`=? AND `users`.`password`=?;", 
        [message.username, serverHashedPassword], (err, results) => {
        if (err) { console.error('Error logging in user: ' + err); return; }
        console.log('User logged in tried successfully');
        ws.send(messagePackGen(results, messagePack.path, messagePack.messageAuthor));
        });
        });
        break;
      default:
        break;
    }
  });
  ws.on('close', function close() {
    console.log('Client disconnected');
  });
});

