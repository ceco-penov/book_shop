function add_to_cart(book_id) {
	var book_qty = $('#books_qty').val();

	$.ajax({
  		type: "GET",
  		url: "/ajax/add_to_cart",
		data: {book_id: book_id, book_qty: book_qty},
		dataType: 'json',
  		success: function( msg ) {
  			$('#cart').html('Cart <span class="glyphicon glyphicon-shopping-cart"></span> <span class="badge" id="cart_badge">'+ msg.books_in_cart +'</span>');
			$('#ajax_response').html('<div class="alert alert-success"><button type="button" class="close" data-dismiss="alert">×</button> '+ msg.err_msg +'</div>');
  		}
	});
};

function update_cart(){
	var grand_total = 0.00;
	var books = new Array;

	$('#cart_data tr').each(function() {
		var book_id = $(this).attr("id");

		if (book_id) { 
			var select_val = $('#books_qty_'+book_id).val();
			var price_val  = $('#price_'+book_id).html();
			var total_val  = $('#total_'+book_id).html();

			total_val = select_val * price_val;
			grand_total += total_val;
			$('#total_'+book_id).html(total_val);

			var book = {
				"book_id" : book_id,
				"qty" : select_val,
				"price" : price_val,
				"total" : total_val
			};
			books.push(book);

			// alert("select_val="+select_val+"|price_val="+price_val+"|total_val="+total_val);
		}else {
			return;
		}
	});

	var mydata = JSON.stringify(books);
	$('#grand_total').html(grand_total + ' $');

	$.ajax({
		type: "GET",
		url: "/ajax/update_cart",
		data: {cart: mydata},
		dataType: 'json',
		success: function( msg ) {
			//alert("DONE!");	
		}
	});
};
