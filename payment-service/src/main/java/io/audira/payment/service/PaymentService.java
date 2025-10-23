package io.audira.payment.service;

import io.audira.payment.model.Payment;
import io.audira.payment.model.PaymentMethod;
import io.audira.payment.model.PaymentStatus;
import io.audira.payment.repository.PaymentRepository;
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
    public Payment createPayment(Long orderId, Long userId, BigDecimal amount, PaymentMethod paymentMethod) {
        log.info("Creating payment for order {} by user {} with amount {}", orderId, userId, amount);

        Payment payment = Payment.builder()
                .orderId(orderId)
                .userId(userId)
                .amount(amount)
                .paymentMethod(paymentMethod)
                .status(PaymentStatus.PENDING)
                .transactionId(generateTransactionId())
                .build();

        Payment savedPayment = paymentRepository.save(payment);
        log.info("Payment created with ID {} and transaction ID {}", savedPayment.getId(), savedPayment.getTransactionId());

        return savedPayment;
    }

    @Transactional
    public Payment processPayment(Long paymentId) {
        log.info("Processing payment with ID {}", paymentId);

        Payment payment = getPaymentById(paymentId);

        if (payment.getStatus() != PaymentStatus.PENDING) {
            throw new IllegalStateException("Payment is not in PENDING status");
        }

        try {
            // Simulate payment gateway processing
            // In a real implementation, you would call the actual payment gateway API here
            boolean paymentSuccessful = simulatePaymentGateway(payment);

            if (paymentSuccessful) {
                payment.setStatus(PaymentStatus.COMPLETED);
                payment.setPaymentGatewayResponse("Payment processed successfully");
                log.info("Payment {} processed successfully", paymentId);
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

    public List<Payment> getPaymentsByUserId(Long userId) {
        return paymentRepository.findByUserId(userId);
    }

    public List<Payment> getPaymentsByOrderId(Long orderId) {
        return paymentRepository.findByOrderId(orderId);
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
