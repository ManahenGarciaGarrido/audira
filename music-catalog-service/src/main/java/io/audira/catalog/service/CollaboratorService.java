package io.audira.catalog.service;

import io.audira.catalog.model.Collaborator;
import io.audira.catalog.repository.CollaboratorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CollaboratorService {

    private final CollaboratorRepository collaboratorRepository;

    @Transactional
    public Collaborator addCollaborator(Collaborator collaborator) {
        return collaboratorRepository.save(collaborator);
    }

    public List<Collaborator> getCollaboratorsBySong(Long songId) {
        return collaboratorRepository.findBySongId(songId);
    }

    public List<Collaborator> getCollaborationsByArtist(Long artistId) {
        return collaboratorRepository.findByArtistId(artistId);
    }

    @Transactional
    public void removeCollaborator(Long collaboratorId) {
        collaboratorRepository.deleteById(collaboratorId);
    }

    @Transactional
    public void removeAllCollaboratorsFromSong(Long songId) {
        collaboratorRepository.deleteBySongId(songId);
    }
}
