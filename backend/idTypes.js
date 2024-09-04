// idTypes.js

const mysql = require("mysql2");

// Create a connection to the database
const db = mysql.createConnection({
  host: "localhost", // Replace with your database host
  user: "root", // Replace with your database username
  password: "root", // Replace with your database password
  database: "studentcontrol", // The database name you created
});

// Function to fetch the ID types
function getIDTypes(callback) {
  const query = "SELECT sysdes1 FROM sysmast WHERE syscomsno=1 AND sysrtp=4";

  db.query(query, (err, results) => {
    if (err) {
      console.error("Error fetching ID types:", err);
      callback(err, null);
      return;
    }
    const idTypes = results.map((row) => row.sysdes1);
    callback(null, idTypes);
  });
}

// Function to fetch syssno for a given ID type
function getIDTypeSyssno(idType, callback) {
  const query = `SELECT syssno FROM sysmast WHERE syscomsno=1 AND sysrtp=4 AND sysdes1 = ?`;
  db.query(query, [idType], (err, results) => {
    if (err) {
      console.error("Error fetching syssno:", err);
      callback(err, null);
      return;
    }

    if (results.length > 0) {
      callback(null, results[0].syssno);
    } else {
      callback(null, null); // Title not found
    }
  });
}


// Function to fetch title for a given syssno
function getIDTypeBySyssno(syssno, callback) {
  const query = "SELECT sysdes1 FROM sysmast WHERE syssno = ?";
  db.query(query, [syssno], (err, results) => {
    if (err) {
      return callback(err, null);
    }
    if (results.length > 0) {
      return callback(null, results[0].sysdes1); // Return the ID type
    } else {
      return callback(null, null); // No ID type found
    }
  });
}

module.exports = {
  getIDTypes,
  getIDTypeSyssno,
  getIDTypeBySyssno
};
