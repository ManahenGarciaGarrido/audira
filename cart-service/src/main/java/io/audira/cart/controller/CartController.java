package io.audira.cart.controller;

import io.audira.cart.model.Cart;
import io.audira.cart.model.ItemType;
import io.audira.cart.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;

    @GetMapping("/{userId}")
    public ResponseEntity<Cart> getCart(@PathVariable Long userId) {
        return cartService.getCartByUserId(userId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/{userId}/items")
    public ResponseEntity<Cart> addItemToCart(
            @PathVariable Long userId,
            @RequestParam ItemType itemType,
            @RequestParam Long itemId,
            @RequestParam Integer quantity,
            @RequestParam BigDecimal price) {
        Cart cart = cartService.addItemToCart(userId, itemType, itemId, quantity, price);
        return ResponseEntity.ok(cart);
    }

    @PutMapping("/{userId}/items/{itemId}")
    public ResponseEntity<Cart> updateItemQuantity(
            @PathVariable Long userId,
            @PathVariable Long itemId,
            @RequestParam Integer quantity) {
        Cart cart = cartService.updateItemQuantity(userId, itemId, quantity);
        return ResponseEntity.ok(cart);
    }

    @DeleteMapping("/{userId}/items/{itemId}")
    public ResponseEntity<Cart> removeItemFromCart(
            @PathVariable Long userId,
            @PathVariable Long itemId) {
        Cart cart = cartService.removeItemFromCart(userId, itemId);
        return ResponseEntity.ok(cart);
    }

    @DeleteMapping("/{userId}")
    public ResponseEntity<Void> clearCart(@PathVariable Long userId) {
        cartService.clearCart(userId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{userId}/count")
    public ResponseEntity<Map<String, Integer>> getCartItemCount(@PathVariable Long userId) {
        int count = cartService.getCartItemCount(userId);
        Map<String, Integer> response = new HashMap<>();
        response.put("itemCount", count);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{userId}/total")
    public ResponseEntity<Map<String, BigDecimal>> getCartTotal(@PathVariable Long userId) {
        return cartService.getCartByUserId(userId)
                .map(cart -> {
                    Map<String, BigDecimal> response = new HashMap<>();
                    response.put("totalAmount", cart.getTotalAmount());
                    return ResponseEntity.ok(response);
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
