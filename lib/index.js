const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');

const app = express();
app.use(cors());
app.use(express.json());

const serviceAccount = require('./path/to/your-service-account-file.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

app.get('/users', async (req, res) => {
  try {
    const listUsersResult = await admin.auth().listUsers(1000);
    res.send(listUsersResult.users);
  } catch (error) {
    console.log('Error listing users:', error);
    res.status(500).send('Error listing users');
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
