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

// Schema creation function
function createSchema() {
  const query = `
    CREATE TABLE IF NOT EXISTS s_stumast (
      stusno INT(8) NOT NULL AUTO_INCREMENT COMMENT 'Serial No',
      stucomsno INT(8) NOT NULL COMMENT 'Company',
      stunam VARCHAR(60) NOT NULL COMMENT 'Student Name',
      stuttlsno INT(8) NOT NULL COMMENT 'Title',
      stumof VARCHAR(1) NOT NULL COMMENT 'Gender',
      studob DATE NOT NULL COMMENT 'Date of Birth',
      stuidtsno INT(8) NOT NULL COMMENT 'ID Type',
      stuidno VARCHAR(12) NOT NULL COMMENT 'ID No',
      stuact VARCHAR(1) NOT NULL COMMENT 'Active [ Y|N ]',
      stuad1 VARCHAR(40) NOT NULL COMMENT 'Address 1',
      stuad2 VARCHAR(40) NOT NULL COMMENT 'Address 2',
      stuad3 VARCHAR(40) NOT NULL COMMENT 'Address 3',
      stutel VARCHAR(25) NOT NULL COMMENT 'Telephone',
      stumob VARCHAR(25) NOT NULL COMMENT 'Mobile No',
      stufax VARCHAR(25) NOT NULL COMMENT 'Fax No',
      stuemail VARCHAR(40) NOT NULL COMMENT 'E-Mail',
      stuucdnew VARCHAR(10) NOT NULL COMMENT 'Inserted User',
      stuentddt DATE NOT NULL COMMENT 'Inserted Date',
      stuenttime TIME NOT NULL COMMENT 'Inserted Time',
      stuucdame VARCHAR(10) NOT NULL COMMENT 'Updated User',
      stuameddt DATE NOT NULL COMMENT 'Updated Date',
      stuametime TIME NOT NULL COMMENT 'Updated Time',
      sturegddt DATE NOT NULL COMMENT 'Registered Date',
      PRIMARY KEY (stucomsno, stunam),
      UNIQUE KEY stusno (stusno),
      KEY stunam (stunam),
      KEY stuttlsno (stuttlsno),
      KEY stuidtsno (stuidtsno),
      KEY sturegddt (sturegddt),
      KEY stuidno (stuidno),
      KEY stuact (stuact)
    ) COMMENT='Students';
  `;
  db.query(query, (err) => {
    if (err) {
      console.error("Error creating table:", err);
    } else {
      console.log("Table created or already exists");
    }
  });
}

// Function to insert student data
function insertStudent(data, callback) {
  const {
    stucomsno,
    stunam,
    stuttlsno, // This is now directly passed from the frontend
    stumof,
    studob,
    stuidtsno, // This is now directly passed from the frontend
    stuidno,
    stuact,
    stuad1,
    stuad2,
    stuad3,
    stutel,
    stumob,
    stufax,
    stuemail,
    stuucdnew,
    stuentddt,
    stuenttime,
    stuucdame,
    stuameddt,
    stuametime,
    sturegddt,
  } = data;

  const query = `
    INSERT INTO s_stumast (
      stucomsno, stunam, stuttlsno, stumof, studob, stuidtsno, stuidno, stuact, stuad1, stuad2, stuad3, stutel, stumob, stufax, stuemail, stuucdnew, stuentddt, stuenttime, stuucdame, stuameddt, stuametime, sturegddt
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;

  db.query(
    query,
    [
      stucomsno,
      stunam,
      stuttlsno,
      stumof,
      studob,
      stuidtsno,
      stuidno,
      stuact,
      stuad1,
      stuad2,
      stuad3,
      stutel,
      stumob,
      stufax,
      stuemail,
      stuucdnew,
      stuentddt,
      stuenttime,
      stuucdame,
      stuameddt,
      stuametime,
      sturegddt,
    ],
    (err, results) => {
      if (err) {
        console.error("Error inserting data:", err);
        callback(err, null);
        return;
      }
      callback(null, results);
    }
  );
}

module.exports = {
  createSchema,
  insertStudent,
};
