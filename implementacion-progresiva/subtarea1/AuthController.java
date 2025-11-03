package io.audira.community.controller;

import io.audira.community.dto.RegisterRequest;
import io.audira.community.model.User;
import io.audira.community.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controller AuthController - Versión SUBTAREA 1
 * Endpoints de autenticación y registro
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);
    private final UserService userService;

    @PostMapping("/register")
    public ResponseEntity<User> register(@Valid @RequestBody RegisterRequest request) {
        logger.info("Register request received for email: {}", request.getEmail());
        User user = userService.registerUser(request);
        logger.info("User registered successfully: {}", request.getEmail());
        return ResponseEntity.ok(user);
    }
}
