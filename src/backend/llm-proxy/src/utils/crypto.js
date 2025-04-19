const crypto = require('crypto');
const config = require('../config');
const logger = require('./logger');

/**
 * Decrypt data using AES-GCM
 * @param {string} ciphertext - Base64 encoded ciphertext
 * @param {string} nonce - Base64 encoded nonce/IV
 * @returns {string} - Decrypted data as string
 */
function decrypt(ciphertext, nonce) {
  try {
    // This is a server-side simulation of WebCrypto AES-GCM decryption
    // In the actual implementation, the key should be derived from a key held server-side
    // that was used to re-encrypt the data (after it was decrypted client-side)
    // For this simulation, we're using a fixed key for demonstration purposes only
    
    // WARNING: In a real implementation, never use a fixed key like this!
    // This is just for demonstration and would be replaced with proper key management
    const key = crypto.scryptSync(
      'this-would-be-a-secure-server-side-key', 
      'salt', 
      32 // 256 bits
    );
    
    const iv = Buffer.from(nonce, 'base64');
    const encryptedData = Buffer.from(ciphertext, 'base64');
    
    // AES-GCM authenticated encryption
    // In GCM mode, the last 16 bytes are the auth tag
    const authTag = encryptedData.slice(encryptedData.length - 16);
    const encryptedContent = encryptedData.slice(0, encryptedData.length - 16);
    
    const decipher = crypto.createDecipheriv(
      'aes-256-gcm', 
      key, 
      iv
    );
    
    decipher.setAuthTag(authTag);
    
    let decrypted = decipher.update(encryptedContent, null, 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  } catch (error) {
    logger.error('Decryption error:', error);
    throw new Error('Failed to decrypt API key');
  }
}

module.exports = {
  decrypt,
};
