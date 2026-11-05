CREATE DATABASE IF NOT EXISTS fintrust_db;

SHOW DATABASES;
USE fintrust_db;

SELECT DATABASE();

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    date_registered DATETIME DEFAULT CURRENT_TIMESTAMP
);

DESCRIBE customers;
SHOW TABLES;

CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    account_type VARCHAR(30) NOT NULL,
    currency CHAR(3) DEFAULT 'NGN',
    balance DECIMAL(15,2) DEFAULT 0.00,
    account_status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_accounts_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

DESCRIBE accounts;

SHOW CREATE TABLE accounts;

SHOW CREATE TABLE accounts;

SELECT
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'fintrust_db'
AND TABLE_NAME = 'accounts'
AND REFERENCED_TABLE_NAME IS NOT NULL;

CREATE TABLE transaction_types (
    transaction_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(30) NOT NULL UNIQUE
);

INSERT INTO transaction_types (type_name)
VALUES
('Deposit'),
('Withdrawal'),
('Transfer');

SELECT * FROM transaction_types;

CREATE TABLE transaction_statuses (
    transaction_status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(30) NOT NULL UNIQUE
);

INSERT INTO transaction_statuses (status_name)
VALUES
('Pending'),
('Successful'),
('Failed');

SELECT * FROM transaction_statuses;

CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    reference VARCHAR(50) NOT NULL UNIQUE,
    source_account_id INT NULL,
    destination_account_id INT NULL,
    transaction_type_id INT NOT NULL,
    transaction_status_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    description VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_transactions_source
        FOREIGN KEY (source_account_id)
        REFERENCES accounts(account_id),

    CONSTRAINT fk_transactions_destination
        FOREIGN KEY (destination_account_id)
        REFERENCES accounts(account_id),

    CONSTRAINT fk_transactions_type
        FOREIGN KEY (transaction_type_id)
        REFERENCES transaction_types(transaction_type_id),

    CONSTRAINT fk_transactions_status
        FOREIGN KEY (transaction_status_id)
        REFERENCES transaction_statuses(transaction_status_id),

    CONSTRAINT chk_transaction_amount
        CHECK (amount > 0),

    CONSTRAINT chk_transaction_accounts
        CHECK (
            source_account_id IS NOT NULL
            OR destination_account_id IS NOT NULL
        )
);
DESCRIBE transactions;
SHOW tables;

CREATE TABLE audit_logs (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NULL,
    action VARCHAR(100) NOT NULL,
    entity_name VARCHAR(50) NOT NULL,
    entity_id INT,
    details TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);
SHOW TABLES;

INSERT INTO customers
(first_name, last_name, email, phone_number)
VALUES
('Amara', 'Okafor', 'amara@example.com', '08012345678'),
('David', 'Adeyemi', 'david@example.com', '08023456789'),
('Fatima', 'Bello', 'fatima@example.com', '08034567890');

SELECT * FROM customers;

SELECT customer_id, first_name, last_name
FROM customers;

INSERT INTO accounts
(customer_id, account_number, account_type, currency, balance)
VALUES
(1, 'FT100001', 'Savings', 'NGN', 150000.00),
(1, 'FT100002', 'Current', 'NGN', 50000.00),
(2, 'FT100003', 'Savings', 'NGN', 200000.00),
(3, 'FT100004', 'Savings', 'NGN', 100000.00);


SELECT * FROM transaction_types;

SELECT * FROM transaction_statuses;

INSERT INTO transactions
(reference, source_account_id, destination_account_id,
 transaction_type_id, transaction_status_id, amount, description)
VALUES
('FT-TRX-001', NULL, 1, 1, 2, 20000.00, 'Customer deposit'),
('FT-TRX-002', 3, NULL, 2, 2, 5000.00, 'Cash withdrawal'),
('FT-TRX-003', 1, 4, 3, 2, 10000.00, 'Transfer to another customer');

SELECT * FROM transactions;

START TRANSACTION;

UPDATE accounts
SET balance = balance + 20000
WHERE account_id = 1;

UPDATE accounts
SET balance = balance - 5000
WHERE account_id = 3;

UPDATE accounts
SET balance = balance - 10000
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 10000
WHERE account_id = 4;

COMMIT;

SELECT account_id, account_number, balance
FROM accounts;

INSERT INTO audit_logs
(customer_id, action, entity_name, entity_id, details)
VALUES
(1, 'ACCOUNT_CREATED', 'ACCOUNTS', 1, 'Amara opened a savings account'),
(1, 'ACCOUNT_CREATED', 'ACCOUNTS', 2, 'Amara opened a current account'),
(2, 'ACCOUNT_CREATED', 'ACCOUNTS', 3, 'David opened a savings account'),
(3, 'ACCOUNT_CREATED', 'ACCOUNTS', 4, 'Fatima opened a savings account'),
(1, 'DEPOSIT_MADE', 'TRANSACTIONS', 1, 'Amara deposited 20000 NGN'),
(2, 'WITHDRAWAL_MADE', 'TRANSACTIONS', 2, 'David withdrew 5000 NGN'),
(1, 'TRANSFER_MADE', 'TRANSACTIONS', 3, 'Amara transferred 10000 NGN to Fatima');

SELECT * FROM audit_logs;

SELECT
    t.transaction_id,
    t.reference,
    t.transaction_type_id,
    tt.type_name,
    t.source_account_id,
    t.destination_account_id,
    t.amount,
    ts.status_name,
    t.created_at
FROM transactions t
JOIN transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id
JOIN transaction_statuses ts
    ON t.transaction_status_id = ts.transaction_status_id
ORDER BY t.transaction_id;

SELECT
    customer_id,
    first_name,
    last_name,
    email,
    phone_number,
    date_registered
FROM customers
ORDER BY customer_id;

DESCRIBE customers;

DESCRIBE accounts;

DESCRIBE transaction_types;

DESCRIBE transaction_statuses;

DESCRIBE audit_logs;

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'fintrust_db'
AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;