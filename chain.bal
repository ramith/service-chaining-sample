import ballerina/http;

@http:ServiceConfig {basePath: "/employee"}
service EmployeeSummery on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["GET", "POST"],
        path: "/{employeeId}"
    }
    resource function GetEmployee(http:Caller caller, http:Request req, string employeeId) returns error? {
        http:Client clientEP = new ("http://localhost:9091");
        var response = checkpanic clientEP->get("/company/hr/employee/" + <@untainted>employeeId);
        if response is http:Response && response.statusCode == http:STATUS_NOT_FOUND {
            checkpanic caller->respond(http:STATUS_NOT_FOUND);
            return;
        }

        json employeeData = <@untainted>checkpanic (<http:Response>response).getJsonPayload();
        string departmentId = <string>checkpanic employeeData.departmentId;
        string firstName = <string>checkpanic employeeData.firstName;
        string lastName = <string>checkpanic employeeData.lastName;
        string title = <string>checkpanic employeeData.title;

        response = checkpanic clientEP->get("/company/hr/department/" + departmentId);
        if response is http:Response && response.statusCode == http:STATUS_NOT_FOUND {
            checkpanic caller->respond(http:STATUS_INTERNAL_SERVER_ERROR);
            return;
        }

        json departmentData = <@untainted>checkpanic (<http:Response>response).getJsonPayload();
        string departmentName = <string>checkpanic departmentData.name;
        json summary = {
            name: firstName + " " + lastName,
            title: title,
            department: departmentName
        };

        checkpanic caller->ok(summary);
    }
}
