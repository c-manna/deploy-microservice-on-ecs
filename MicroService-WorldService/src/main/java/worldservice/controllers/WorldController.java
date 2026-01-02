package worldservice.controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class WorldController {

    @GetMapping("/world")
    public String getWorld(){

        return "hello from service World\n";

    }

}
