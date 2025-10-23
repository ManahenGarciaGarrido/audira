package io.audira.user.controller;

import io.audira.user.dto.UpdateProfileRequest;
import io.audira.user.dto.UserProfileDto;
import io.audira.user.security.UserPrincipal;
import io.audira.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
// Ruta base interna. El Gateway enrutará /api/users/** aquí.
// /api/users/profile -> /profile
// /api/users/123     -> /123
// /api/users         -> /
@RequestMapping("/")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    // Endpoint: GET /api/users/profile (probado en el script)
    @GetMapping("/profile")
    public ResponseEntity<UserProfileDto> getCurrentUserProfile(@AuthenticationPrincipal UserPrincipal currentUser) {
        UserProfileDto userProfile = userService.getUserProfile(currentUser.getId());
        return ResponseEntity.ok(userProfile);
    }

    // Endpoint: PUT /api/users/profile (probado en el script)
    @PutMapping("/profile")
    public ResponseEntity<UserProfileDto> updateCurrentUserProfile(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @Valid @RequestBody UpdateProfileRequest updateRequest
    ) {
        UserProfileDto updatedProfile = userService.updateUserProfile(currentUser.getId(), updateRequest);
        return ResponseEntity.ok(updatedProfile);
    }

    // Endpoint: GET /api/users/{id} (probado en el script)
    @GetMapping("/{id}")
    public ResponseEntity<UserProfileDto> getUserProfileById(@PathVariable("id") Long userId) {
        UserProfileDto userProfile = userService.getUserProfile(userId);
        return ResponseEntity.ok(userProfile);
    }

    // Endpoint: GET /api/users (probado en el script)
    @GetMapping
    public ResponseEntity<List<UserProfileDto>> getAllUsers() {
        List<UserProfileDto> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }
}