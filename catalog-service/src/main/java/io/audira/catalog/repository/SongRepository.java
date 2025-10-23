package io.audira.catalog.repository;

import io.audira.catalog.model.Song;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SongRepository extends JpaRepository<Song, Long> {
    List<Song> findByArtistId(Long artistId);
    List<Song> findByAlbumId(Long albumId);
    List<Song> findByGenreId(Long genreId);
    List<Song> findByTitleContainingIgnoreCase(String title);
    List<Song> findTop20ByOrderByCreatedAtDesc();

    @Query("SELECT s FROM Song s WHERE LOWER(s.title) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Song> searchByTitleOrArtist(String query);

    @Query("SELECT s FROM Song s WHERE s.artistId = :artistId OR s.id IN " +
           "(SELECT c.songId FROM Collaboration c WHERE :artistId MEMBER OF c.collaboratorIds)")
    List<Song> findSongsByArtistIncludingCollaborations(Long artistId);

    @Query("SELECT s FROM Song s ORDER BY s.createdAt DESC")
    List<Song> findRecentSongs();
}
