package com.example.encryption.service;

import org.springframework.stereotype.Service;
import java.io.*;

@Service
public class EncryptionService {

    public File encryptFile(File inputFile, long key) throws IOException {
        return convertFile(inputFile, -key); // negative key for encryption
    }

    public File decryptFile(File inputFile, long key) throws IOException {
        return convertFile(inputFile, key);  // positive key for decryption
    }

    private File convertFile(File inputFile, long key) throws IOException {
        File outputFile = File.createTempFile("result_", ".txt");
        try (FileInputStream fin = new FileInputStream(inputFile);
             FileOutputStream fout = new FileOutputStream(outputFile)) {

            byte[] data = fin.readAllBytes();
            for (int i = 0; i < data.length; i++) {
                data[i] = (byte) (data[i] + key);
            }
            fout.write(data);
        }
        return outputFile;
    }
}
