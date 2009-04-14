#!/usr/bin/perl

use strict;

use lib 'extlib', 'lib', '../lib', 'plugins/MTBooter/lib';

use MT;
use MTBooter::Data;

use Getopt::Long;

my $mt = MT->new() or die "No MT object " . MT->errstr();
$mt->run_callbacks('init_app', $mt);

#how does one get incoming params? using Getopt::Long
my $blog_id = 1;
my $entries= 0;
my $blogs= 0;
my $years = 5;
my $users = 0;
my $usecats = 0;
my $addpings = 0;
my $assets = 0;
my $addcats = 0;
my $addassets = 0;
my $addcf = 0;
my $addusers = 0;

my $result = GetOptions("blog_id=i" => \$blog_id,
                        "entries=i" => \$entries,
                        "blogs=i"   => \$blogs,
                        "years=i"   => \$years,
                        "users=i"   => \$users,
                        "assets=i"  => \$assets,
                        "addcats"   => \$addcats,
                        "addpings"  => \$addpings,
                        "addassets" => \$addassets,
                        "addcf"     => \$addcf,
                        "addusers"     => \$addusers,
);

if ($addcf) {
  print "Now adding custom fields to blog with blog_id $blog_id\n";
  add_custom_fields_to_blog($blog_id);
}

if ($entries) {
  print "Now going to create $entries entries spanning $years years in blog_id $blog_id\n";

  create_entries($blog_id, "Entry", $entries, $years, 5, 0, 0, 1, 0, $addcf ? 1 : 0);
}

if ($blogs) {
  print "Now going to create $blogs blogs\n";

  create_blogs($blogs, 1);
}

if ($addcats) {
  print "Now adding categories to entries in blog_id $blog_id\n";

  add_categories_to_entries($blog_id);
}

if ($addpings) {
  print "Now adding pings to entries in blog_id $blog_id\n";

  add_trackbacks_to_entries($blog_id);
}

if ($addassets) {
  print "Now adding assets to blog with blog_id $blog_id\n";

  add_assets_to_blog($blog_id, $assets);
}

if ($addusers) {
  print "Now adding users!\n";

  create_users($users);
}

#example of usage:

# perl tools/mtbooter-command.pl --blog_id 1 --entries 100 --years 5 --addcats --addpings
