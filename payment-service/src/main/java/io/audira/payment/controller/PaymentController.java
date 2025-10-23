package io.audira.payment.controller;

import io.audira.payment.model.Payment;
import io.audira.payment.model.PaymentMethod;
import io.audira.payment.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping
    public ResponseEntity<Payment> createPayment(
            @RequestParam Long orderId,
            @RequestParam Long userId,
            @RequestParam Double amount,
            @RequestParam PaymentMethod paymentMethod) {
        return ResponseEntity.ok(paymentService.createPayment(orderId, userId, amount, paymentMethod));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Payment> getPaymentById(@PathVariable Long id) {
        return ResponseEntity.ok(paymentService.getPaymentById(id));
    }

    @GetMapping("/order/{orderId}")
    public ResponseEntity<Payment> getPaymentByOrder(@PathVariable Long orderId) {
        return ResponseEntity.ok(paymentService.getPaymentByOrderId(orderId));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Payment>> getUserPayments(@PathVariable Long userId) {
        return ResponseEntity.ok(paymentService.getUserPayments(userId));
    }

    @PostMapping("/{id}/process")
    public ResponseEntity<Payment> processPayment(
            @PathVariable Long id,
            @RequestParam String transactionId) {
        return ResponseEntity.ok(paymentService.processPayment(id, transactionId));
    }

    @PostMapping("/{id}/complete")
    public ResponseEntity<Payment> completePayment(@PathVariable Long id) {
        return ResponseEntity.ok(paymentService.completePayment(id));
    }

    @PostMapping("/{id}/fail")
    public ResponseEntity<Payment> failPayment(@PathVariable Long id) {
        return ResponseEntity.ok(paymentService.failPayment(id));
    }

    @PostMapping("/{id}/refund")
    public ResponseEntity<Payment> refundPayment(@PathVariable Long id) {
        return ResponseEntity.ok(paymentService.refundPayment(id));
    }
}
