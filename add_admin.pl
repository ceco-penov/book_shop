#!/usr/bin/perl

use strict;
use warnings;

use DBI;
use Digest::SHA qw(sha1_hex);

my $DBNAME = 'book_shop.db';

my $TEST_ADM = 'admin';
my $TEST_PASS = '123';
my $TEST_REAL_NAME = 'Web System Administrator';

my $DBH = DBI->connect("dbi:SQLite:dbname=$DBNAME");

my $sth = $DBH->prepare('insert into ROLES (ID,NAME) values (?,?)');
$sth->execute(1, 'Admin');
$sth->execute(2, 'Customer');


my $sha1_pass = sha1_hex($TEST_PASS);
$sth = $DBH->prepare('insert into USERS (LOGIN_NAME,LOGIN_PASS,REAL_NAME,ROLE_ID) values (?,?,?,?)');
$sth->execute($TEST_ADM, $sha1_pass, $TEST_REAL_NAME, 1);

$DBH->disconnect();
