package io.audira.commerce.service;

import io.audira.commerce.model.Payment;
import io.audira.commerce.model.PaymentMethod;
import io.audira.commerce.model.PaymentStatus;
import io.audira.commerce.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService {

    private final PaymentRepository paymentRepository;

    @Transactional
    public Payment createPayment(Long orderId, Long userId, Double amount, PaymentMethod paymentMethod) {
        BigDecimal amountDecimal = BigDecimal.valueOf(amount);
        log.info("Creating payment for order {} by user {} with amount {}", orderId, userId, amountDecimal);

        Payment payment = Payment.builder()
                .orderId(orderId)
                .userId(userId)
                .amount(amountDecimal)
                .paymentMethod(paymentMethod)
                .status(PaymentStatus.PENDING)
                .transactionId(generateTransactionId())
                .build();

        Payment savedPayment = paymentRepository.save(payment);
        log.info("Payment created with ID {} and transaction ID {}", savedPayment.getId(), savedPayment.getTransactionId());

        return savedPayment;
    }

    @Transactional
    public Payment processPayment(Long paymentId, String transactionId) {
        log.info("Processing payment with ID {} and transaction ID {}", paymentId, transactionId);

        Payment payment = getPaymentById(paymentId);

        if (payment.getStatus() != PaymentStatus.PENDING) {
            throw new IllegalStateException("Payment is not in PENDING status");
        }

        try {
            // Set the provided transaction ID
            payment.setTransactionId(transactionId);

            // Simulate payment gateway processing
            // In a real implementation, you would call the actual payment gateway API here
            boolean paymentSuccessful = simulatePaymentGateway(payment);

            if (paymentSuccessful) {
                payment.setStatus(PaymentStatus.PROCESSING);
                payment.setPaymentGatewayResponse("Payment being processed");
                log.info("Payment {} set to processing", paymentId);
            } else {
                payment.setStatus(PaymentStatus.FAILED);
                payment.setErrorMessage("Payment processing failed");
                log.error("Payment {} processing failed", paymentId);
            }
        } catch (Exception e) {
            payment.setStatus(PaymentStatus.FAILED);
            payment.setErrorMessage(e.getMessage());
            log.error("Error processing payment {}: {}", paymentId, e.getMessage());
        }

        return paymentRepository.save(payment);
    }

    @Transactional
    public Payment completePayment(Long paymentId) {
        log.info("Completing payment with ID {}", paymentId);

        Payment payment = getPaymentById(paymentId);

        if (payment.getStatus() != PaymentStatus.PROCESSING && payment.getStatus() != PaymentStatus.PENDING) {
            throw new IllegalStateException("Payment must be in PROCESSING or PENDING status to complete");
        }

        payment.setStatus(PaymentStatus.COMPLETED);
        payment.setPaymentGatewayResponse("Payment completed successfully");
        log.info("Payment {} completed successfully", paymentId);

        return paymentRepository.save(payment);
    }

    @Transactional
    public Payment failPayment(Long paymentId) {
        log.info("Failing payment with ID {}", paymentId);

        Payment payment = getPaymentById(paymentId);

        if (payment.getStatus() == PaymentStatus.COMPLETED || payment.getStatus() == PaymentStatus.REFUNDED) {
            throw new IllegalStateException("Cannot fail a completed or refunded payment");
        }

        payment.setStatus(PaymentStatus.FAILED);
        payment.setErrorMessage("Payment marked as failed");
        log.info("Payment {} marked as failed", paymentId);

        return paymentRepository.save(payment);
    }

    @Transactional
    public Payment refundPayment(Long paymentId) {
        log.info("Refunding payment with ID {}", paymentId);

        Payment payment = getPaymentById(paymentId);

        if (payment.getStatus() != PaymentStatus.COMPLETED) {
            throw new IllegalStateException("Payment must be in COMPLETED status to refund");
        }

        try {
            // Simulate refund processing
            // In a real implementation, you would call the actual payment gateway refund API here
            String refundTransactionId = generateTransactionId();
            payment.setStatus(PaymentStatus.REFUNDED);
            payment.setRefundTransactionId(refundTransactionId);
            payment.setPaymentGatewayResponse("Payment refunded successfully");
            log.info("Payment {} refunded successfully with refund transaction ID {}", paymentId, refundTransactionId);
        } catch (Exception e) {
            log.error("Error refunding payment {}: {}", paymentId, e.getMessage());
            throw new RuntimeException("Failed to refund payment: " + e.getMessage());
        }

        return paymentRepository.save(payment);
    }

    public Payment getPaymentById(Long id) {
        return paymentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Payment not found with ID: " + id));
    }

    public Payment getPaymentByTransactionId(String transactionId) {
        return paymentRepository.findByTransactionId(transactionId)
                .orElseThrow(() -> new RuntimeException("Payment not found with transaction ID: " + transactionId));
    }

    public List<Payment> getUserPayments(Long userId) {
        return paymentRepository.findByUserId(userId);
    }

    public Payment getPaymentByOrderId(Long orderId) {
        List<Payment> payments = paymentRepository.findByOrderId(orderId);
        if (payments.isEmpty()) {
            throw new RuntimeException("No payment found for order ID: " + orderId);
        }
        // Return the most recent payment for the order
        return payments.get(payments.size() - 1);
    }

    public List<Payment> getPaymentsByStatus(PaymentStatus status) {
        return paymentRepository.findByStatus(status);
    }

    @Transactional
    public Payment updatePaymentStatus(Long paymentId, PaymentStatus status, String gatewayResponse) {
        Payment payment = getPaymentById(paymentId);
        payment.setStatus(status);
        payment.setPaymentGatewayResponse(gatewayResponse);
        return paymentRepository.save(payment);
    }

    private String generateTransactionId() {
        return "TXN-" + UUID.randomUUID().toString().replace("-", "").substring(0, 16).toUpperCase();
    }

    private boolean simulatePaymentGateway(Payment payment) {
        // Simulate payment gateway processing
        // In a real implementation, this would make an API call to a payment gateway
        // For now, we'll simulate a successful payment
        return true;
    }
}
