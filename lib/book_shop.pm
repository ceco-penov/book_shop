package book_shop;

use Dancer ':syntax';

use DBI;

use Data::Dumper;
use Digest::SHA qw(sha1_hex);

use LWP::UserAgent;


our $VERSION = '0.1';

get '/' => sub {

	debug Dumper(session);

	if (session->{'LOGGED_IN'} and session->{'ROLE'} == 1) {
		return redirect '/admin';
	}

    template 'index';
};

get '/login' => sub {
	template 'login';
};

get '/logout' => sub {
	session->destroy;

	return redirect '/';
};

post '/login' => sub {
	my %params = params;
	
	my $dbh = db_connect();

	my $user = $params{'login_name'};
	my $pass = $params{'login_pass'};

	debug Dumper(\%params);

	my $sth = $dbh->prepare('select REAL_NAME,ROLE_ID from USERS where LOGIN_NAME = ? and LOGIN_PASS = ?');
	$sth->execute($user, sha1_hex($pass));

	my ($real_name, $role); 
	while(my $hr = $sth->fetchrow_hashref) {
		$real_name = $hr->{'REAL_NAME'};
		$role      = $hr->{'ROLE_ID'};
		last;
	}

	# admin
	if ($role == 1) {
		session 'REAL_NAME' => $real_name;
		session 'ROLE'	=> $role;
		session 'LOGGED_ID' => 1;
		return redirect '/admin';
	}
	
};

get '/admin' => sub {
	# not admin
	if (session->{'ROLE'} != 1) {
		return redirect '/';
	}

	template 'admin' => {
		REAL_NAME => session->{'REAL_NAME'},
	};
};

get '/admin/book/add' => sub {
	template 'book_add';
};

post '/admin/book/add' => sub {
    my %params = params;

    my $title = $params{'book_title'};
    my $price = $params{'book_price'};
    my $qty   = $params{'book_qty'};

    debug Dumper(request->headers), "\n";

    debug Dumper(\%params), "\n";

    #my $file = request->upload('book_cover');
    my $file  = upload('book_cover');

    debug Dumper($file), "\n";
    my $path = '/home/ceci/src/perl/staj/book_shop/public/book_covers/';
    my $basename = $file->basename;
    my $ext;
    if ($basename =~ /.*\.([^.]*)$/) {
        $ext = $1;
    }
    my $image_filename = sha1_hex(time . $basename . rand(1000)) . ".$ext";
    $file->copy_to($path . $image_filename);

    debug Dumper(\%params),$image_filename,"\n";

    my $dbh = db_connect();
    my $sth = $dbh->prepare('insert into BOOKS (TITLE, PRICE, QUANTITY, IMAGE_PATH) values (?,?,?,?)');
    my $rv = $sth->execute($title, $price, $qty, $image_filename);
    my $book_id = $dbh->sqlite_last_insert_rowid();

    debug "book_id=$book_id\n";

    for my $k (sort keys %params) {
        my $sth1 = $dbh->prepare('insert into AUTHORS (NAME) values (?)');
        my $sth2 = $dbh->prepare('insert into BOOK_AUTHORS (BOOK_ID,AUTHOR_ID) values (?,?)');

        if ($k =~ /author/) {
            $rv = $sth1->execute($params{$k});
            my $auth_id = $dbh->sqlite_last_insert_rowid();
            $rv = $sth2->execute($book_id, $auth_id);

            debug "book_id=$book_id | auth_id=$auth_id | author=$params{$k})\n";
        }
    }

    redirect '/admin';
};

post '/search' => sub {
	my %params = params;

	my $book_search_url = 'https://www.googleapis.com/books/v1/volumes?q=';
	#my $api_key = setting('google_api_key');

	my $search_params = 0;

	if ($params{'q'}) {
		my $q =  $params{'q'};
		$q =~ s/\s+/\+/g;
		$book_search_url .= $q;
		$search_params++;
	}

	if ($params{'q_author'}) {
		my $q_author =  $params{'q_author'};
		$q_author =~ s/\s+/\+/g;
		my $plus = '';
		$plus = '+' if $search_params;
		$book_search_url .= "$plus"."inauthor:$q_author";
		$search_params++;
	}

	if ($params{'q_title'}) {
		my $q_title =  $params{'q_title'};
		$q_title =~ s/\s+/\+/g;
		my $plus = '';
		$plus = '+' if $search_params;
		$book_search_url .= "$plus"."intitle:$q_title";
		$search_params++;
	}

	#$book_search_url .= "&key=$api_key" if $search_params;

	debug "book_search_url=$book_search_url\n";

	my $ua = LWP::UserAgent->new;
	my $resp = $ua->get($book_search_url);
	my $page = $resp->content();
	my $info = from_json($page);

	debug Dumper($info), "\n";

		
	template 'books_list' => {
		'books' => $info,
	};
};



sub db_connect {
	
	my $db_connection_str = setting('DB_CONN_STR');
	my $dbh = DBI->connect($db_connection_str) or die "error: [$DBI::errstr] [$!]";

	return $dbh;
}

sub db_disconnect {
	my $dbh = shift;

	$dbh->disconnect();
}

true;
