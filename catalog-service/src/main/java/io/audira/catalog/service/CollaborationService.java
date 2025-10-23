package io.audira.catalog.service;

import io.audira.catalog.model.Collaboration;
import io.audira.catalog.repository.CollaborationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CollaborationService {

    private final CollaborationRepository collaborationRepository;

    @Transactional
    public Collaboration createCollaboration(Collaboration collaboration) {
        return collaborationRepository.save(collaboration);
    }

    public List<Collaboration> getCollaborationsBySong(Long songId) {
        return collaborationRepository.findBySongId(songId);
    }

    public List<Collaboration> getCollaborationsByArtist(Long artistId) {
        return collaborationRepository.findByCollaboratorIdsContaining(artistId);
    }

    @Transactional
    public void deleteCollaboration(Long id) {
        collaborationRepository.deleteById(id);
    }
}
