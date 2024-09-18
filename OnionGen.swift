import Foundation
import CryptoKit

// Функция для преобразования Ed25519-ключей в onion-адрес v3
func generateOnionAddress(from publicKey: Data) -> String? {
    // SHA-3 (256) хэширование открытого ключа
    let publicKeyHash = SHA3(variant: .sha256).calculate(for: publicKey.bytes)
    
    // Берем первые 32 байта и добавляем контрольную сумму + версия
    let checksumData = Data(SHA3(variant: .sha256).calculate(for: publicKeyHash + [0x03] + [0x03]))
    
    // Финальный onion-адрес состоит из: [публичный ключ (32 байта) + контрольная сумма (2 байта) + версия (1 байт)]
    let onionAddressData = publicKey + checksumData.prefix(2) + [0x03]
    
    // Base32 кодирование и добавление доменной части .onion
    let onionAddress = onionAddressData.base32EncodedString.lowercased() + ".onion"
    
    return onionAddress
}

// Функция для генерации случайных Ed25519-ключей и проверки onion-адреса
func generateOnionAddress(withPrefix prefix: String) {
    while true {
        // Генерация ключей Ed25519
        let privateKey = Curve25519.Signing.PrivateKey()
        let publicKey = privateKey.publicKey.rawRepresentation
        
        // Генерация onion-адреса
        if let onionAddress = generateOnionAddress(from: publicKey), onionAddress.hasPrefix(prefix.lowercased()) {
            print("Найден подходящий onion-адрес: \(onionAddress)")
            break
        }
    }
}

let targetPrefix = "adiom" // Префикс, который нужно найти
generateOnionAddress(withPrefix: targetPrefix)
