import ballerina/http;

@http:ServiceConfig {
    basePath: "/employee"
}
service DepartmentService on new http:Listener(9091) {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/{employeeId}"
    }
    resource function GetEmployee(http:Caller caller,
        http:Request req, string employeeId) {
        
        http:Client clientEP = new ("http://localhost:9090");
        http:Response response = checkpanic clientEP->get("/employee/" + <@untainted>employeeId);
        if response.statusCode == 404 {
            checkpanic caller->respond(404);
            return;
        } 
        
        var payload = <@untainted> checkpanic response.getJsonPayload();

        var employeeRecord = record {
            string id;
            string firstName;
            string lastName;
            string title;
            string departmentId;
        };

        var employeeData = checkpanic employeeRecord.constructFrom(<map<json>>payload);
        response = checkpanic  clientEP->get("/department/" + employeeData.departmentId);
        if response.statusCode == 404 {
            checkpanic caller->respond(500);
            return;
        } 
        
        payload = checkpanic response.getJsonPayload();
        var departmentRecord = record {
            string id;
            string name;
        };

        var departmentData = <@untainted> checkpanic departmentRecord.constructFrom(payload);
        json summary = {
            name: employeeData.firstName + " " + employeeData.lastName,
            title: employeeData.title,
            department: departmentData.name
        };
        
        checkpanic caller->ok(summary);
    }
}
