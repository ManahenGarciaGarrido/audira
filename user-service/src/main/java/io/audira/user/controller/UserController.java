package io.audira.user.controller;

import io.audira.user.dto.UpdateProfileRequest;
import io.audira.user.dto.UserDTO;
import io.audira.user.model.UserRole;
import io.audira.user.security.UserPrincipal;
import io.audira.user.service.UserService;
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

    @GetMapping("/me")
    public ResponseEntity<UserDTO> getCurrentUser(@AuthenticationPrincipal UserPrincipal currentUser) {
        return ResponseEntity.ok(userService.getUserById(currentUser.getId()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getUserById(id));
    }

    @GetMapping("/username/{username}")
    public ResponseEntity<UserDTO> getUserByUsername(@PathVariable String username) {
        return ResponseEntity.ok(userService.getUserByUsername(username));
    }

    @GetMapping
    public ResponseEntity<List<UserDTO>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @GetMapping("/role/{role}")
    public ResponseEntity<List<UserDTO>> getUsersByRole(@PathVariable UserRole role) {
        return ResponseEntity.ok(userService.getUsersByRole(role));
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserDTO> updateProfile(
            @PathVariable Long id,
            @RequestBody UpdateProfileRequest request,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        if (!id.equals(currentUser.getId())) {
            return ResponseEntity.status(403).build();
        }
        return ResponseEntity.ok(userService.updateProfile(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        if (!id.equals(currentUser.getId())) {
            return ResponseEntity.status(403).build();
        }
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/follow/{targetId}")
    public ResponseEntity<UserDTO> followUser(
            @PathVariable Long id,
            @PathVariable Long targetId,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        if (!id.equals(currentUser.getId())) {
            return ResponseEntity.status(403).build();
        }
        return ResponseEntity.ok(userService.followUser(id, targetId));
    }

    @DeleteMapping("/{id}/follow/{targetId}")
    public ResponseEntity<UserDTO> unfollowUser(
            @PathVariable Long id,
            @PathVariable Long targetId,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        if (!id.equals(currentUser.getId())) {
            return ResponseEntity.status(403).build();
        }
        return ResponseEntity.ok(userService.unfollowUser(id, targetId));
    }

    @GetMapping("/{id}/followers")
    public ResponseEntity<List<UserDTO>> getFollowers(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getFollowers(id));
    }

    @GetMapping("/{id}/following")
    public ResponseEntity<List<UserDTO>> getFollowing(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getFollowing(id));
    }
}
