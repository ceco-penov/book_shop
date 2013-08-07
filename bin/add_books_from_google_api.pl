#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use JSON;

use Data::Dumper;

use DBI;

my $DB_CONN_STR = "dbi:SQLite:dbname=/home/ceci/src/perl/staj/book_shop/book_shop.db";

my $authors_file = $ARGV[0] || die "usage: $0 authors_file\n";

open(my $fh, "<", $authors_file) || die "cannot open file";
my @authors;
while(my $line = <$fh>) {
    chomp $line;
    $line =~ s/\s+/\+/g;
    push @authors , $line;
}

my $web_page = 'https://www.googleapis.com/books/v1/volumes?q=inauthor:'; 

my $ua = LWP::UserAgent->new;

for my $author (@authors) {

    my $books = get_books_by_author($author);
    save_books_in_db($books, $author);
}

sub get_books_by_author {
    my $author = shift;

    my $query =  $web_page . $author;

    my $resp = $ua->get($query);
    my $page = $resp->content();

    print "$page\n";

    my $info = from_json($page);
    return $info;
}

sub save_books_in_db {
    my $info = shift;
    my $a = shift;

    my $total_items = $info->{'totalItems'};
    my @items  = @{$info->{'items'}};

    my $i = 0;

    for my $book (@items) {

        $i++;
	
	    my $item = $book->{'volumeInfo'};
	    my $title = $item->{'title'};
	    my @authors = @{$item->{'authors'}};
	    my $publisher = $item->{'publisher'};
	    my $publish_date = $item->{'publishedDate'};
	    my $book_description = $item->{'description'};

	    my ($isbn_10, $isbn_13);
	    for my $id (@{$item->{'industryIdentifiers'}}) {
		    if ($id->{'type'} eq 'ISBN_10') {
			    $isbn_10 = $id->{'identifier'};
		    }

		    if ($id->{'type'} eq 'ISBN_13'){
			    $isbn_13 = $id->{'identifier'};
		    }
	    }

	    my $pages = $item ->{'pageCount'};
	    my @categories = @{$item->{'categories'}} if $item->{'categories'};
	    my $av_rating = $item->{'averageRating'};
	    my $ratings_count = $item->{'ratingsCount'};
	    my $small_thumbnail = $item->{'imageLinks'}{'smallThumbnail'};
	    my $thumbnail = $item->{'imageLinks'}{'thumbnail'};
	    my $view_status = $book->{'accessInfo'}{'accessViewStatus'};
	    my $web_reader_link = $book->{'accessInfo'}{'webReaderLink'};

	    print <<HERE;
----------------------------------------------------------------------
$title
----------------------------------------------------------------------
@authors
$publisher
$publish_date
$book_description
$isbn_10
$isbn_13
$pages
@categories
$av_rating
$ratings_count
$small_thumbnail
$thumbnail
$view_status
$web_reader_link

END [$a] [$i] ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++END

HERE

    my $price = sprintf("%.2f", 5 + int(rand(20)));
    my $qty   = 10 + int(rand(100));

    my $dbh = db_connect(); 	
    my $sth = $dbh->prepare('insert into BOOKS (TITLE, PRICE, QUANTITY, THUMBNAIL, SMALL_THUMBNAIL, WEB_READER_LINK, PUBLISHER, PUBLISH_DATE, PAGES, ISBN, DESCRIPTION) values (?,?,?,?,?,?,?,?,?,?,?)');
    my $rv = $sth->execute($title, $price, $qty, $thumbnail, $small_thumbnail, $web_reader_link, $publisher,$publish_date, $pages, $isbn_13, $book_description);
    my $book_id = $dbh->sqlite_last_insert_rowid();

    for my $author (@authors) {
        my $sth1 = $dbh->prepare('insert into AUTHORS (NAME) values (?)');
        my $sth2 = $dbh->prepare('insert into BOOK_AUTHORS (BOOK_ID,AUTHOR_ID) values (?,?)');

        $rv = $sth1->execute($author);
        my $auth_id = $dbh->sqlite_last_insert_rowid();
        $rv = $sth2->execute($book_id, $auth_id);
    }

    db_disconnect($dbh);

    }
}

sub db_connect {
	
	my $db_connection_str = $DB_CONN_STR;
	my $dbh = DBI->connect($db_connection_str) or die "error: [$DBI::errstr] [$!]";

	return $dbh;
}

sub db_disconnect {
	my $dbh = shift;

	$dbh->disconnect();
}
