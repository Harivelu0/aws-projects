package com.example.encryption_app.controller;

import com.example.encryption_app.model.OperationLog;
import com.example.encryption_app.repository.OperationLogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;

@Controller
public class EncryptionController {

    @Autowired
    private OperationLogRepository logRepository;

    @GetMapping("/")
    public String home() {
        return "index"; // your index.html in templates
    }

    @PostMapping("/process")
    public String processFile(@RequestParam("file") MultipartFile file,
                              @RequestParam("key") long key,
                              @RequestParam("operation") String operation,
                              Model model) {

        OperationLog log = new OperationLog();
        try {
            if (file.isEmpty()) {
                model.addAttribute("message", "Please select a file!");
                return "index";
            }

            String originalFileName = file.getOriginalFilename();
            log.setFileName(originalFileName);
            log.setOperation(operation);

            // Create temp file to work with
            File tempFile = File.createTempFile("upload-", originalFileName);
            file.transferTo(tempFile);

            // Create processed file
            File processedFile = File.createTempFile("processed-", originalFileName);
            encryptDecryptFile(tempFile, processedFile, key, operation);

            model.addAttribute("message", "Operation successful!");
            model.addAttribute("downloadFile", processedFile.getName());

            log.setStatus("SUCCESS");

        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("message", "Error: " + e.getMessage());
            log.setStatus("FAILURE");
        } finally {
            logRepository.save(log); // Save log to RDS
        }

        return "index";
    }

    // Encryption/Decryption logic
    private void encryptDecryptFile(File inputFile, File outputFile, long key, String operation) throws IOException {
        try (FileInputStream fin = new FileInputStream(inputFile);
             FileOutputStream fout = new FileOutputStream(outputFile)) {

            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = fin.read(buffer)) != -1) {
                for (int i = 0; i < bytesRead; i++) {
                    if (operation.equalsIgnoreCase("encrypt")) {
                        buffer[i] = (byte) (buffer[i] + key);
                    } else {
                        buffer[i] = (byte) (buffer[i] - key);
                    }
                }
                fout.write(buffer, 0, bytesRead);
            }
        }
    }
}
