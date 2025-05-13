-- Customer table
CREATE TABLE customer (
    cid NUMBER PRIMARY KEY,
    cname VARCHAR2(30),
    address VARCHAR2(50),
    city VARCHAR2(30),
    state CHAR(2)
);

-- Product table
CREATE TABLE product (
    pid NUMBER PRIMARY KEY,
    pname VARCHAR2(30),
    price NUMBER(9,2),
    inventory NUMBER
);

-- Shipment table
CREATE TABLE shipment (
    sid NUMBER PRIMARY KEY,
    cid NUMBER,
    shipdate DATE,
    FOREIGN KEY (cid) REFERENCES customer(cid)
);

-- ShippedProduct table
CREATE TABLE shippedproduct (
    sid NUMBER,
    pid NUMBER,
    amount NUMBER,
    PRIMARY KEY (sid, pid),
    FOREIGN KEY (sid) REFERENCES shipment(sid),
    FOREIGN KEY (pid) REFERENCES product(pid)
);