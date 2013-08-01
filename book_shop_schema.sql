CREATE TABLE USERS (
		ID integer primary key autoincrement,
		LOGIN_NAME text,
		LOGIN_PASS text,
		REAL_NAME  text,
		PHONE text,
		ROLE_ID integer
);

CREATE TABLE ROLES (
		ID integer primary key autoincrement,
		NAME text
);

CREATE TABLE AUTHORS (
		ID integer primary key autoincrement,
		NAME text
);

CREATE TABLE BOOKS (
		ID integer primary key autoincrement,
		TITLE text,
		PRICE real,
		QUANTITY integer,
		IMAGE_PATH text
);

CREATE TABLE BOOK_AUTHORS (
		ID integer primary key autoincrement,
		BOOK_ID integer,
		AUTHOR_ID integer
);

CREATE TABLE ORDERS (
		ID integer primary key autoincrement,
		DATE_TIME integer,
		TOTAL_PRICE real,
		USER_ID integer,
		ANON_USER_REAL_NAME text,
		ANON_USER_PHONE text,
		ANON_USER_ADDRESS text,
		DONE integer
);

CREATE TABLE ORDERED_BOOKS (
		ID integer primary key autoincrement,
		ORDER_ID integer,
		BOOK_ID integer,
		QUANTITY integer,
		PRICE real,
		TOTAL_PRICE real
);
