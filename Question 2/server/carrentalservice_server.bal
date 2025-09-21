import ballerina/grpc;
import ballerina/log;
import ballerina/uuid;
import ballerina/crypto;
import ballerina/time;

// Helper function to hash passwords
function hashPassword(string password) returns string {
    return crypto:hashSha256(password.toBytes()).toBase16();
}


//IN MEMEORY DATA STORAGE

map<Car> carsDB = {};
map<User> usersDB = {};
map<CartItem[]> userCarts = {};
map<Reservation[]> reservationDB = {};
map<string> userTokens = {}; // mapping token to user_id

//Demo data for initial testing
function init() {   
    usersDB["u-demo"] = <User>{
        user_id: "user-001",
        username: "demo",
        password: crypto:hashSha256("demo".toBytes()).toBase16(),
        name: "Demo User",
        email: "demo@carrental.com",
        customer_id: "cust-001",
        phone: "+264814558444",
        role: "CUSTOMER"
    };

    usersDB["u-admin"] = {
        user_id: "u-admin",
        username: "admin",
        password: hashPassword("admin123"),
        name: "System Admin",
        email: "admin@carrental.com",
        customer_id: "",
        phone: "+264812345679",
        role: "ADMIN"
    };

    //demo cars for testing
    carsDB["N247-254W"] = {
        car_id: "car-003",
        plate: "N247-254W",
        make: "Audi",
        model: "A6",
        category: "Sedan",
        year: 2016,
        daily_rate: 450.0,
        kilos: 15000,
        status: AVAILABLE
    };
    
    carsDB["N789-012W"] = {
        car_id: "car-002",
        plate: "N789-012W",
        make: "Honda",
        model: "CX-5",
        category: "SUV",
        year: 2022,
        daily_rate: 750.0,
        kilos: 20000,
        status: AVAILABLE
    };
}

//gRPC service definition
@grpc:Descriptor {value: CARRENTAL_DESC}
service "CarRentalService" on new grpc:Listener(9090) {

    //Login user and return auth token
    remote function Login(LoginRequest request) returns LoginResponse | error {
        string username = request.username;
        string password = request.password;

        log:printInfo("Login attempt for user: " + username);

        //Find a User by username
        User? foundUser = ();
        foreach User user in usersDB {
            if user.username == username {
                foundUser = user;
                break;
            }
        }

        if foundUser is () {
            return {
                success: false,
                message: "Invalid user or password",
                user_id: "",
                username: "",
                role: CUSTOMER,
                token: ""
            };
        }

        //Password verification (assuming passwords are stored hashed)
        if foundUser.password != hashPassword(password) {
            return {
                success: false,
                message: "Invalid username or password",
                user_id: "",
                username: "",
                role: CUSTOMER,
                token: ""
            };
        }


        //Generate auth token
        string token = uuid:createType1AsString();
        userTokens[token] = foundUser.user_id;

        //Determine user role
        UserRole userRole = foundUser.role == "ADMIN" ? ADMIN : CUSTOMER;
        return {
            success: true,
            message: "Login successful",
            user_id: foundUser.user_id,
            username: foundUser.username,
            role: userRole,
            token: token
        };

    }

// Add new car (Admin only)
remote function AddCar(AddCarRequest request) returns AddCarResponse | error {
    string plate = request.plate;

    //Input validation 
    if plate == "" {
        return {
            success: false,
            message: "Car plate number cannot be empty",
            car_id: ""
        };
    }

    // Check if car already exists
    if carsDB.hasKey(plate) {
        return {
            success: false,
            message: "Car with plate " + plate + " already exists",
            car_id: ""
        };
    }


    //Generatin car ID
    string carId = "car-" + uuid:createType1AsString().substring(0, 8);

    //Create car object 
    Car newCar = {
        car_id: carId,
        plate: plate,
        make: request.make,
        model: request.model,
        category: request.model, //Auto determine car category
        year: request.year,
        daily_rate: request.daily_price,
        kilos: request.kilos,
        status: request.status
    };

    //Store car in DB
    carsDB[plate] = newCar;
    log:printInfo("Added new car: " + plate + " (" + newCar.make + " " + newCar.model + ")");

    return {
        success: true,
        message: "Car Added successfully",
        car_id: carId
    };
}

// Admin: Update car details
remote function UpdateCar(UpdateCarRequest request) returns UpdateCarResponse|error {
    string plate = request.plate;
    
    if !carsDB.hasKey(plate) {
        return {
            success: false,
            message: "Car with plate " + plate + " not found",
            updated_car: {}
        };
    }
    
    Car existingCar = carsDB.get(plate);
    
    // Update fields (keep existing values if new ones are empty/zero)
    Car updatedCar = {
        car_id: existingCar.car_id, 
        plate: plate,
        make: request.make != "" ? request.make : existingCar.make,
        model: request.model != "" ? request.model : existingCar.model,
        category: request.model != "" ? determinateCategory(request.model) : existingCar.category,
        year: request.year > 0 ? request.year : existingCar.year,
        daily_rate: request.daily_price > 0.0 ? request.daily_price : existingCar.daily_rate,
        kilos: request.kilos >= 0 ? request.kilos : existingCar.kilos,
        status: request.status
    };
    
    carsDB[plate] = updatedCar;
    log:printInfo("Car updated: " + plate);
    
    return {
        success: true,
        message: "Car updated successfully",
        updated_car: updatedCar
    };
}

//Admin: Create multiple users (streaming)
remote function CreateUsers(stream<CreateUsersRequest, grpc:Error?> userStream) returns CreateUsersResponse|error {
    int usersCreated = 0;
    int usersSkipped = 0;

check userStream.forEach(function(CreateUsersRequest request) {
    User user = request.user;
    if user.user_id != "" && !usersDB.hasKey(user.user_id) {
        //Hash password before storing
        user.password = hashPassword(user.password);
        usersDB[user.user_id] = user;
        usersCreated += 1;
        log:printInfo("Created user: " + user.user_id + " (" + user.username + ")");


    } else {
        usersSkipped += 1;
        log:printWarn("Skipped creating user (missing ID or already exists): " + user.user_id + " (" + user.username + ")");
    }
});


string message = string `Created ${usersCreated} users.`;
if usersSkipped > 0 {
    message += string ` Skipped ${usersSkipped} users (missing ID or already exists).`;
}

    return <CreateUsersResponse>{
        success: true,
        message: message,
        users_created: usersCreated      
    };
}  


    // Admin: Remove a car from inventory
    remote function RemoveCar(RemoveCarRequest request) returns RemoveCarResponse|error {
        string plate = request.plate;
        
        if !carsDB.hasKey(plate) {
            return {
                success: false,
                message: "Car with plate " + plate + " not found",
                remaining_cars: []
            };
        }


        // Check if car has active reservations
        boolean hasActiveReservations = false;
        foreach  Reservation[] userReservations in reservationDB {
            foreach Reservation reservation in userReservations {
                if reservation.plate == plate && reservation.status == "CONFIRMED" {
                    hasActiveReservations = true;
                    break;
                }
            }
            if hasActiveReservations {
                break;
            }
        }
        
        if hasActiveReservations {
            return {
                success: false,
                message: "Cannot remove car with active reservations",
                remaining_cars: []
            };
        }
        
        _ = carsDB.remove(plate);
        log:printInfo("Car removed: " + plate);
        
        // Return updated car list
        Car[] remainingCars = [];
        foreach Car car in carsDB {
            remainingCars.push(car);
        }
        
        return {
            success: true,
            message: "Car removed successfully",
            remaining_cars: remainingCars
        };
    }

    // Customer - List available cars
    remote function ListAvailableCars(ListAvailableCarsRequest request) 
                                returns stream<ListAvailableCarsResponse, error?>|error {
        ListAvailableCarsResponse[] availableCars = [];
        string filterText = request.filter_text.toLowerAscii();
        int filterYear = request.filter_year;
        
        foreach Car car in carsDB {
            if car.status == AVAILABLE {
                boolean matches = true;
                
                // Apply text filter if provided
                if filterText != "" {
                    string carInfo = (car.make + " " + car.model + " " + 
                                    car.category + " " + car.plate).toLowerAscii();
                    if carInfo.indexOf(filterText) is () {
                        matches = false;
                    }
                }
                
                // Apply year filter if provided
                if filterYear > 0 && car.year != filterYear {
                    matches = false;
                }
                
                if matches {
                    availableCars.push({car: car});
                }
            }
        }
        
            log:printInfo(string `Streaming ${availableCars.length()} available cars`);
            return availableCars.toStream();
        }
    
            // Customer - Search for a specific car
    remote function SearchCar(SearchCarRequest request) returns SearchCarResponse|error {
        string plate = request.plate;
        
        if !carsDB.hasKey(plate) {
            return {
                found: false,
                message: "Car with plate " + plate + " not found",
                car: {}
            };
        }
        
        Car car = carsDB.get(plate);
        string statusMsg = car.status == AVAILABLE ? "available for rental" : 
                          car.status == RENTED ? "currently rented" : "unavailable";
        
        return {
            found: true,
            message: string `Car found - ${statusMsg}`,
            car: car
        };
    }
    
    // Customer -  Add car to cart
    remote function AddToCart(AddToCartRequest request) returns AddToCartResponse|error {
        string customerId = request.customer_id;
        string plate = request.plate;
        string startDate = request.start_date;
        string endDate = request.end_date;
        
        // Validate car exists
        if !carsDB.hasKey(plate) {
            return {
                success: false,
                message: "Car with plate " + plate + " not found",
                cart_items: []
            };
        }
        
        Car car = carsDB.get(plate);
        
        // Check if car is available
        if car.status != AVAILABLE {
            return {
                success: false,
                message: "Car is not available for rental",
                cart_items: []
            };
        }
        
        // Validate dates
        if !isValidDateRange(startDate, endDate) {
            return {
                success: false,
                message: "Invalid date range. End date must be after start date",
                cart_items: []
            };
        }
        
        // Check for date conflicts with existing reservations
        if !isCarAvailableForDates(plate, startDate, endDate) {
            return {
                success: false,
                message: "Car is already booked for the selected dates",
                cart_items: []
            };
        }
        
        // Create cart item
        CartItem item = {
            plate: plate,
            start_date: startDate,
            end_date: endDate,
            customer_id: customerId
        };
        
        // Add to user's cart
        CartItem[] currentCart = userCarts[customerId] ?: [];
        
        // Check if car is already in cart
        foreach CartItem cartItem in currentCart {
            if cartItem.plate == plate {
                return {
                    success: false,
                    message: "Car is already in your cart",
                    cart_items: currentCart
                };
            }
        }
        
        currentCart.push(item);
        userCarts[customerId] = currentCart;
        
        log:printInfo(string `Cart item added for customer ${customerId}: ${plate}`);
        
        return {
            success: true,
            message: string `Car ${plate} added to cart`,
            cart_items: currentCart
        };
    }
    
    // Customer - Place reservation from cart
    remote function PlaceReservation(PlaceReservationRequest request) 
                                returns PlaceReservationResponse|error {
        string customerId = request.customer_id;
        
        // Check if user has items in cart
        if !userCarts.hasKey(customerId) || (userCarts[customerId] ?: []).length() == 0 {
            return {
                success: false,
                message: "Your cart is empty",
                reservations: [],
                total_amount: 0.0
            };
        }
        
        CartItem[] cartItems = userCarts.get(customerId);
        Reservation[] newReservations = [];
        float totalAmount = 0.0;
        
        // Validate all items before creating reservations
        foreach CartItem item in cartItems {
            // Re-check if car is still available for the dates
            if !isCarAvailableForDates(item.plate, item.start_date, item.end_date) {
                return {
                    success: false,
                    message: string `Car ${item.plate} is no longer available for selected dates`,
                    reservations: [],
                    total_amount: 0.0
                };
            }
            
            // Check if car still exists and is available
            if !carsDB.hasKey(item.plate) {
                return {
                    success: false,
                    message: string `Car ${item.plate} no longer exists`,
                    reservations: [],
                    total_amount: 0.0
                };
            }
            
            Car car = carsDB.get(item.plate);
            if car.status != AVAILABLE {
                return {
                    success: false,
                    message: string `Car ${item.plate} is not available`,
                    reservations: [],
                    total_amount: 0.0
                };
            }
        }
        
        // Create reservations
        time:Utc currentTime = time:utcNow();
        string bookingDate = time:utcToString(currentTime).substring(0, 10);
        
        foreach CartItem item in cartItems {
            Car car = carsDB.get(item.plate);
            int days = calculateDays(item.start_date, item.end_date);
            float totalPrice = <float>(days * car.daily_rate);
            
            string reservationId = "RES-" + uuid:createType1AsString().substring(0, 8);
            
            Reservation reservation = {
                reservation_id: reservationId,
                customer_id: customerId,
                plate: item.plate,
                start_date: item.start_date,
                end_date: item.end_date,
                total_prince: totalPrice, // typo in proto file
                booking_date: bookingDate,
                status: "CONFIRMED"
            };
            
            newReservations.push(reservation);
            totalAmount += totalPrice;
            
            // Store reservation
            Reservation[] customerReservations = reservationDB[customerId] ?: [];
            customerReservations.push(reservation);
            reservationDB[customerId] = customerReservations;
            
            log:printInfo(string `Reservation created: ${reservationId} for customer ${customerId}`);
        }
        
        // Clear cart after successful reservation
        _ = userCarts.remove(customerId);
        
        return {
            success: true,
            message: string `Successfully placed ${newReservations.length()} reservation(s)`,
            reservations: newReservations,
            total_amount: totalAmount
        };
    }
}


function determinateCategory(string model) returns string {
    string modelLower = model.toLowerAscii();
    
    if modelLower.indexOf("sedan") is int || modelLower.indexOf("corolla") is int || 
       modelLower.indexOf("A6") is int || modelLower.indexOf("accord") is int {
        return "Sedan";
    } else if modelLower.indexOf("suv") is int || modelLower.indexOf("fortuner") is int || 
              modelLower.indexOf("q7") is int || modelLower.indexOf("cx-5") is int {
        return "SUV";
    } else if modelLower.indexOf("bakkie") is int || modelLower.indexOf("ranger") is int || 
              modelLower.indexOf("amarok") is int {
        return "Bakkie";
    } else if modelLower.indexOf("van") is int || modelLower.indexOf("sportsvan") is int {
        return "Van";
    } else if modelLower.indexOf("polo") is int || modelLower.indexOf("hatch") is int {
        return "Hatchback";
    } else {
        return "Standard";
    }
}

function isValidDateRange(string startDate, string endDate) returns boolean {
    // Date format: YYYY-MM-DD
    if startDate.length() != 10 || endDate.length() != 10 {
        return false;
    }
    
    // Date validation: end date must be after start date
    if endDate <= startDate {
        return false;
    }
    
    // Check if start date is not in the past
    time:Utc currentTime = time:utcNow();
    string today = time:utcToString(currentTime).substring(0, 10);
    if startDate < today {
        return false;
    }
    
    return true;
}

function calculateDays(string startDate, string endDate) returns int {
    // day calculation based on date strings
    
    
    // Parse dates (YYYY-MM-DD format)
    int startYear = checkpanic int:fromString(startDate.substring(0, 4));
    int startMonth = checkpanic int:fromString(startDate.substring(5, 7));
    int startDay = checkpanic int:fromString(startDate.substring(8, 10));
    
    int endYear = checkpanic int:fromString(endDate.substring(0, 4));
    int endMonth = checkpanic int:fromString(endDate.substring(5, 7));
    int endDay = checkpanic int:fromString(endDate.substring(8, 10));
    
    // Simplified calculation (approximate)
    int yearDiff = endYear - startYear;
    int monthDiff = endMonth - startMonth;
    int dayDiff = endDay - startDay;
    
    int totalDays = (yearDiff * 365) + (monthDiff * 30) + dayDiff;
    
    // Minimum 1 day rental
    return totalDays > 0 ? totalDays : 1;
}

function isCarAvailableForDates(string plate, string startDate, string endDate) returns boolean {
    // Check if car exists and is available
    if !carsDB.hasKey(plate) {
        return false;
    }
    
    Car car = carsDB.get(plate);
    if car.status != AVAILABLE && car.status != RENTED {
        return false;
    }
    
    // Check for overlapping reservations
    foreach Reservation[] customerReservations in reservationDB {
        foreach Reservation reservation in customerReservations {
            if reservation.plate == plate && reservation.status == "CONFIRMED" {
                // Check for date overlap
                // Overlap occurs if: NOT (new_end < existing_start OR new_start > existing_end)
                boolean noOverlap = endDate < reservation.start_date || 
                                   startDate > reservation.end_date;
                if !noOverlap {
                    return false;
                }
            }
        }
    }
    
    return true;
}