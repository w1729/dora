use dep::std::hash::poseidon::bn254::{hash_1, hash_2, hash_3};

/// A module for handling cryptographic operations
mod crypto {
    use super::*;

    /// Derives the public key from the private key using Poseidon hash
    pub fn derive_public_key(private_key: Field) -> Field {
        hash_1([private_key])
    }

    /// Generates a signature component using HMAC-like construction
    pub fn generate_signature_component(private_key: Field, message_hash: Field, nonce: Field) -> Field {
        let inner_hash = hash_3([private_key, message_hash, nonce]);
        hash_2([private_key, inner_hash])
    }
}

/// Main function for generating a signature
fn main(
    private_key: Field,
    public_key: pub Field,
    message_hash: pub Field
) -> pub [Field; 2] {
    // Verify that the public key matches the derived key
    assert(public_key == crypto::derive_public_key(private_key));

    // Generate the two signature components using nonces 0 and 1
    let signature_component_1 = crypto::generate_signature_component(private_key, message_hash, 0);
    let signature_component_2 = crypto::generate_signature_component(private_key, message_hash, 1);

    // Return the signature as a tuple of two field elements
    [signature_component_1, signature_component_2]
}