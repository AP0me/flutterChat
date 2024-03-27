const mysql = require('mysql');
const WebSocket = require('ws');
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

function messagePackGen(messages, path){
  return '{ "messages": '+JSON.stringify(messages)+', "path": '+JSON.stringify(path)+' }'
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
        console.log(message.text, message.name);
        db.query('SELECT chat_messages.text, users.name FROM users RIGHT JOIN chat_messages ON users.user_id = chat_messages.user_id WHERE 1;', (err, results) => {
          if (err) throw err;
          ws.send(messagePackGen(results, messagePack.path));
        });
        break;
      case '/addMessage':
        message = messages[0];
        console.log(message.text, message.name);
        db.query("INSERT INTO chat_messages (text, user_id) VALUES (?, (SELECT user_id FROM `users` WHERE users.name = ?) );", [message.text, message.name], (err, results) => {
          if (err) {
            console.error('Error inserting message: ' + err);
            return;
          }
          broadcastMessage(messagePackGen([{"text": message.text, "name": message.name}], messagePack.path));
          console.log('Message added successfully');
        });
      default:
        break;
    }
  });
  ws.on('close', function close() {
    console.log('Client disconnected');
  });
});

