package io.audira.store.service;

import io.audira.store.model.Product;
import io.audira.store.model.ProductVariant;
import io.audira.store.repository.ProductRepository;
import io.audira.store.repository.ProductVariantRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    private final ProductVariantRepository productVariantRepository;

    @Transactional
    public Product createProduct(Product product) {
        return productRepository.save(product);
    }

    public Optional<Product> getProductById(Long id) {
        return productRepository.findById(id);
    }

    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    public List<Product> getProductsByArtist(Long artistId) {
        return productRepository.findByArtistId(artistId);
    }

    public List<Product> getProductsByCategory(String category) {
        return productRepository.findByCategory(category);
    }

    public List<Product> getProductsByArtistAndCategory(Long artistId, String category) {
        return productRepository.findByArtistIdAndCategory(artistId, category);
    }

    public List<Product> searchProducts(String keyword) {
        return productRepository.searchByKeyword(keyword);
    }

    public List<String> getAllCategories() {
        return productRepository.findAllCategories();
    }

    @Transactional
    public Product updateProduct(Long id, Product productDetails) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));

        product.setName(productDetails.getName());
        product.setDescription(productDetails.getDescription());
        product.setPrice(productDetails.getPrice());
        product.setStock(productDetails.getStock());
        product.setCategory(productDetails.getCategory());

        if (productDetails.getImageUrls() != null) {
            product.setImageUrls(productDetails.getImageUrls());
        }

        return productRepository.save(product);
    }

    @Transactional
    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
    }

    @Transactional
    public ProductVariant addVariant(Long productId, ProductVariant variant) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + productId));

        variant.setProduct(product);
        return productVariantRepository.save(variant);
    }

    public List<ProductVariant> getVariantsByProductId(Long productId) {
        return productVariantRepository.findByProductId(productId);
    }

    public Optional<ProductVariant> getVariantById(Long variantId) {
        return productVariantRepository.findById(variantId);
    }

    @Transactional
    public ProductVariant updateVariant(Long variantId, ProductVariant variantDetails) {
        ProductVariant variant = productVariantRepository.findById(variantId)
                .orElseThrow(() -> new RuntimeException("Variant not found with id: " + variantId));

        variant.setName(variantDetails.getName());
        variant.setPrice(variantDetails.getPrice());
        variant.setStock(variantDetails.getStock());

        if (variantDetails.getAttributes() != null) {
            variant.setAttributes(variantDetails.getAttributes());
        }

        return productVariantRepository.save(variant);
    }

    @Transactional
    public void deleteVariant(Long variantId) {
        productVariantRepository.deleteById(variantId);
    }

    @Transactional
    public Product updateStock(Long productId, Integer newStock) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + productId));

        product.setStock(newStock);
        return productRepository.save(product);
    }

    @Transactional
    public ProductVariant updateVariantStock(Long variantId, Integer newStock) {
        ProductVariant variant = productVariantRepository.findById(variantId)
                .orElseThrow(() -> new RuntimeException("Variant not found with id: " + variantId));

        variant.setStock(newStock);
        return productVariantRepository.save(variant);
    }
}
