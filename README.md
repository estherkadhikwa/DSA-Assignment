# DSA Assignment 1

**Course Title:** Distributed Systems and Applications
**Course Code:** DSA612S 
**Assessment:** First Assignment 
**Released on:** 27/08/2025
**Due date:** 21/09/ 2025 at 23h59
**Total Marks:** 100

## Group Members
Chantelle van Wyk - 212087312
Nicole Fillipus - 215034821
Esther Kadhikwa 222091789
Billy Mafenyeho - 219099588
Danjumuka Amenenge - 218062931
Enzo Jantjies -216097975


NOTE: 100% AI-generated codes will be awarded a zero. AI tools should be used as a guide only.

## Question 1: Restful APIs
The Facilities Directorate at NUST wants to keep track of all the assets it owns, such as laboratory equipment, servers, and vehicles. Each asset has important details like its tag, name, faculty,
department, date acquired, and current status (ACTIVE, UNDER_REPAIR, or DISPOSED).

But assets are not just single items. Each one can have:
• Components - parts of the asset, e.g., a motor in a printer or a hard drive in a server.
• Maintenance schedules - regular servicing plans, e.g., quarterly or yearly checks, with a next due date.
• Work orders - when something breaks, a work order is opened to fix it.
• Tasks - small jobs under a work order, like “replace screen” or “update antivirus.”

The university wants you to design and implement a RESTful API in Ballerina that will allow staff to:
• Create and manage assets — add new assets, update their information, look them up, or remove them.
• View all assets — get a list of all assets
• View assets that belong to one faculty
• Check for overdue items — find assets that have maintenance schedules whose due date has already passed.
• Manage components — add or remove components of an asset.
• Manage schedules — add or remove servicing schedules for an asset.
• Manage work orders — open a new work order if an asset is faulty, update its status, or close it.
• Manage tasks — add or remove the small tasks under a work order.

The main database must be implemented as a map or a table, where each asset is identified by its assetTag (the unique key).
Inside each asset, there are lists of components, schedules, and work orders.
Your task is to build an API that works like a mini asset-management system for the university.
It should follow RESTful principles, handle the different entities and their relationships, and
support operations such as add, update, delete, and search.

### Deliverables:

1. Working Solution (7 marks)
• Correct setup and compilation.
• Proper use of the map/table for the main database

2. Service Implementation (35 marks)
• Create and manage assets - add, update, look up, or remove assets (10 marks)
• View all assets - retrieve the full list (3 marks)
• View assets by faculty- filter by faculty (5 marks)
• Check for overdue items -return assets with overdue maintenance schedules (5 marks)
• Manage components- add/remove components for an asset (5 marks)
• Manage schedules -add/remove schedules for an asset (5 marks)
(Total = 35 marks)

3. Client Implementation (10 marks)
• Ballerina client that correctly interacts with the service.
• Demonstrates at least:
o Adding and updating an asset
o Viewing all assets
o Viewing by faculty
o Overdue check
o Managing at least one component or schedule
(Total = 10 marks)

## Question 2: Remote invocation: CAR RENTAL SYSTEM using gRPC
Your task is to design and implement a gRPC-based CAR RENTAL SYSTEM that supports two user roles—Customer and Admin—to manage cars, browse availability, add cars to a rental cart (with dates), and place reservations. Customers can view available cars, search for a specific car
by plate, add it to their cart with intended rental dates, and place a reservation. Admins can add new cars, update car details, remove cars, and list all reservations.

In short, we have the following operations:
➢ add_car: An admin registers a car in the system (make, model, year, daily price, mileage, number plate, status). The system returns the car’s unique ID (the plate).
➢ create_users () - Multiple users (customers or admins), each with a specific profile, are created and streamed to the server. The response is returned once the operation completes.
➢ update_car () – Admin can change a car’s details using its plate as the key (e.g., adjust the daily price, set status to AVAILABLE/UNAVAILABLE).
➢ remove_car () -Admin can delete a car from the inventory. The server responds with the new full list of cars, so the admin sees the updated catalogue.
➢ list_available_cars () - Customers ask for cars they can rent now. The server streams back the available cars one by one (optionally filtered by text like “Toyota” or a year).
➢ search_car () -Customer looks up a specific car by its plate. If it’s available, the server returns its details; otherwise, you’re told it isn’t available.
➢ add_to_cart () - Customer picks a car (by plate) and supplies start and end dates for the rental. The server checks basic rules (dates make sense, car exists). If OK, it adds this selection to the customer’s “cart” (a temporary list).
➢ place_reservation ()

This turns whatever is in the customer’s cart into an actual reservation. The server:
✓ Verifies that each car is still available for the requested dates (no overlaps).
✓ Calculates the price (days × daily rate).
✓ Confirm the booking and clear the cart.

Your task is to define a protocol buffer contract with the remote functions and implement both the client and the server in the Ballerina Language.

### Server Implementation:

Implement the server logic using the Ballerina Language and gRPC. Your server should handle
incoming requests from clients and perform appropriate actions based on the requested operation.

### Client Implementation:

The clients should be able to use the generated gRPC client code to connect to the server and perform operations as implemented in the service. Clients should be able to handle user input and display relevant information to the user.

Please be aware that you have the freedom to include additional fields in your records if you believe they would enhance the performance and overall quality of your system.

### Deliverables:

We will follow the criteria below to assess this problem:

• Definition of the remote interface in Protocol Buffer. (15 marks)
• Implementation of the gRPC client in the Ballerina language, and able to test the application. (10 marks)
• Implementation of the gRPC server and server-side logic in response to the remote invocations in the Ballerina Language. [25 marks]

### Submission Instructions
• This assignment is to be completed by groups of 5-7 students each.
• For each group, a repository should be created on GitHub or GitLab. The repository should have all group members set up as contributors.
• All assignments must be uploaded to a GitHub or GitLab repository. Students who haven't pushed any code to the repository will not be given the opportunity to present and defend the assignment. More particularly, if a student’s username does not appear in the commit log of the group repository, that student will be assumed not to have contributed to the project and thus be awarded the mark 0.
• The assignment will be group work, but individual marks will be allocated based on each student's contribution to the assignment.
• Marks for the assignment will only be allocated to students who have presented the assignment.
• It’s the responsibility of all group members to make sure that they are available for the assignment presentation. An assignment cannot be presented more than once.
• The submission deadline date is Sunday, September 21, 2025, at 23h59. Please note that commits after that deadline will not be accepted. Therefore, a submission will be assessed based on the clone of the repository at the deadline.
• Any group that fails to submit on time will be awarded a mark of 0. Late submissions are not to be entertained.
• There should be no assumption about the execution environment of your code. It could be run using a specific framework or on the command line.
• In the case of plagiarism (groups copying from each other or submissions copied from the Internet), all submissions involved will be awarded the mark 0, and each student will receive a warning.
• 100% AI-generated codes will be awarded a zero. AI tools should be used as a guide only.
