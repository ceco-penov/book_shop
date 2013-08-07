#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use JSON;

use Data::Dumper;

my $web_page = 'https://www.googleapis.com/books/v1/volumes?q=brazilian%20juijitsu+inauthor:marcelo%20garcia&key=AIzaSyDrIo9B5cw8eJicCwMfExHxpDaK_agAlhs'; 

my $ua = LWP::UserAgent->new;

my $resp = $ua->get($web_page);

my $page = $resp->content();

print "$page\n";

my $info = from_json($page); 


my $total_items = $info->{'totalItems'};
my @items  = @{$info->{'items'}};

for my $book (@items) {
	
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
	my $small_image = $item->{'imageLinks'}{'smallThumbnail'};
	my $larger_image = $item->{'imageLinks'}{'thumbnail'};
	my $view_status = $book->{'accessInfo'}{'accessViewStatus'};
	my $web_reader_link = $book->{'accessInfo'}{'webReaderLink'};

	print <<HERE;

$title
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
$small_image
$larger_image
$view_status
$web_reader_link

HERE
	

}
