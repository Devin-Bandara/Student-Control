//app.js

const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors"); // Import cors
const { createSchema, insertStudent } = require("./studentcontrolfile"); // Import functions
const {
  getTitles,
  getTitleSyssno,
  getTitleBySyssno,
} = require("./titlecontrolfile"); // Import getTitles function
const { getIDTypes, getIDTypeSyssno, getIDTypeBySyssno } = require("./idTypes"); // Import getIDTypes and getIDTypesSyssno function

const app = express();
const port = 3000;

app.use(cors());

// Middleware to parse JSON bodies
app.use(bodyParser.json());

// Setup your database connection (This can be removed if you're using the same connection in titlecontrolfile.js)
const mysql = require("mysql2");
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "root",
  database: "StudentControl",
});

db.connect((err) => {
  if (err) {
    console.error("Error connecting to the database:", err.stack);
    return;
  }
  console.log("Connected to the database");
});
// Create schema if not exists
createSchema(); // Ensure schema is created

// Route to handle title lookup
app.post("/get-syssno", (req, res) => {
  const { title } = req.body;

  getTitleSyssno(title, (err, syssno) => {
    if (err) {
      res.status(500).send("Error fetching syssno to get title");
      return;
    }

    if (syssno) {
      res.json({ syssno });
    } else {
      res.status(404).send("Title not found");
    }
  });
});

// API endpoint to fetch titles
app.get("/titles", (req, res) => {
  getTitles((err, titles) => {
    if (err) {
      res.status(500).send("Error fetching titles");
      return;
    }
    res.json(titles);
  });
});

// API endpoint to fetch IDs
app.get("/ids", (req, res) => {
  getIDTypes((err, idTypes) => {
    if (err) {
      res.status(500).send("Error fetching ID types");
      return;
    }
    res.json(idTypes);
  });
});

// Route to handle to get syssno to ID
app.post("/getIDsyssno", (req, res) => {
  const { idtype } = req.body;

  getIDTypeSyssno(idtype, (err, syssno) => {
    if (err) {
      res.status(500).send("Error fetching syssno to ID");
      return;
    }

    if (syssno) {
      res.json({ syssno });
    } else {
      res.status(404).send("Idtype not found");
    }
  });
});

// Route to handle POST requests from the Flutter app
app.post("/student", (req, res) => {
  const studentData = req.body;

  // Insert data into the database using function from studentcontrolfile.js
  insertStudent(studentData, (err, results) => {
    if (err) {
      res.status(500).send("Error inserting data");
      return;
    }
    res.status(201).send("Data inserted successfully");
  });
});

// API endpoint to fetch all student names
app.get("/students", (req, res) => {
  const query = "SELECT stunam FROM s_stumast"; // Query to fetch all student names

  db.query(query, (err, results) => {
    if (err) {
      res.status(500).send("Error fetching student names");
      return;
    }
    res.json(results);
  });
});

// API endpoint to fetch the studentID of a student name
app.get("/studentID", (req, res) => {
  const studentName = req.query.name; // Get the name from the query parameter

  if (!studentName) {
    return res.status(400).send("Student name query parameter is required");
  }
  const query = "SELECT stusno FROM s_stumast WHERE stunam = ?"; // Query to fetch the student ID of a student name

  db.query(query,[studentName], (err, results) => {
    if (err) {
      console.error("Error fetching student ID:", err);
      res.status(500).send("Error fetching student ID");
      return;
    }
    if (results.length === 0) {
      return res.status(404).send("Student not found");
    }
    res.json({ studentID: results[0].stusno  });
  });
});

app.get("/studentdetails", (req, res) => {
  const studentName = req.query.name; // Get the name from the query parameter
  const query = "SELECT * FROM s_stumast WHERE stunam = ?"; // Query to fetch the student details by name

  db.query(query, [studentName], (err, results) => {
    if (err) {
      res.status(500).send("Error fetching student details");
      return;
    }
    if (results.length > 0) {
      const studentDetails = results[0]; // Define the studentDetails object
      const stuttlsno = studentDetails.stuttlsno;
      const stuidtsno = studentDetails.stuidtsno;

      // Fetch the title based on syssno
      getTitleBySyssno(stuttlsno, (err, title) => {
        if (err) {
          res.status(500).send("Error fetching title");
          return;
        }
        if (title) {
          studentDetails.title = title; // Replace stuttlsno with the title
          delete studentDetails.stuttlsno; // Remove the stuttlsno field
        } else {
          studentDetails.title = "Unknown"; // Handle case where title is not found
        }
      });

      // Fetch the ID type based on syssno
      getIDTypeBySyssno(stuidtsno, (err, idType) => {
        if (err) {
          res.status(500).send("Error fetching id type");
          return;
        }
        if (idType) {
          studentDetails.idType = idType; // Replace stuidtsno with the ID
          delete studentDetails.stuidtsno; // Remove the stuttlsno field
        } else {
          studentDetails.id = "Unknown"; // Handle case where id is not found
        }

        res.json(studentDetails); // Send the updated student details with the title
      });
    } else {
      res.status(404).send("Student not found");
    }
  });
});

// PATCH route to update student information
app.patch("/student/update/:stusno", (req, res) => {
  const {
    stunam,
    title,
    stumof,
    studob,
    idType,
    stuidno,
    stuact,
    stuad1,
    stuad2,
    stuad3,
    stutel,
    stumob,
    stufax,
    stuemail,
  } = req.body;

  const { stusno } = req.params;

  console.log("Updating student with ID:", stusno);
  console.log("Received request payload:", req.body);

  // Fetch current student details
  db.query("SELECT * FROM s_stumast WHERE stusno = ?", [stusno], (err, results) => {
    if (err) {
      console.error("Error fetching current student details:", err);
      return res.status(500).send("Error fetching current student details");
    }

    if (results.length === 0) {
      return res.status(404).send("Student not found");
    }

    const currentDetails = results[0];

    // Helper function to format date to 'YYYY-MM-DD' for DATE columns
    function formatDate(date) {
      if (!date) return null;
      const d = new Date(date);
      if (isNaN(d.getTime())) return null;
      return d.toISOString().split('T')[0]; // 'YYYY-MM-DD'
    }

    // Fetch syssnos if needed
    function fetchSyssno(value, fetchFunc, currentField) {
      if (!value) return Promise.resolve(currentField);
      return new Promise((resolve, reject) => {
        fetchFunc(value, (err, syssno) => {
          if (err) return reject(err);
          resolve(syssno);
        });
      });
    }

    Promise.all([
      fetchSyssno(title, getTitleSyssno, currentDetails.stuttlsno),
      fetchSyssno(idType, getIDTypeSyssno, currentDetails.stuidtsno)
    ])
    .then(([newStuttlsno, newStuidtsno]) => {
      const updateQuery = `
        UPDATE s_stumast 
        SET 
          stunam= COALESCE(?, stunam),
          stuttlsno = COALESCE(?, stuttlsno),
          stumof = COALESCE(?, stumof),
          studob = COALESCE(?, studob),
          stuidtsno = COALESCE(?, stuidtsno),
          stuidno = COALESCE(?, stuidno),
          stuact = COALESCE(?, stuact),
          stuad1 = COALESCE(?, stuad1),
          stuad2 = COALESCE(?, stuad2),
          stuad3 = COALESCE(?, stuad3),
          stutel = COALESCE(?, stutel),
          stumob = COALESCE(?, stumob),
          stufax = COALESCE(?, stufax),
          stuemail = COALESCE(?, stuemail),
          stuameddt = CURDATE(),
          stuametime = CURTIME()
        WHERE stusno = ?
      `;

      const values = [
        stunam||currentDetails.stunam,
        newStuttlsno,
        stumof || currentDetails.stumof,
        formatDate(studob) || currentDetails.studob,
        newStuidtsno,
        stuidno || currentDetails.stuidno,
        stuact || currentDetails.stuact,
        stuad1 || currentDetails.stuad1,
        stuad2 || currentDetails.stuad2,
        stuad3 || currentDetails.stuad3,
        stutel || currentDetails.stutel,
        stumob || currentDetails.stumob,
        stufax || currentDetails.stufax,
        stuemail || currentDetails.stuemail,
        stusno
      ];

      db.query(updateQuery, values, (err, results) => {
        if (err) {
          console.error("Error executing update query:", err);
          return res.status(500).send("Error updating student details");
        }

        if (results.affectedRows > 0) {
          res.status(200).send("Student details updated successfully");
        } else {
          res.status(404).send("Student not found");
        }
      });
    })
    .catch((err) => {
      console.error("Error fetching syssnos:", err);
      res.status(500).send("Error fetching syssnos");
    });
  });
});



app.get("/studentdetailsbyID", (req, res) => {
  const studentID = req.query.id; // Get the ID from the query parameter
  console.log("Received request for student ID:", studentID);

  const query = "SELECT * FROM s_stumast WHERE stusno = ?"; // Query to fetch the student details by ID

  db.query(query, [studentID], (err, results) => {
    if (err) {
      console.error("Error fetching student details:", err);
      res.status(500).send("Error fetching student details");
      return;
    }
    if (results.length > 0) {
      const studentDetails = results[0]; // Define the studentDetails object
      const stuttlsno = studentDetails.stuttlsno;
      const stuidtsno = studentDetails.stuidtsno;

      // Fetch the title and ID type concurrently using Promises
      Promise.all([
        new Promise((resolve, reject) => {
          getTitleBySyssno(stuttlsno, (err, title) => {
            if (err) return reject(err);
            studentDetails.title = title || "Unknown";
            delete studentDetails.stuttlsno;
            resolve();
          });
        }),
        new Promise((resolve, reject) => {
          getIDTypeBySyssno(stuidtsno, (err, idType) => {
            if (err) return reject(err);
            studentDetails.idType = idType || "Unknown";
            delete studentDetails.stuidtsno;
            resolve();
          });
        })
      ])
      .then(() => {
        // Send the updated student details with the title and ID type
        res.json(studentDetails);
      })
      .catch((err) => {
        res.status(500).send("Error fetching title or ID type");
      });
    } else {
      res.status(404).send("Student not found");
    }
  });
});

// DELETE route to remove a student by ID
app.delete("/student/delete/:stusno", (req, res) => {
  const { stusno } = req.params;

  console.log("Deleting student with ID:", stusno);

  const deleteQuery = "DELETE FROM s_stumast WHERE stusno = ?";

  db.query(deleteQuery, [stusno], (err, results) => {
    if (err) {
      console.error("Error executing delete query:", err);
      return res.status(500).send("Error deleting student");
    }

    if (results.affectedRows > 0) {
      res.status(200).send("Student deleted successfully");
    } else {
      res.status(404).send("Student not found");
    }
  });
});

// Route to check if student exists
app.get('/student/check/:name', (req, res) => {
  const { name } = req.params;

  // Query to check if the student name exists in the database
  const query = 'SELECT COUNT(*) AS count FROM s_stumast WHERE stunam = ?';
  
  db.query(query, [name], (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      return res.status(500).send('Error checking student existence');
    }
    
    const studentExists = results[0].count > 0;
    if (studentExists) {
      res.status(200).send('Student exists');
    } else {
      res.status(404).send('Student not found');
    }
  });
});



app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
