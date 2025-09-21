// Dependency: carRental.proto
// mkdir client && cd client
// bal init (to make this folder a Ballerina package)
// Client was created using:
// bal grpc --input ../carRental.proto --mode client --output .
// Run using bal run

import ballerina/io;
import ballerina/grpc;

public function main() returns error? {
    CarRentalServiceClient ep = check new ("http://localhost:9090");

    LoginResponse loginRes = check ep->Login({ username: "demo", password: "demo" });
    io:println("login -> ", loginRes);

    AddCarRequest addReq = {
        make: "VW",
        model: "T-Cross",
        year: 2023,
        daily_price: 950.0,
        kilos: 12000,
        plate: "N-209-999-W",
        status: AVAILABLE
    };
    AddCarResponse addRes = check ep->AddCar(addReq);
    io:println("addCar -> ", addRes);

    UpdateCarRequest updReq = {
        plate: "N-209-999-W",
        make: "VW",
        model: "T-Cross Comfortline",
        year: 2023,
        daily_price: 900.0,
        kilos: 12500,
        status: AVAILABLE
    };
    UpdateCarResponse updRes = check ep->UpdateCar(updReq);
    io:println("updateCar -> ", updRes);

    RemoveCarResponse remCarRes = check ep->RemoveCar({ plate: "N-209-999-W" });
    io:println("removeCar -> ", remCarRes);

    SearchCarResponse searchRes = check ep->SearchCar({ plate: "N123-456W" });
    io:println("searchCar -> ", searchRes);

    AddToCartRequest cartReq = {
        customer_id: "cust-1001",
        plate: searchRes.car.plate, 
        start_date: "2025-09-25",
        end_date:   "2025-09-28"
    };
    AddToCartResponse cartRes = check ep->AddToCart(cartReq);
    io:println("addToCart -> ", cartRes);

    PlaceReservationResponse placeRes = check ep->PlaceReservation({ customer_id: "cust-1001" });
    io:println("placeReservation -> ", placeRes);

    stream<ListAvailableCarsResponse, grpc:Error?> carStream =
        check ep->ListAvailableCars({ filter_text: "", filter_year: 0 });

    check carStream.forEach(function (ListAvailableCarsResponse v) {
        Car c = v.car;
        io:println("• ", c.make, " ", c.model, " (", c.year.toString(),
            ") plate=", c.plate, " rate=", c.daily_rate.toString(), " status=", c.status.toString());
    });

    CreateUsersStreamingClient cu = check ep->CreateUsers();

    CreateUsersRequest u1 = { user: {
        user_id: "u-1001", username: "chantelle", password: "test1234",
        name: "Chantelle van Wyk", email: "chantellecvanwyk@gmail.com",
        customer_id: "cust-1001", phone: "+264812696929", role: "CUSTOMER"
    }};
    CreateUsersRequest u2 = { user: {
        user_id: "u-1002", username: "admin", password: "admin123",
        name: "Admin", email: "admin@gmail.com",
        customer_id: "", phone: "+264812345629", role: "ADMIN"
    }};

    check cu->sendCreateUsersRequest(u1);
    check cu->sendCreateUsersRequest(u2);
    check cu->complete();
    CreateUsersResponse? cuRes = check cu->receiveCreateUsersResponse();
    io:println("createUsers -> ", cuRes);

    io:println("done.");
}
