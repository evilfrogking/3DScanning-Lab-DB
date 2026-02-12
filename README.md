# 3DScanning-Lab-DB
> CS 340: Databases

# 3D Artifacts Database
## Overview
Nyers [1] of OSU's 3D scanning lab uses an artifact collection of around 500 items, mostly from the anthropology department, and others from various university departments, for student use. However, he is interested in creating a catalogue of 3D-scanned artifacts for interested departments, enabling simultaneous sharing of the 3D scans and potentially quadrupling the number of scanned artifacts. The interested parties of other departments are known as “points of contact,” and the 3D scanning lab has its own point of contact, Dr. Loren Davis. Depending on what the scans are used for, artifacts can be scanned with or without texture (aka color); that is, one artifact can be scanned multiple times to produce multiple 3D scans. A database website allows 3D scanning technicians to track artifacts, 3D scans, and points of contact for interested departments, along with related data.

## Database Outline
### Artifacts
Records details of the physical objects that are 3D-scanned, including all potentially relevant research information [2].  
<br>**Attributes**  
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
<br>**Relationship(s)**
- A 1:M relationship between Artifacts and 3DScans is implemented with artifactID as a FK in 3DScans. All 3D scans must correspond to their original artifacts, while artifacts do not need 3D scans to be catalogued.
- A 1:M relationship between PointsOfContact and Artifacts is implemented with pocID as a FK in artifacts. All artifacts need to be catalogued with a point of contact, but points of contact do not need artifacts to be included in the database.

### 3DScans
Records the details of the 3D scans, including all potentially relevant research information [2].
<br>**Attributes**
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
<br>**Relationship(s)**
- A 1:M relationship between Artifacts and 3DScans is implemented with artifactID as a FK in 3D Scans. All 3D scans must correspond to their original artifacts, while artifacts do not need 3D scans to be catalogued.
- A 1:M relationship between Technicians and 3DScans is implemented with techID as a FK in 3DScans. A technician can perform several 3D scans, but an artifact is scanned 3D by only one technician, who can create several 3D scans of that one artifact.
- PointsOfContact has two relationships with 3DScans: 1:M, represented by labPOCID, and M:N, represented by the ScanPOCs intersection table [3].  
The 3d scanning lab has its own point of contact, Dr. Loren Davis, so all questions regarding the 3D scans are forwarded to him, rather than to individual technicians, who are often students. The lab's point of contact is referenced as the lapPOCID attribute.  
Additionally, external points of contact can request 3D scans, and those requests are visualized by the ScanPOCs intersection table.

### Technicians
Records the details of the technicians providing the 3D scans.
<br>**Attributes**
1. techID: INT, AUTO_INCREMENT, UNIQUE, not NULL, PK
2. techFName: VARCHAR(26), not NULL
3. techLName: VARCHAR(26), not NULL
4. techEmail: VARCHAR(51), not NULL
5. techPhone: VARCHAR(26), not NULL
<br>**Relationship(s)**
- A 1:M relationship between Technicians and 3DScans is implemented with techID as a FK in 3DScans. All 3D scans need to be connected to the technician who created them, but technicians can be included in the database before they create their first 3D scan.

### PointsOfContact
Records details of the individual curators receiving or curating the 3D scans.
<br>**Attributes**
1. pocID: INT, AUTO_INCREMENT, UNIQUE, not NULL, PK
2. active: BOOLEAN, not NULL DEFAULT TRUE
3. pocFName: VARCHAR(26), not NULL
4. pocLName: VARCHAR(26), not NULL
5. pocEmail: VARCHAR(51), not NULL
6. pocPhone: VARCHAR(26), not NULL
7. pocInstitution: VARCHAR(101), not NULL
<br>**Relationship(s)**
- A 1:M relationship between PointsOfContact and Artifacts is implemented with pocID as a FK in Artifacts. All artifacts need to be catalogued with a point of contact, but points of contact can be included in the database without being associated with an artifact.
PointsOfContact has two relationships with 3DScans: 1:M, represented by labPOCID, and M:N, represented by the ScanPOCs intersection table [3]. 
The 3d scanning lab has its own point of contact, Dr. Loren Davis, so all questions regarding the 3D scans are forwarded to him, rather than to individual technicians, who are often students. The lab's point of contact is referenced as the lapPOCID attribute.  
Additionally, external points of contact can request 3D scans, and those requests are visualized by the ScanPOCs intersection table.

### ScanPOCs
The intersection table between PointsOfContact and 3DScans to highlight the M:M relationship between them. Specifically regarding the points of contact after the lab point of contact involving the 3d scans.
<br>**Attributes**
1. scanPOCID: INT, AUTO_INCREMENT, UNIQUE, not NULL, PK
2. pocID: INT, not NULL, FK
3. scanID: INT, not NULL, FK
<br>**Relationship(s)**
- A 1:M relationship between ScansPointsOfContact and 3DScans is implemented with scanID as a FK in ScansPointsOfContact. This intersection table will match scan IDs to point-of-contact IDs, so it needs each ID as a foreign key.
- A 1:M relationship between ScansPointsOfContact and PointsOfContact is implemented with pocID as a FK in ScansPointsOfContact. This intersection table will match scan IDs to point-of-contact IDs, so it needs each ID as a foreign key.
