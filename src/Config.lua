-- Stonetr03

return {
    Fusion = require(script.Parent:WaitForChild("Packages"):WaitForChild("Fusion"));
    Spacing = 20;
    Errors = {
        [0] = "";
        [400] = "There has been an error while getting the DataStore. Invalid Key";
        [401] = "There has been an error while getting the DataStore. Does Studio have access to Api Services?"
    };
    IndexColors = {
        string = Color3.fromRGB(186,85,211);
        number = Color3.fromRGB(255, 165, 0);
        key = Color3.fromRGB(0, 115, 255);
    };
    ValueColors = {
        string = Color3.fromRGB(50,205,50);
        number = Color3.fromRGB(220,20,60);
        boolean = Color3.fromRGB(30,144,255);
        table = Color3.fromRGB(156, 156, 156);
        ["nil"] = Color3.fromRGB(156, 156, 156);
    };
    Version = "v1.1.0"
}