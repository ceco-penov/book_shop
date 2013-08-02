package book_shop;

use Dancer ':syntax';

use DBI;

use Data::Dumper;
use Digest::SHA qw(sha1_hex);

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
