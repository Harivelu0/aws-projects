package com.example.encryption_app.repository;

import com.example.encryption_app.model.OperationLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OperationLogRepository extends JpaRepository<OperationLog, Long> {
}
