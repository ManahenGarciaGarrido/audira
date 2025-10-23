package io.audira.communication.controller;

import io.audira.communication.model.FAQ;
import io.audira.communication.service.FAQService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/faqs")
@RequiredArgsConstructor
public class FAQController {

    private final FAQService faqService;

    @GetMapping
    public ResponseEntity<List<FAQ>> getAllFAQs() {
        return ResponseEntity.ok(faqService.getAllFAQs());
    }

    @GetMapping("/active")
    public ResponseEntity<List<FAQ>> getActiveFAQs() {
        return ResponseEntity.ok(faqService.getActiveFAQs());
    }

    @GetMapping("/category/{category}")
    public ResponseEntity<List<FAQ>> getFAQsByCategory(@PathVariable FAQ.FAQCategory category) {
        return ResponseEntity.ok(faqService.getFAQsByCategory(category));
    }

    @GetMapping("/{id}")
    public ResponseEntity<FAQ> getFAQById(@PathVariable Long id) {
        return ResponseEntity.ok(faqService.getFAQById(id));
    }

    @PostMapping
    public ResponseEntity<FAQ> createFAQ(@RequestBody FAQ faq) {
        return ResponseEntity.status(HttpStatus.CREATED).body(faqService.createFAQ(faq));
    }

    @PutMapping("/{id}")
    public ResponseEntity<FAQ> updateFAQ(@PathVariable Long id, @RequestBody FAQ faqDetails) {
        return ResponseEntity.ok(faqService.updateFAQ(id, faqDetails));
    }

    @PutMapping("/{id}/toggle-active")
    public ResponseEntity<FAQ> toggleFAQActive(@PathVariable Long id) {
        return ResponseEntity.ok(faqService.toggleFAQActive(id));
    }

    @PostMapping("/{id}/view")
    public ResponseEntity<FAQ> incrementViewCount(@PathVariable Long id) {
        return ResponseEntity.ok(faqService.incrementViewCount(id));
    }

    @PostMapping("/{id}/helpful")
    public ResponseEntity<FAQ> markAsHelpful(@PathVariable Long id) {
        return ResponseEntity.ok(faqService.markAsHelpful(id));
    }

    @PostMapping("/{id}/not-helpful")
    public ResponseEntity<FAQ> markAsNotHelpful(@PathVariable Long id) {
        return ResponseEntity.ok(faqService.markAsNotHelpful(id));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteFAQ(@PathVariable Long id) {
        faqService.deleteFAQ(id);
        return ResponseEntity.noContent().build();
    }
}
