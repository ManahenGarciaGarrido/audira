package io.audira.catalog.repository;

import io.audira.catalog.model.Collaboration;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface CollaborationRepository extends JpaRepository<Collaboration, Long> {
    Optional<Collaboration> findBySongId(Long songId);

    @Query("SELECT c FROM Collaboration c WHERE :artistId MEMBER OF c.collaboratorIds")
    List<Collaboration> findByCollaboratorId(Long artistId);
}
