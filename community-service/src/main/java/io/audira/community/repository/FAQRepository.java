package io.audira.community.repository;

import io.audira.community.model.FAQ;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface FAQRepository extends JpaRepository<FAQ, Long> {
    List<FAQ> findByIsActiveTrue();
    List<FAQ> findByCategoryAndIsActiveTrue(FAQ.FAQCategory category);
    List<FAQ> findByIsActiveTrueOrderByDisplayOrderAsc();
    List<FAQ> findByCategoryAndIsActiveTrueOrderByDisplayOrderAsc(FAQ.FAQCategory category);
}
