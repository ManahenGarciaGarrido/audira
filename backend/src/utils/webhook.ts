import crypto from 'crypto';

/**
 * Verify webhook signature using HMAC SHA-256
 * @param payload - The raw request body as a string
 * @param signature - The signature from the webhook header
 * @param secret - The webhook secret key
 * @returns true if signature is valid, false otherwise
 */
export const verifyWebhookSignature = (
  payload: string,
  signature: string,
  secret: string
): boolean => {
  try {
    const hmac = crypto.createHmac('sha256', secret);
    hmac.update(payload);
    const computedSignature = hmac.digest('hex');

    // Use timing-safe comparison to prevent timing attacks
    return crypto.timingSafeEqual(
      Buffer.from(signature),
      Buffer.from(computedSignature)
    );
  } catch (error) {
    return false;
  }
};
