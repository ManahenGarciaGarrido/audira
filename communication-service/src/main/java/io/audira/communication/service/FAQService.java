package io.audira.communication.service;

import io.audira.communication.model.FAQ;
import io.audira.communication.repository.FAQRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class FAQService {

    private final FAQRepository faqRepository;

    public List<FAQ> getAllFAQs() {
        return faqRepository.findAll();
    }

    public List<FAQ> getActiveFAQs() {
        return faqRepository.findByIsActiveTrueOrderByDisplayOrderAsc();
    }

    public List<FAQ> getFAQsByCategory(FAQ.FAQCategory category) {
        return faqRepository.findByCategoryAndIsActiveTrueOrderByDisplayOrderAsc(category);
    }

    public FAQ getFAQById(Long id) {
        return faqRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("FAQ not found with id: " + id));
    }

    @Transactional
    public FAQ createFAQ(FAQ faq) {
        return faqRepository.save(faq);
    }

    @Transactional
    public FAQ updateFAQ(Long id, FAQ faqDetails) {
        FAQ faq = getFAQById(id);
        faq.setQuestion(faqDetails.getQuestion());
        faq.setAnswer(faqDetails.getAnswer());
        faq.setCategory(faqDetails.getCategory());
        faq.setDisplayOrder(faqDetails.getDisplayOrder());
        faq.setIsActive(faqDetails.getIsActive());
        return faqRepository.save(faq);
    }

    @Transactional
    public FAQ toggleFAQActive(Long id) {
        FAQ faq = getFAQById(id);
        faq.setIsActive(!faq.getIsActive());
        return faqRepository.save(faq);
    }

    @Transactional
    public FAQ incrementViewCount(Long id) {
        FAQ faq = getFAQById(id);
        faq.setViewCount(faq.getViewCount() + 1);
        return faqRepository.save(faq);
    }

    @Transactional
    public FAQ markAsHelpful(Long id) {
        FAQ faq = getFAQById(id);
        faq.setHelpfulCount(faq.getHelpfulCount() + 1);
        return faqRepository.save(faq);
    }

    @Transactional
    public FAQ markAsNotHelpful(Long id) {
        FAQ faq = getFAQById(id);
        faq.setNotHelpfulCount(faq.getNotHelpfulCount() + 1);
        return faqRepository.save(faq);
    }

    @Transactional
    public void deleteFAQ(Long id) {
        faqRepository.deleteById(id);
    }
}
