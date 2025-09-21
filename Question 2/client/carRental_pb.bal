import ballerina/grpc;
import ballerina/protobuf;

public const string CARRENTAL_DESC = "0A0F63617252656E74616C2E70726F746F120F63617272656E74616C73797374656D22CC010A045573657212170A07757365725F69641801200128095206757365724964121A0A08757365726E616D651802200128095208757365726E616D65121A0A0870617373776F7264180320012809520870617373776F726412120A046E616D6518042001280952046E616D6512140A05656D61696C1805200128095205656D61696C121F0A0B637573746F6D65725F6964180620012809520A637573746F6D6572496412140A0570686F6E65180720012809520570686F6E6512120A04726F6C651808200128095204726F6C6522F5010A0343617212150A066361725F69641801200128095205636172496412140A05706C6174651802200128095205706C61746512120A046D616B6518032001280952046D616B6512140A056D6F64656C18042001280952056D6F64656C121A0A0863617465676F7279180520012809520863617465676F727912120A0479656172180620012805520479656172121D0A0A6461696C795F7261746518072001280152096461696C795261746512140A056B696C6F7318082001280552056B696C6F7312320A0673746174757318092001280E321A2E63617272656E74616C73797374656D2E4361725374617475735206737461747573227B0A08436172744974656D12140A05706C6174651801200128095205706C617465121D0A0A73746172745F64617465180220012809520973746172744461746512190A08656E645F646174651803200128095207656E6444617465121F0A0B637573746F6D65725F6964180420012809520A637573746F6D657249642283020A0B5265736572766174696F6E12250A0E7265736572766174696F6E5F6964180120012809520D7265736572766174696F6E4964121F0A0B637573746F6D65725F6964180220012809520A637573746F6D6572496412140A05706C6174651803200128095205706C617465121D0A0A73746172745F64617465180420012809520973746172744461746512190A08656E645F646174651805200128095207656E644461746512210A0C746F74616C5F7072696E6365180620012801520B746F74616C5072696E636512210A0C626F6F6B696E675F64617465180720012809520B626F6F6B696E674461746512160A06737461747573180820012809520673746174757322CE010A0D4164644361725265717565737412120A046D616B6518012001280952046D616B6512140A056D6F64656C18022001280952056D6F64656C12120A0479656172180320012805520479656172121F0A0B6461696C795F7072696365180420012801520A6461696C79507269636512140A056B696C6F7318052001280552056B696C6F7312140A05706C6174651806200128095205706C61746512320A0673746174757318072001280E321A2E63617272656E74616C73797374656D2E4361725374617475735206737461747573223F0A1243726561746555736572735265717565737412290A047573657218012001280B32152E63617272656E74616C73797374656D2E5573657252047573657222D1010A105570646174654361725265717565737412140A05706C6174651801200128095205706C61746512120A046D616B6518022001280952046D616B6512140A056D6F64656C18032001280952056D6F64656C12120A0479656172180420012805520479656172121F0A0B6461696C795F7072696365180520012801520A6461696C79507269636512140A056B696C6F7318062001280552056B696C6F7312320A0673746174757318072001280E321A2E63617272656E74616C73797374656D2E436172537461747573520673746174757322280A1052656D6F76654361725265717565737412140A05706C6174651801200128095205706C617465225C0A184C697374417661696C61626C654361727352657175657374121F0A0B66696C7465725F74657874180120012809520A66696C74657254657874121F0A0B66696C7465725F79656172180220012805520A66696C7465725965617222280A105365617263684361725265717565737412140A05706C6174651801200128095205706C6174652283010A10416464546F4361727452657175657374121F0A0B637573746F6D65725F6964180120012809520A637573746F6D6572496412140A05706C6174651802200128095205706C617465121D0A0A73746172745F64617465180320012809520973746172744461746512190A08656E645F646174651804200128095207656E6444617465223A0A17506C6163655265736572766174696F6E52657175657374121F0A0B637573746F6D65725F6964180120012809520A637573746F6D65724964225B0A0E416464436172526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512150A066361725F696418032001280952056361724964226E0A134372656174655573657273526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512230A0D75736572735F63726561746564180320012805520C757365727343726561746564227E0A11557064617465436172526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512350A0B757064617465645F63617218032001280B32142E63617272656E74616C73797374656D2E436172520A757064617465644361722284010A1152656D6F7665436172526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D657373616765123B0A0E72656D61696E696E675F6361727318032003280B32142E63617272656E74616C73797374656D2E436172520D72656D61696E696E674361727322430A194C697374417661696C61626C6543617273526573706F6E736512260A0363617218012001280B32142E63617272656E74616C73797374656D2E4361725203636172226B0A11536561726368436172526573706F6E736512140A05666F756E641801200128085205666F756E6412180A076D65737361676518022001280952076D65737361676512260A0363617218032001280B32142E63617272656E74616C73797374656D2E43617252036361722281010A11416464546F43617274526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512380A0A636172745F6974656D7318032003280B32192E63617272656E74616C73797374656D2E436172744974656D5209636172744974656D7322B3010A18506C6163655265736572766174696F6E526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512400A0C7265736572766174696F6E7318032003280B321C2E63617272656E74616C73797374656D2E5265736572766174696F6E520C7265736572766174696F6E7312210A0C746F74616C5F616D6F756E74180420012801520B746F74616C416D6F756E7422460A0C4C6F67696E52657175657374121A0A08757365726E616D651801200128095208757365726E616D65121A0A0870617373776F7264180220012809520870617373776F726422BD010A0D4C6F67696E526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512170A07757365725F69641803200128095206757365724964121A0A08757365726E616D651804200128095208757365726E616D65122D0A04726F6C6518052001280E32192E63617272656E74616C73797374656D2E55736572526F6C655204726F6C6512140A05746F6B656E1806200128095205746F6B656E2A230A0855736572526F6C65120C0A08435553544F4D4552100012090A0541444D494E10012A370A09436172537461747573120D0A09415641494C41424C451000120F0A0B554E415641494C41424C451001120A0A0652454E544544100232A8060A1043617252656E74616C5365727669636512460A054C6F67696E121D2E63617272656E74616C73797374656D2E4C6F67696E526571756573741A1E2E63617272656E74616C73797374656D2E4C6F67696E526573706F6E736512490A06416464436172121E2E63617272656E74616C73797374656D2E416464436172526571756573741A1F2E63617272656E74616C73797374656D2E416464436172526573706F6E7365125A0A0B437265617465557365727312232E63617272656E74616C73797374656D2E4372656174655573657273526571756573741A242E63617272656E74616C73797374656D2E4372656174655573657273526573706F6E7365280112520A0955706461746543617212212E63617272656E74616C73797374656D2E557064617465436172526571756573741A222E63617272656E74616C73797374656D2E557064617465436172526573706F6E736512520A0952656D6F766543617212212E63617272656E74616C73797374656D2E52656D6F7665436172526571756573741A222E63617272656E74616C73797374656D2E52656D6F7665436172526573706F6E7365126C0A114C697374417661696C61626C654361727312292E63617272656E74616C73797374656D2E4C697374417661696C61626C6543617273526571756573741A2A2E63617272656E74616C73797374656D2E4C697374417661696C61626C6543617273526573706F6E7365300112520A0953656172636843617212212E63617272656E74616C73797374656D2E536561726368436172526571756573741A222E63617272656E74616C73797374656D2E536561726368436172526573706F6E736512520A09416464546F4361727412212E63617272656E74616C73797374656D2E416464546F43617274526571756573741A222E63617272656E74616C73797374656D2E416464546F43617274526573706F6E736512670A10506C6163655265736572766174696F6E12282E63617272656E74616C73797374656D2E506C6163655265736572766174696F6E526571756573741A292E63617272656E74616C73797374656D2E506C6163655265736572766174696F6E526573706F6E7365620670726F746F33";

public isolated client class CarRentalServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, CARRENTAL_DESC);
    }

    isolated remote function Login(LoginRequest|ContextLoginRequest req) returns LoginResponse|grpc:Error {
        map<string|string[]> headers = {};
        LoginRequest message;
        if req is ContextLoginRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/Login", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <LoginResponse>result;
    }

    isolated remote function LoginContext(LoginRequest|ContextLoginRequest req) returns ContextLoginResponse|grpc:Error {
        map<string|string[]> headers = {};
        LoginRequest message;
        if req is ContextLoginRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/Login", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <LoginResponse>result, headers: respHeaders};
    }

    isolated remote function AddCar(AddCarRequest|ContextAddCarRequest req) returns AddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddCarRequest message;
        if req is ContextAddCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/AddCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddCarResponse>result;
    }

    isolated remote function AddCarContext(AddCarRequest|ContextAddCarRequest req) returns ContextAddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddCarRequest message;
        if req is ContextAddCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/AddCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddCarResponse>result, headers: respHeaders};
    }

    isolated remote function UpdateCar(UpdateCarRequest|ContextUpdateCarRequest req) returns UpdateCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/UpdateCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <UpdateCarResponse>result;
    }

    isolated remote function UpdateCarContext(UpdateCarRequest|ContextUpdateCarRequest req) returns ContextUpdateCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/UpdateCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <UpdateCarResponse>result, headers: respHeaders};
    }

    isolated remote function RemoveCar(RemoveCarRequest|ContextRemoveCarRequest req) returns RemoveCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/RemoveCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <RemoveCarResponse>result;
    }

    isolated remote function RemoveCarContext(RemoveCarRequest|ContextRemoveCarRequest req) returns ContextRemoveCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/RemoveCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <RemoveCarResponse>result, headers: respHeaders};
    }

    isolated remote function SearchCar(SearchCarRequest|ContextSearchCarRequest req) returns SearchCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/SearchCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <SearchCarResponse>result;
    }

    isolated remote function SearchCarContext(SearchCarRequest|ContextSearchCarRequest req) returns ContextSearchCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/SearchCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <SearchCarResponse>result, headers: respHeaders};
    }

    isolated remote function AddToCart(AddToCartRequest|ContextAddToCartRequest req) returns AddToCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/AddToCart", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddToCartResponse>result;
    }

    isolated remote function AddToCartContext(AddToCartRequest|ContextAddToCartRequest req) returns ContextAddToCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/AddToCart", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddToCartResponse>result, headers: respHeaders};
    }

    isolated remote function PlaceReservation(PlaceReservationRequest|ContextPlaceReservationRequest req) returns PlaceReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/PlaceReservation", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <PlaceReservationResponse>result;
    }

    isolated remote function PlaceReservationContext(PlaceReservationRequest|ContextPlaceReservationRequest req) returns ContextPlaceReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/PlaceReservation", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <PlaceReservationResponse>result, headers: respHeaders};
    }

    isolated remote function CreateUsers() returns CreateUsersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("carrentalsystem.CarRentalService/CreateUsers");
        return new CreateUsersStreamingClient(sClient);
    }

    isolated remote function ListAvailableCars(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns stream<ListAvailableCarsResponse, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("carrentalsystem.CarRentalService/ListAvailableCars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        ListAvailableCarsResponseStream outputStream = new ListAvailableCarsResponseStream(result);
        return new stream<ListAvailableCarsResponse, grpc:Error?>(outputStream);
    }

    isolated remote function ListAvailableCarsContext(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns ContextListAvailableCarsResponseStream|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("carrentalsystem.CarRentalService/ListAvailableCars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        ListAvailableCarsResponseStream outputStream = new ListAvailableCarsResponseStream(result);
        return {content: new stream<ListAvailableCarsResponse, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public isolated client class CreateUsersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendCreateUsersRequest(CreateUsersRequest message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextCreateUsersRequest(ContextCreateUsersRequest message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveCreateUsersResponse() returns CreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <CreateUsersResponse>payload;
        }
    }

    isolated remote function receiveContextCreateUsersResponse() returns ContextCreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <CreateUsersResponse>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public class ListAvailableCarsResponseStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|ListAvailableCarsResponse value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|ListAvailableCarsResponse value;|} nextRecord = {value: <ListAvailableCarsResponse>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public type ContextListAvailableCarsResponseStream record {|
    stream<ListAvailableCarsResponse, error?> content;
    map<string|string[]> headers;
|};

public type ContextCreateUsersRequestStream record {|
    stream<CreateUsersRequest, error?> content;
    map<string|string[]> headers;
|};

public type ContextLoginResponse record {|
    LoginResponse content;
    map<string|string[]> headers;
|};

public type ContextListAvailableCarsResponse record {|
    ListAvailableCarsResponse content;
    map<string|string[]> headers;
|};

public type ContextPlaceReservationResponse record {|
    PlaceReservationResponse content;
    map<string|string[]> headers;
|};

public type ContextRemoveCarRequest record {|
    RemoveCarRequest content;
    map<string|string[]> headers;
|};

public type ContextUpdateCarRequest record {|
    UpdateCarRequest content;
    map<string|string[]> headers;
|};

public type ContextAddCarResponse record {|
    AddCarResponse content;
    map<string|string[]> headers;
|};

public type ContextAddToCartResponse record {|
    AddToCartResponse content;
    map<string|string[]> headers;
|};

public type ContextUpdateCarResponse record {|
    UpdateCarResponse content;
    map<string|string[]> headers;
|};

public type ContextLoginRequest record {|
    LoginRequest content;
    map<string|string[]> headers;
|};

public type ContextAddToCartRequest record {|
    AddToCartRequest content;
    map<string|string[]> headers;
|};

public type ContextCreateUsersRequest record {|
    CreateUsersRequest content;
    map<string|string[]> headers;
|};

public type ContextListAvailableCarsRequest record {|
    ListAvailableCarsRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchCarRequest record {|
    SearchCarRequest content;
    map<string|string[]> headers;
|};

public type ContextAddCarRequest record {|
    AddCarRequest content;
    map<string|string[]> headers;
|};

public type ContextRemoveCarResponse record {|
    RemoveCarResponse content;
    map<string|string[]> headers;
|};

public type ContextPlaceReservationRequest record {|
    PlaceReservationRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchCarResponse record {|
    SearchCarResponse content;
    map<string|string[]> headers;
|};

public type ContextCreateUsersResponse record {|
    CreateUsersResponse content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type User record {|
    string user_id = "";
    string username = "";
    string password = "";
    string name = "";
    string email = "";
    string customer_id = "";
    string phone = "";
    string role = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type ListAvailableCarsResponse record {|
    Car car = {};
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type PlaceReservationResponse record {|
    boolean success = false;
    string message = "";
    Reservation[] reservations = [];
    float total_amount = 0.0;
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type LoginResponse record {|
    boolean success = false;
    string message = "";
    string user_id = "";
    string username = "";
    UserRole role = CUSTOMER;
    string token = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type RemoveCarRequest record {|
    string plate = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type UpdateCarRequest record {|
    string plate = "";
    string make = "";
    string model = "";
    int year = 0;
    float daily_price = 0.0;
    int kilos = 0;
    CarStatus status = AVAILABLE;
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type AddCarResponse record {|
    boolean success = false;
    string message = "";
    string car_id = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type AddToCartResponse record {|
    boolean success = false;
    string message = "";
    CartItem[] cart_items = [];
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type UpdateCarResponse record {|
    boolean success = false;
    string message = "";
    Car updated_car = {};
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type CartItem record {|
    string plate = "";
    string start_date = "";
    string end_date = "";
    string customer_id = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type LoginRequest record {|
    string username = "";
    string password = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type AddToCartRequest record {|
    string customer_id = "";
    string plate = "";
    string start_date = "";
    string end_date = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type CreateUsersRequest record {|
    User user = {};
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type ListAvailableCarsRequest record {|
    string filter_text = "";
    int filter_year = 0;
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type SearchCarRequest record {|
    string plate = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type AddCarRequest record {|
    string make = "";
    string model = "";
    int year = 0;
    float daily_price = 0.0;
    int kilos = 0;
    string plate = "";
    CarStatus status = AVAILABLE;
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type RemoveCarResponse record {|
    boolean success = false;
    string message = "";
    Car[] remaining_cars = [];
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type Reservation record {|
    string reservation_id = "";
    string customer_id = "";
    string plate = "";
    string start_date = "";
    string end_date = "";
    float total_prince = 0.0;
    string booking_date = "";
    string status = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type Car record {|
    string car_id = "";
    string plate = "";
    string make = "";
    string model = "";
    string category = "";
    int year = 0;
    float daily_rate = 0.0;
    int kilos = 0;
    CarStatus status = AVAILABLE;
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type PlaceReservationRequest record {|
    string customer_id = "";
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type SearchCarResponse record {|
    boolean found = false;
    string message = "";
    Car car = {};
|};

@protobuf:Descriptor {value: CARRENTAL_DESC}
public type CreateUsersResponse record {|
    boolean success = false;
    string message = "";
    int users_created = 0;
|};

public enum UserRole {
    CUSTOMER, ADMIN
}

public enum CarStatus {
    AVAILABLE, UNAVAILABLE, RENTED
}

