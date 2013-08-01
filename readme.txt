DB SCHEMA
DB CONNECT
INSERT INTO ROLES ADMIN,CUSTOMER
INSERT INTO USERS WITH ROLE ADMIN, SHA1 HASH OF LOGIN_PASS
HOMEPAGE -> LOGIN LINK
/login

IF USER IS ADMIN redirect to /admin

admin homepage-
add_author ->  /admin/add_author
	name
add_books  -> /admin/add_book form
	save image file
-----------------------------------------------------------

HOMEPAGE
search bar
books list

-----------------------------------------------------------
add_to_cart - store in session
checkout - name, address, phone

/admin
/admin/author/add
/admin/authors/list -> alphabeticaly
/admin/book/add
/admin/book/edit
/admin/books/list  -> alphabeticaly
/admin/orders/list -> filter: newest first, pagination, 
/admin/order/view
/admin/order/finish

/add_to_cart -> ajax zapisva v sesiqta
/checkout -> zapisva v orders v dbase
