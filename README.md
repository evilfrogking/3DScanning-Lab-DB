# 3DScanning-Lab-DB
> CS 340: Databases
---  
[Web interface](http://classwork.engr.oregonstate.edu:3825/)  
[Project GitHub](https://github.com/evilfrogking/3DScanning-Lab-DB/tree/main)
---  
# Tools used
**HTML, CSS, JavaScript, MySQL, Node**  
MariaDB MySQL was used for database development. MySQL Workbench, PHPAdmin, and Draw.io were used for ERDs, Schemas, and tables. Node was used to implement the web app.  

# 3D Artifacts Database
## Overview
OSU has recently established a 3D Scanning lab for archaeology students and is using a collection of five hundred artifacts to train students in 3D Scanning. Once trained, Nyers [1] will use the technicians to catalog artifacts for several departments, enabling 3D scans for Ecampus students, other departments, and eventually outside institutions, vastly increasing the scope of the project to several thousand artifacts, a dozen technicians, and dozens of points of contact. Points of contact represent both individuals who provide artifacts for scanning and maintain ownership of those items and representatives of institutions interested in using the available 3D scans produced by the lab. While the new lab is being built, the ability to scan additional items is halted. Thus, the database can connect preexisting points of contact to preexisting scans, or update an existing connection between a scan and a point of contact, but nothing else.

## Database Outline
### Artifacts
Records details of the physical objects that are 3D-scanned, including all potentially relevant research information [2].  
#### Attributes  
1. artifactID: INT, AUTO_INCREMENT, UNIQUE, not NULL, PK
2. pocID: INT, not NULL, FK
3. onSite: BOOLEAN, not NULL DEFAULT TRUE
4. institutionalD: VARCHAR(101)
5. location: VARCHAR(50), not NULL; where the artifact is being stored in the 3D scanning lab.
6. ipHolder: VARCHAR(50)
7. license: VARCHAR(50)
8. classification: VARCHAR(50), not NULL
9. cultural: BOOLEAN, not NULL DEFAULT FALSE
10. archaeology: BOOLEAN, not NULL DEFAULT FALSE

#### Relationship(s)  
- A 1:M relationship between Artifacts and 3DScans is implemented with artifactID as a FK in 3DScans. All 3D scans must correspond to their original artifacts, while artifacts do not need 3D scans to be catalogued.
- A 1:M relationship between PointsOfContact and Artifacts is implemented with pocID as a FK in artifacts. All artifacts need to be catalogued with a point of contact, but points of contact do not need artifacts to be included in the database.

### 3DScans
Records the details of the 3D scans, including all potentially relevant research information [2].
#### Attributes  
1. scanID: INT, AUTO_INCREMENT, UNIQUE, not NULL, PK
2. artifactID: INT, not NULL, FK
3. labPOCID: INT, not NULL, FK; the point of contact for the 3D scanning lab.
4. techID: INT, not NULL, FK
5. scanDate: DATE, not NULL
6. units: VARCHAR(10), not NULL; the default is mm
7. scanMethod: VARCHAR(50), not NULL
8. derived: BOOLEAN DEFAULT FALSE, not NULL; a yes-or-no variable.
9. fileName: VARCHAR(50), not NULL, UNIQUE
~~10. doi: VARCHAR(50)~~

#### Relationship(s)
- A 1:M relationship between Artifacts and 3DScans is implemented with artifactID as a FK in 3D Scans. All 3D scans must correspond to their original artifacts, while artifacts do not need 3D scans to be catalogued.
- A 1:M relationship between Technicians and 3DScans is implemented with techID as a FK in 3DScans. A technician can perform several 3D scans, but an artifact is scanned 3D by only one technician, who can create several 3D scans of that one artifact.
- PointsOfContact has two relationships with 3DScans: 1:M, represented by labPOCID, and M:N, represented by the ScanPOCs intersection table [3].  
The 3d scanning lab has its own point of contact, Dr. Loren Davis, so all questions regarding the 3D scans are forwarded to him, rather than to individual technicians, who are often students. The lab's point of contact is referenced as the lapPOCID attribute.  
Additionally, external points of contact can request 3D scans, and those requests are visualized by the ScanPOCs intersection table.

### Technicians
Records the details of the technicians providing the 3D scans.  
#### Attributes
1. techID: INT, AUTO_INCREMENT, UNIQUE, not NULL, PK
2. techFName: VARCHAR(26), not NULL
3. techLName: VARCHAR(26), not NULL
4. techEmail: VARCHAR(51), not NULL
5. techPhone: VARCHAR(26), not NULL
#### Relationship(s)
- A 1:M relationship between Technicians and 3DScans is implemented with techID as a FK in 3DScans. All 3D scans need to be connected to the technician who created them, but technicians can be included in the database before they create their first 3D scan.

### PointsOfContact
Records details of the individual curators receiving or curating the 3D scans.
#### Attributes
1. pocID: INT, AUTO_INCREMENT, UNIQUE, not NULL, PK
2. active: BOOLEAN, not NULL DEFAULT TRUE
3. pocFName: VARCHAR(26), not NULL
4. pocLName: VARCHAR(26), not NULL
5. pocEmail: VARCHAR(51), not NULL
6. pocPhone: VARCHAR(26), not NULL
7. pocInstitution: VARCHAR(101), not NULL  
#### Relationship(s)
- A 1:M relationship between PointsOfContact and Artifacts is implemented with pocID as a FK in Artifacts. All artifacts need to be catalogued with a point of contact, but points of contact can be included in the database without being associated with an artifact.
PointsOfContact has two relationships with 3DScans: 1:M, represented by labPOCID, and M:N, represented by the ScanPOCs intersection table [3]. 
The 3d scanning lab has its own point of contact, Dr. Loren Davis, so all questions regarding the 3D scans are forwarded to him, rather than to individual technicians, who are often students. The lab's point of contact is referenced as the lapPOCID attribute.  
Additionally, external points of contact can request 3D scans, and those requests are visualized by the ScanPOCs intersection table.

### ScanPOCs
The intersection table between PointsOfContact and 3DScans to highlight the M:M relationship between them. Specifically regarding the points of contact after the lab point of contact involving the 3d scans.  
#### Attributes
1. scanPOCID: INT, AUTO_INCREMENT, UNIQUE, not NULL, PK
2. pocID: INT, not NULL, FK
3. scanID: INT, not NULL, FK
#### Relationship(s)
- A 1:M relationship between ScansPointsOfContact and 3DScans is implemented with scanID as a FK in ScansPointsOfContact. This intersection table will match scan IDs to point-of-contact IDs, so it needs each ID as a foreign key.
- A 1:M relationship between ScansPointsOfContact and PointsOfContact is implemented with pocID as a FK in ScansPointsOfContact. This intersection table will match scan IDs to point-of-contact IDs, so it needs each ID as a foreign key.

# Citations
> The code was informed, styled after, or co-written by the following sources:
## Project design
[1]	A. Nyers, interview, Jan. 2026.
[2]	A. Nyers, (2026). Using Excel cells as attributes for artifacts and 3D scans.metadata [Excel spreadsheet]. Available: [Canvas](https://canvas.oregonstate.edu/courses/2055205/files/115980248?module_item_id=26476308)
## Code implementation
*File name: app.js*  
**From OSU's Professor Curry's CS340 2026 course**
- Week 6 Building Your Project UI
[Canvas](https://canvas.oregonstate.edu/courses/2031764/pages/exploration-web-application-technology-2?module_item_id=26243419)
- Week 8 - DB Performance and Query Optimization + Project Development
[Canvas](https://canvas.oregonstate.edu/courses/2031764/pages/exploration-implementing-cud-operations-in-your-app?module_item_id=26243436)
*Additional files*  
Copilot, GitHub Copilot, and ChatGPT were used for code implementation, design, troubleshooting, and improvement throughout this codebase, and AI use is clearly marked with citations.

# To-Do List
- [ ] Zip folder organization  
- [ ] Submit Project
## Aspen
- [x] PDF  
  - [x] Executive Summary  
  - [x] Project and Database Outlines  
  - [x] ER Diagram  
  - [x] Sample Data  
- [x] Code  
## Alex
- [x] UI Screen Shots with Informative Titles
- [x] Schema  
- [x] Data Definition Queries  
- [x] Data Manipulation Queries  
- [x] Procedure Language Queries  
- [x] Website Functionality  
- [x] Style
  - [x] Icon buttons
  - [x] Booleans as True/False
  - [x] Update form page
