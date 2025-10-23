package io.audira.community.controller;

import io.audira.community.dto.UpdateProfileRequest;
import io.audira.community.dto.UserDTO;
import io.audira.community.security.UserPrincipal;
import io.audira.community.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    // Endpoint: GET /api/users/profile (probado en el script)
    @GetMapping("/profile")
    public ResponseEntity<UserDTO> getCurrentUserProfile(@AuthenticationPrincipal UserPrincipal currentUser) {
        UserDTO userProfile = userService.getUserById(currentUser.getId());
        return ResponseEntity.ok(userProfile);
    }

    // Endpoint: PUT /api/users/profile (probado en el script)
    @PutMapping("/profile")
    public ResponseEntity<UserDTO> updateCurrentUserProfile(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @Valid @RequestBody UpdateProfileRequest updateRequest
    ) {
        UserDTO updatedProfile = userService.updateProfile(currentUser.getId(), updateRequest);
        return ResponseEntity.ok(updatedProfile);
    }

    // Endpoint: GET /api/users/{id} (probado en el script)
    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getUserProfileById(@PathVariable("id") Long userId) {
        UserDTO userProfile = userService.getUserById(userId);
        return ResponseEntity.ok(userProfile);
    }

    // Endpoint: GET /api/users (probado en el script)
    @GetMapping
    public ResponseEntity<List<UserDTO>> getAllUsers() {
        List<UserDTO> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }
}