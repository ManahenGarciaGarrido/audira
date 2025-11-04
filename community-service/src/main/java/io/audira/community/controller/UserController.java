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

    // Endpoint: GET /api/users/{userId}/followers
    @GetMapping("/{userId}/followers")
    public ResponseEntity<List<UserDTO>> getUserFollowers(@PathVariable("userId") Long userId) {
        List<UserDTO> followers = userService.getFollowers(userId);
        return ResponseEntity.ok(followers);
    }

    // Endpoint: GET /api/users/{userId}/following
    @GetMapping("/{userId}/following")
    public ResponseEntity<List<UserDTO>> getUserFollowing(@PathVariable("userId") Long userId) {
        List<UserDTO> following = userService.getFollowing(userId);
        return ResponseEntity.ok(following);
    }

    // Endpoint: GET /api/users/{userId}/following/artists
    @GetMapping("/{userId}/following/artists")
    public ResponseEntity<List<UserDTO>> getFollowedArtists(@PathVariable("userId") Long userId) {
        List<UserDTO> followedArtists = userService.getFollowedArtists(userId);
        return ResponseEntity.ok(followedArtists);
    }

    // Endpoint: POST /api/users/{userId}/follow/{targetUserId}
    @PostMapping("/{userId}/follow/{targetUserId}")
    public ResponseEntity<UserDTO> followUser(
            @PathVariable("userId") Long userId,
            @PathVariable("targetUserId") Long targetUserId) {
        UserDTO updatedUser = userService.followUser(userId, targetUserId);
        return ResponseEntity.ok(updatedUser);
    }

    // Endpoint: DELETE /api/users/{userId}/follow/{targetUserId}
    @DeleteMapping("/{userId}/follow/{targetUserId}")
    public ResponseEntity<UserDTO> unfollowUser(
            @PathVariable("userId") Long userId,
            @PathVariable("targetUserId") Long targetUserId) {
        UserDTO updatedUser = userService.unfollowUser(userId, targetUserId);
        return ResponseEntity.ok(updatedUser);
    }
}