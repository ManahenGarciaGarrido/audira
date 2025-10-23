package io.audira.payment.webhook;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/payments/webhook")
@RequiredArgsConstructor
public class WebhookController {

    @PostMapping("/stripe")
    public ResponseEntity<String> handleStripeWebhook(@RequestBody Map<String, Object> payload) {
        log.info("Received Stripe webhook: {}", payload);
        // TODO: Implementar procesamiento de webhook de Stripe
        return ResponseEntity.ok("Webhook received");
    }

    @PostMapping("/paypal")
    public ResponseEntity<String> handlePayPalWebhook(@RequestBody Map<String, Object> payload) {
        log.info("Received PayPal webhook: {}", payload);
        // TODO: Implementar procesamiento de webhook de PayPal
        return ResponseEntity.ok("Webhook received");
    }
}
