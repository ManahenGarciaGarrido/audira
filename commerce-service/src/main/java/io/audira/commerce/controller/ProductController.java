package io.audira.commerce.controller;

import io.audira.commerce.model.Product;
import io.audira.commerce.model.ProductVariant;
import io.audira.commerce.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @PostMapping
    public ResponseEntity<Product> createProduct(@RequestBody Product product) {
        return ResponseEntity.status(HttpStatus.CREATED).body(productService.createProduct(product));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {
        return productService.getProductById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts(
            @RequestParam(required = false) Long artistId,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String search) {

        List<Product> products;

        if (search != null && !search.isEmpty()) {
            products = productService.searchProducts(search);
        } else if (artistId != null && category != null) {
            products = productService.getProductsByArtistAndCategory(artistId, category);
        } else if (artistId != null) {
            products = productService.getProductsByArtist(artistId);
        } else if (category != null) {
            products = productService.getProductsByCategory(category);
        } else {
            products = productService.getAllProducts();
        }

        return ResponseEntity.ok(products);
    }

    @GetMapping("/categories")
    public ResponseEntity<List<String>> getAllCategories() {
        return ResponseEntity.ok(productService.getAllCategories());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(
            @PathVariable Long id,
            @RequestBody Product product) {
        try {
            return ResponseEntity.ok(productService.updateProduct(id, product));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/stock")
    public ResponseEntity<Product> updateStock(
            @PathVariable Long id,
            @RequestParam Integer stock) {
        try {
            return ResponseEntity.ok(productService.updateStock(id, stock));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // Variant endpoints
    @PostMapping("/{productId}/variants")
    public ResponseEntity<ProductVariant> addVariant(
            @PathVariable Long productId,
            @RequestBody ProductVariant variant) {
        try {
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(productService.addVariant(productId, variant));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{productId}/variants")
    public ResponseEntity<List<ProductVariant>> getVariants(@PathVariable Long productId) {
        return ResponseEntity.ok(productService.getVariantsByProductId(productId));
    }

    @GetMapping("/variants/{variantId}")
    public ResponseEntity<ProductVariant> getVariantById(@PathVariable Long variantId) {
        return productService.getVariantById(variantId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/variants/{variantId}")
    public ResponseEntity<ProductVariant> updateVariant(
            @PathVariable Long variantId,
            @RequestBody ProductVariant variant) {
        try {
            return ResponseEntity.ok(productService.updateVariant(variantId, variant));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/variants/{variantId}")
    public ResponseEntity<Void> deleteVariant(@PathVariable Long variantId) {
        productService.deleteVariant(variantId);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/variants/{variantId}/stock")
    public ResponseEntity<ProductVariant> updateVariantStock(
            @PathVariable Long variantId,
            @RequestParam Integer stock) {
        try {
            return ResponseEntity.ok(productService.updateVariantStock(variantId, stock));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
