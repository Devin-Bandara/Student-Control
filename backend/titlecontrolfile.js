// titlecontrolfile.js

const mysql = require("mysql2");

// Create a connection to the database
const db = mysql.createConnection({
  host: "localhost", // Replace with your database host
  user: "root", // Replace with your database username
  password: "root", // Replace with your database password
  database: "studentcontrol", // The database name you created
});

// Connect to the database
db.connect((err) => {
  if (err) {
    console.error("Error connecting to the database:", err);
    return;
  }
  console.log("Connected to the database");
});

// Function to fetch titles
function getTitles(callback) {
  const query = `SELECT sysdes2 FROM sysmast WHERE syscomsno=1 AND sysrtp=3`;

  db.query(query, (err, results) => {
    if (err) {
      console.error("Error fetching titles:", err);
      callback(err, null);
      return;
    }
    const titles = results.map((row) => row.sysdes2);
    callback(null, titles);
  });
}

// Function to fetch syssno for a given title
function getTitleSyssno(title, callback) {
  const query = `SELECT syssno FROM sysmast WHERE syscomsno=1 AND sysrtp=3 AND sysdes2 = ?`;
  console.log("Querying syssno for title:", title); // Log the title passed
  db.query(query, [title], (err, results) => {
    if (err) {
      console.error("Error fetching syssno:", err);
      callback(err, null);
      return;
    }
    console.log("Query results:", results); // Log the query results

    if (results.length > 0) {
      callback(null, results[0].syssno);
    } else {
      callback(null, null); // Title not found
    }
  });
}


// Function to fetch title for a given syssno
function getTitleBySyssno(syssno, callback) {
  const query = "SELECT sysdes2 FROM sysmast WHERE syssno = ?";
  db.query(query, [syssno], (err, results) => {
    if (err) {
      return callback(err, null);
    }
    if (results.length > 0) {
      return callback(null, results[0].sysdes2); // Return the title
    } else {
      return callback(null, null); // No title found
    }
  });
}

module.exports = {
  getTitles,
  getTitleSyssno,
  getTitleBySyssno,
};
