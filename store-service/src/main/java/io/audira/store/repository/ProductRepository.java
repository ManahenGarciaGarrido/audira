package io.audira.store.repository;

import io.audira.store.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByArtistId(Long artistId);
    List<Product> findByCategory(String category);
    List<Product> findByArtistIdAndCategory(Long artistId, String category);

    @Query("SELECT p FROM Product p WHERE LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(p.description) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Product> searchByKeyword(String keyword);

    @Query("SELECT DISTINCT p.category FROM Product p")
    List<String> findAllCategories();
}
