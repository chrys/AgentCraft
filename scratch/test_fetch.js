const http = require('http');
const fs = require('fs');
const path = require('path');

const url = 'http://localhost:3000/api/skills?targetPath=/Users/chrys/Projects/YourPlanner&tool=github-copilot';

http.get(url, (res) => {
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  res.on('end', () => {
    const dest = path.join(__dirname, 'response.html');
    fs.writeFileSync(dest, data, 'utf8');
    console.log('Successfully saved response to ' + dest);
  });
}).on('error', (err) => {
  console.error('Error fetching URL:', err.message);
});
