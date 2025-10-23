package io.audira.catalog.repository;

import io.audira.catalog.model.Album;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface AlbumRepository extends JpaRepository<Album, Long> {
    List<Album> findByArtistId(Long artistId);
    List<Album> findByTitleContainingIgnoreCase(String title);
    List<Album> findTop20ByOrderByCreatedAtDesc();

    @Query("SELECT a FROM Album a WHERE LOWER(a.title) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Album> searchByTitleOrArtist(String query);

    @Query("SELECT a FROM Album a ORDER BY a.createdAt DESC")
    List<Album> findRecentAlbums();

    @Query("SELECT a FROM Album a JOIN a.genreIds g WHERE g = :genreId")
    List<Album> findByGenreId(Long genreId);
}
