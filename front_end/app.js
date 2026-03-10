// Authors: Aspen Frazee and Alex Hinson
// File name: app.js
// Templates used: Yes, the template provided in "Web Application Technology" was used and followed for the app.get process
// https://canvas.oregonstate.edu/courses/2031764/pages/exploration-web-application-technology-2?module_item_id=26243419
// Additionally, the template in "Implementing CUD operations in your app" was used and followed for the app.post process
// https://canvas.oregonstate.edu/courses/2031764/pages/exploration-implementing-cud-operations-in-your-app?module_item_id=26243436
// AI used: N/A
// Express
const express = require('express');
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// Switch between ports for testing
const ASPEN_PORT = 3825;
const PORT = ASPEN_PORT;
// const ALEX_PORT = 8872;
// const PORT = ALEX_PORT;

// Database
const db = require('./database/db-connector');

// Handlebars
const { engine } = require('express-handlebars'); // Import express-handlebars engine
app.engine('.hbs', engine({ extname: '.hbs' })); // Create instance of handlebars
app.set('view engine', '.hbs'); // Use handlebars engine for *.hbs files.

// ########################################
// ########## ROUTE HANDLERS

// READ ROUTES
app.get('/', async function (req, res) {
    try {
        res.render('home'); // Render the home.hbs file
    } catch (error) {
        console.error('Error rendering page:', error);
        // Send a generic error message to the browser
        res.status(500).send('An error occurred while rendering the page.');
    }
});

app.get('/3DScans', async function (req, res) {
    try {
        const query1 = `SELECT 3DScans.scanID AS 'ID', 3DScans.scanDate AS 'Scan Date', 3DScans.fileName AS 'File Name', \
            Artifacts.artifactID AS 'Artifact ID', Technicians.techEmail AS 'Technician Contact', \
            PointsOfContact.pocEmail AS 'Lab Contact', 3DScans.units AS 'Units', 3DScans.scanMethod AS 'Scan Method', \
            3DScans.derived FROM 3DScans \
            LEFT JOIN Artifacts ON 3DScans.artifactID = Artifacts.artifactID \
            LEFT JOIN Technicians ON 3DScans.techID = Technicians.techID \
            LEFT JOIN PointsOfContact ON 3DScans.labPOCID = PointsOfContact.pocID;`;
        const query2 = 'SELECT * FROM Technicians;';
        const query3 = 'SELECT * FROM PointsOfContact;';
        const query4 = 'SELECT * FROM Artifacts;';
        const [scans] = await db.query(query1);
        const [techs] = await db.query(query2);
        const [pocs] = await db.query(query3);
        const [artifacts] = await db.query(query4);

        res.render('3DScans', { scans: scans, techs: techs, pocs: pocs, artifacts: artifacts });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

// Creates the functionality for the Artifacts page
app.get('/Artifacts', async function (req, res) {
    try {
        // Create and execute our queries
        const query1 = `SELECT Artifacts.artifactID AS 'ID', PointsOfContact.pocEmail AS 'Contact Email', Artifacts.onSite AS 'On Site', \
            Artifacts.institutionalID AS 'Institutional ID', Artifacts.location AS 'Location', \
            Artifacts.ipHolder AS 'IP Holder', Artifacts.license AS 'License', Artifacts.classification AS 'Classification', \
            Artifacts.cultural AS 'Cultural', Artifacts.archaeology AS 'Archaeological' FROM Artifacts \
            LEFT JOIN PointsOfContact ON Artifacts.pocID = PointsOfContact.pocID;`;
        const query2 = 'SELECT * FROM PointsOfContact;';
        
        const [artifacts] = await db.query(query1);
        const [pocs] = await db.query(query2);

        // Render the Artifacts.hbs file, and also send the renderer
        //  an object that contains our POC information
        res.render('Artifacts', { artifacts: artifacts, pocs: pocs });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

// Creates the functionality for the Technicians page
app.get('/Technicians', async function (req, res) {
    try {
        // Create and execute our queries
        const query1 = `SELECT techID AS 'ID', CONCAT(techFName, ' ', techLName) AS 'Technician Name', \
        techEmail AS 'Email', techPhone AS 'Phone Number' FROM Technicians;`;
        const [technicians] = await db.query(query1);

        res.render('Technicians', { technicians: technicians });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

// PointsOfContact page functionality
app.get('/PointsOfContact', async function (req, res) {
    try {
        const query1 = `SELECT pocID AS 'ID', CONCAT(pocFName, ' ', pocLName) as 'Contact Name', pocEmail as 'Email', pocPhone as 'Phone Number', \
        pocInstitution as 'Institution', active FROM PointsOfContact;`;
        const [contacts] = await db.query(query1);
        res.render('PointsOfContact', { contacts: contacts });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/ScanPOCs', async function (req, res) {
    try {
        const query1 = `SELECT ScanPOCs.scanPOCID AS 'ID', 3DScans.fileName AS 'File', \
            PointsOfContact.pocEmail AS 'Contact' FROM ScanPOCs \
            LEFT JOIN 3DScans ON ScanPOCs.scanID = 3DScans.scanID \
            LEFT JOIN PointsOfContact ON ScanPOCs.pocID = PointsOfContact.pocID;`;
        const query2 = 'SELECT * FROM 3DScans;';
        const query3 = 'SELECT * FROM PointsOfContact;';
        const [scancontacts] = await db.query(query1);
        const [scans] = await db.query(query2);
        const [pocs] = await db.query(query3);
        res.render('ScanPOCs', { scancontacts: scancontacts, scans: scans, pocs: pocs });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.post('/Reset', async function (req, res) {
  try {
    await db.query('CALL sp_RestartDatabase()');
    return res.redirect(303, '/');  // ← end the request, force a GET
  } catch (error) {
    console.error('Error executing queries:', error);
    return res.status(500).send('An error occurred while resetting the database.');
  }
});


// Citation for use of AI Tools:
// Date: 03/02/2026
// Prompts used to generate PL/SQL
// Edit my delete function to work with my stored procedure sp_delete_scanPOC.
// into the following schema [movies db schema here] and returns the id of the newly inserted title. 
// Write a test to verify the SP by inserting the title for the 2001 comedy movie Shrek.
// AI Source URL: https://copilot.microsoft.com/

app.post('/DeleteScanPOC', async function (req, res) {
  try {
    const scanPOCID = req.body.scanPOCID;

    // Call the stored procedure (only one IN param)
    const [resultSets] = await db.query('CALL sp_delete_scanPOC(?);', [scanPOCID]);

    // mysql2 returns an array of result sets for CALL.
    // Your proc does one SELECT at the end, so the message will be in resultSets[0][0].result_message
    let msg = 'Error! Scan\'dout still in!';
    if (Array.isArray(resultSets) && resultSets.length > 0 && resultSets[0]?.[0]?.result_message) {
      msg = resultSets[0][0].result_message;
    }

    console.log('DeleteScanPOC:', msg);

    // Option 1: redirect back to the list and optionally flash a message
    res.redirect('/ScanPOCs');

    // Option 2: if you want to show message inline without redirect, you could:
    // res.status(200).send(msg);
  } catch (error) {
    console.error('Error executing queries:', error);
    res.status(500).send('An error occured while executing the database queries.');
  }
});

// This functionality was provided as a template in the
// "Implementing CUD operations in your app" exploration
// CREATE ROUTES
app.post('/CreateScanPOC', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;

        // Create and execute our queries
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_create_scanPOC(?, ?, @new_id);`;

        // Store ID of last inserted row
        const [[[rows]]] = await db.query(query1, [
            data.create_scanpoc_3DScan,
            data.create_scanpoc_POC]);

        console.log(`CREATE Scan'dout. ID: ${rows.new_id} ` +
            `Details: Contact:${data.create_scanpoc_POC} Scan:${data.create_scanpoc_3DScan}`
        );

        // Redirect the user to the updated webpage
        res.redirect('/ScanPOCs');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

// Citation for use of AI Tools:
// Date: 03/09/2026
// Prompts used to generate PL/SQL
// Troubleshoot why my update function isn't working with my stored procedure sp_update_scanPOC. 
// The SP takes in the following parameters: scanPOCID, scanID, pocID. 
// The SP updates the ScanPOCs table with the provided scanID and 
// pocID where the scanPOCID matches the provided scanPOCID.
// Copilot wrote input validation as well.
// AI Source URL: https://copilot.microsoft.com/
// Citation for use of AI Tools:
// Date: 03/09/2026
// Prompts used to generate PL/SQL
// Troubleshoot why my update function isn't working with my stored procedure sp_update_scanPOC. 
// The SP takes in the following parameters: scanPOCID, scanID, pocID. 
// The SP updates the ScanPOCs table with the provided scanID and 
// pocID where the scanPOCID matches the provided scanPOCID. 
// AI Source URL: https://copilot.microsoft.com/
app.post('/UpdateScanPOC', async (req, res) => {
  try {
        const scanPOCID = req.body.update_scanPOC_id;
        const scanID    = req.body.update_scan_ID;
        const pocID     = req.body.update_poc_ID;

        const query1 = 'CALL sp_update_scanPOC(?, ?, ?);';

        const [resultSets] = await db.query('CALL sp_update_scanPOC(?, ?, ?);', 
            [scanPOCID, scanID, pocID]);

        res.redirect('/ScanPOCs');
  } catch (err) {
    console.error('Error executing queries:', err);
    console.log('POST /UpdateScanPOC body:', req.body);
    res.status(500).send('An error occurred while executing the database queries.');
  }
});


// ########################################
// ########## LISTENER

app.listen(PORT, function () {
    console.log(
        'Express started on http://localhost:' +
            PORT +
            '; press Ctrl-C to terminate.'
    );
});
