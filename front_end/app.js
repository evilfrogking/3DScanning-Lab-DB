
// Express
const express = require('express');
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// Switch between ports for testing
// const ASPEN_PORT = 3825;
// const PORT = ASPEN_PORT;
const ALEX_PORT = 8872;
const PORT = ALEX_PORT;

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
        const query1 = `SELECT 3DScans.scanID, 3DScans.scanDate, 3DScans.fileName, \
            Artifacts.artifactID AS 'artifactID', Technicians.techEmail AS 'techID', \
            PointsOfContact.pocEmail AS 'labPOCID', 3DScans.units, 3DScans.scanMethod, \
            3DScans.derived FROM 3DScans \
            LEFT JOIN Artifacts ON 3DScans.artifactID = Artifacts.artifactID \
            LEFT JOIN Technicians ON 3DScans.techID = Technicians.techID \
            LEFT JOIN PointsOfContact ON 3DScans.labPOCID = PointsOfContact.pocID;`;
        const query2 = 'SELECT * FROM Technicians;';
        const query3 = 'SELECT * FROM PointsOfContact;';
        const query4 = 'SELECT * FROM Artifacts;';
        //const query2 = 'SELECT * FROM bsg_planets;';
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
        const query1 = `SELECT Artifacts.artifactID, Artifacts.pocID, Artifacts.onSite, Artifacts.institutionalID, Artifacts.location, \
            Artifacts.ipHolder, Artifacts.license, Artifacts.classification, Artifacts.cultural, Artifacts.archaeology FROM Artifacts \
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
        const query1 = `SELECT Technicians.techID, Technicians.techFName, Technicians.techLName, Technicians.techEmail, Technicians.techPhone FROM Technicians;`;
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

app.get('/PointsOfContact', async function (req, res) {
    try {
        const query1 = `SELECT pocID, pocFName, pocLName, pocEmail, pocPhone, \
        pocInstitution, active FROM PointsOfContact;`;
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
        const query1 = `SELECT ScanPOCs.scanPOCID, 3DScans.fileName AS 'scanID', \
            PointsOfContact.pocEmail AS 'pocID' FROM ScanPOCs \
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
// ########################################
// ########## LISTENER

app.listen(PORT, function () {
    console.log(
        'Express started on http://localhost:' +
            PORT +
            '; press Ctrl-C to terminate.'
    );
});
