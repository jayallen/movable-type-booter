
package MTBooter::Data;

use base qw(Exporter Class::ErrorHandler);
use vars qw(@EXPORT);
use strict;
use warnings;

use MT;
use MTBooter::Data::Random;
use MT::Permission;

@EXPORT = qw( create_category create_entries create_demo create_blog create_categories add_forums create_users create_user_set_for_blog
add_categories_to_entries add_trackbacks_to_entries add_trackback_to_entry add_assets_to_blog create_blogs create_custom_fields_for_blog add_custom_fields_to_blog);

our $g_DefaultPassword = "test";
our $g_UserPrefix = "testuser"; #Used in create_user_set. Here until textbox is added to input form;

sub add_category_to_entry {
    #my $class = shift;
    my ($blog_id, $entry_id, $category_id, $is_primary) = @_;

    require MT::Placement;

    my $place = MT::Placement->new;

    $place->entry_id($entry_id);
    $place->blog_id($blog_id);
    $place->category_id($category_id);
    $place->is_primary($is_primary);
    #$place->save or return $class->error ("Error saving placement: " . $place->errstr);
    $place->save
      or die $place->errstr;
}

sub create_category {
    #my $class = shift;
    my ($blog_id, $parent_cat_id) = @_;

    require MT::Category;
    my $cat = MT::Category->new;

    $cat->blog_id($blog_id);
    $cat->label('temp');
    #$cat->save or return $class->errstr ("Error saving category: " . $cat->errstr);
    $cat->save
      or die $cat->errstr;

    my $cat_id = $cat->id;

    if ($parent_cat_id) {
        #make the category a sub-category
        my $parent_cat = MT::Category->load($parent_cat_id);

        $cat->parent($parent_cat_id);

        #determine if parent category is a sub-category
        if ( $parent_cat->parent_category ) {
            $cat->label("Sub-sub-category $cat_id");
        }
        else {
            $cat->label("Sub-category $cat_id");
        }
    }
    else {
        $cat->label("Category $cat_id");
    }

    #$cat->save or return $class->errstr ("Error saving category: " . $cat->errstr);
    $cat->save
      or die $cat->errstr;

    return $cat->id;
}

sub create_entries {

    #how can this be adapted to also create Pages? is it just a flag of MT::Entries?
    # my $class = shift;
    my ($blog_id, $EntryType, $NumberEntries, $NumberYears, $NumberTags, $RateEntries, $RatingType, $AddComments, $AddCategories, $AddCFData) = @_;

    $EntryType = lc $EntryType;

    my $entry_class = MT->version_number < 4 ? 'MT::Entry' : MT->model($EntryType);

    my $TotalComments = 0;

    #actually create the entries
    for ( 1..$NumberEntries ) {
        my $entry = $entry_class->new;
        #my $entry = MT::Entry->new;

        $entry->blog_id($blog_id);
        $entry->status( MT::Entry::RELEASE() );

        #let's randomize the author
        my $RandomUser = random_user();
        my $author_id  = $RandomUser->id;

        $entry->author_id($author_id);

        if ($NumberTags) {
            my @tags = get_random_tags($NumberTags);
            $entry->tags(@tags);
        }

        my $random_date = random_date($NumberYears);
        my $authored_on = MT->version_number < 4 ? 'created_on' : 'authored_on';
        $entry->$authored_on($random_date);

        #make sure entry can be commented on
        $entry->allow_comments(1);
        $entry->allow_pings(1);

        $entry->save
          or die $entry->errstr;

        my $entry_id = $entry->id;

        #now assign entry rating, if user has specified that
        if ($RateEntries) {
            my $plugin = MT::Plugin::MTBooter->instance;

        #so all ratings will appear as if made by the logged in user? let's try randomizing that--not to mention the number of users who rated the entry
        #maybe try randomizing number of times the entry has been rated, and accept that there will be some redundant ratings (which will go down as the number of authors increases)
            my $NumberTimesRated = random_number_times(10);

            for ( my $j = 0 ; $j < $NumberTimesRated ; $j++ ) {
                my $RandomUser = random_user();

                #randomize rating
                my $RandomRating = random_rating($RatingType);
                $entry->set_score( $plugin->key, $RandomUser, $RandomRating,
                    1 );
            }
        }

        # add some comments if user has specified that
        if ($AddComments) {
            my $NumberComments = random_number_times(5);

            for ( my $k = 0 ; $k < $NumberComments ; $k++ ) {
                my $RandomUser = random_user();

                my $comment_author_id   = $RandomUser->id;
                my $author_display_name = $RandomUser->nickname;

                #create random comment
                random_comment( $blog_id, $entry_id, $comment_author_id,
                    $author_display_name, "");
            }
        }

        #add category to some entries, if AddCategories is set
        if ($AddCategories) {
          add_categories_to_entry($blog_id, $entry_id);
        }

        #add custom field data to entries, if AddCFData is set
        if ($AddCFData) {
          add_cf_data_to_entry( $blog_id, $entry );
        }

        my $title      = "";
        my $entry_body = "";

        require Acme::Wabby;

        #Acme::Wabby::import(qw(:errors));

        #get seed text from settings
        my $plugin   = MT::Plugin::MTBooter->instance;
        my $config   = $plugin->get_config_hash();
        my $seedtext = $config->{ SeedText };

        my $wabby = Acme::Wabby->new(
            min_len             => 40,
            max_len             => 200,
            punctuation         => [ ".", "?", "!", "..." ],
            case_sensitive      => 0,
            hash_file           => "./wabbyhash.dat",
            list_file           => "./wabbylist.dat",
            autosave_on_destroy => 0,
            max_attempts        => 1000
        );

        $wabby->add($seedtext);

        $entry_body = $wabby->spew;

        $wabby = Acme::Wabby->new(
            min_len             => 2,
            max_len             => 6,
            punctuation         => [ ".", "?", "!", "..." ],
            case_sensitive      => 0,
            hash_file           => "./wabbyhash.dat",
            list_file           => "./wabbylist.dat",
            autosave_on_destroy => 0,
            max_attempts        => 1000
        );

        $wabby->add($seedtext);

        $title = $wabby->spew;

        $entry->title($title);
        $entry->text($entry_body);

        $entry->save
          or die $entry->errstr;

        print STDERR "Alert! Entry $entry_id has been created!\n";
    }

    return 1;
}

sub add_categories_to_entry {
  my $blog_id = shift;
  my $entry_id = shift;

  my $NumberCategories = random_number_times(3);

  for ( my $m = 0 ; $m < $NumberCategories ; $m++ ) {

    #add random number of categories--zero
    my $Category = random_category($blog_id);

    # No categories yet? Create some!
    if ( !$Category ) {
        create_categories($blog_id);
        $Category = random_category($blog_id);
    }

    if ($Category) {
            my $category_id = $Category->id;

            #if $m is zero (first iteration) than that category is primary
            my $is_primary = 0;

            if ( $m == 0 ) {
              $is_primary = 1;
            } else {
              $is_primary = 0;
            }

            #then add it to the entry
            add_category_to_entry( $blog_id, $entry_id, $category_id, $is_primary );
    }
  }
}

sub create_demo {

    my $app = shift;

    my $plugin = MT::Plugin::MTBooter->instance;

    #determine what template sets are available

    my $sets = $app->registry("template_sets");

    #iterate through the array and get the keys, and the label

    #how do you iterate through an array in perl again?

    #while( my ($k, $v) = each %$sets ) {

    #  print "key: $k, value: $v.\n";

    #}

    #for my $set ($sets) {

    # $template_set_name = $set[''];

    #}

    #create the demo blogs -- hard-coded and assuming MTCS is installed, which is very wrong indeed

    create_blog( $app, "Classic Blog",
        "This is a classic Movable Type blog like the one in MT4.",
        "mt_blog", 1, 1 );

    create_blog(
        $app,
        "Community Blog",
        "This is a blog with community features like favorites and userpics.",
        'mt_community_blog', 1, 1
    );

    create_blog( $app, "Forums Blog",
        "This is a forums blog for discussing stuff.",
        'mt_community_forum', 1, 1 );

    my $tmpl = $plugin->load_tmpl('create_demo_confirm.tmpl');

    my $param;

    $param->{ 'CreateDemoSuccess' } =
      "Your demo blogs have been created successfully.";

    return $app->build_page( $tmpl, $param );

}

sub create_blog {
    my ($BlogName, $BlogDescription, $blog_template, $create_entries, $create_categories) = @_;

    require MT::Blog;

    my $blog = MT::Blog->new;
    $blog->name($BlogName);
    $blog->description($BlogDescription);
    $blog->save
      or die $blog->errstr;

    $blog->create_default_templates($blog_template);

    my $blog_id = $blog->id;

    #need to set publishing paths in an intelligent way

    #like getting the host of the machine

    #then assume that blog will be published to blogs at html root

    my $DefaultSiteURL = MT->config('DefaultSiteURL');

    my $DefaultSitePath = MT->config('DefaultSitePath');

    if ( !$DefaultSiteURL ) { $DefaultSiteURL = "http://localhost/blogs/" }

    if ( !$DefaultSitePath ) { $DefaultSitePath = "/blogs" }

    $blog->site_url( $DefaultSiteURL . "/blog-" . $blog_id );

    $blog->site_path( $DefaultSitePath . "/blog-" . $blog_id );

    $blog->save
      or die $blog->errstr;

    #create categories for that blog

    if ($create_categories) {
        create_categories($blog_id);
    }

    #create entries for that blog

    if ($create_entries) {
        create_entries( $blog_id, "Entry", 10, 1, 5, 0, 0, 1, 20 );
    }

    print STDERR "Alert! Blog \"$BlogName\" has been created!\n";

    return $blog_id;
}

sub create_categories {
    #my $class = shift;
    my $blog_id = shift;

    #always create five top-level categories

    my $number_categories = 5;

    for ( my $i = 0 ; $i < $number_categories ; $i++ ) {

        my $cat_id = create_category( $blog_id, "" );

        #create sub-categories for that category

        my $number_sub_categories = random_number_times(3);

        for ( my $j = 0 ; $j < $number_sub_categories ; $j++ ) {

            my $sub_cat_id = create_category( $blog_id, $cat_id );

            #create sub-sub-categories for that sub-category

            my $number_subsub_categories = random_number_times(2);

            for ( my $k = 0 ; $k < $number_subsub_categories ; $k++ ) {

                create_category( $blog_id, $sub_cat_id );

            }

        }

    }

    return;

}

sub add_forums {

    my $blog_id = shift;

    my $entry_id = shift;

  #add just a single category for now - this code is tailored to the MTCS forums

    my $CategoryGroup = random_top_level_category($blog_id);

    if ($CategoryGroup) {

        my $category_group_id = $CategoryGroup->id;

        #pick a random category within that category group

        my $Category = random_category($category_group_id);

        if ($Category) {

            my $category_id = $Category->id;

            #then add it to the entry

            add_category_to_entry( $blog_id, $entry_id, $category_id );

        }

    }

}

sub create_users {

    my $NumberUsers = shift;

    my $blog_id = shift;

    my @Users;

    my $count = 0;

    #my @UsernamesUsed;

    #get all roles in system

    my @Roles;
    if (MT->version_number >= 4) {
        require MT::Role;
        @Roles = MT::Role->load();
    }

    while ( $NumberUsers != $count ) {

        my $DisplayName = create_user_name();

        #derive their nickname from their name

        my $username = createUsername($DisplayName);

#check to see if the username has been used, otherwise put it in the array of usernames that have been used

        #if it's been used, what to do? skip this iteration of the while loop

#I think it's actually better to check for existence of user in MT, though that is more expensive, it is almost much safer, and means that users can be created

        #in more than one batch

        #if(!in_array_str($username, @UsernamesUsed)) {

        if ( findAuthor($username) ) {

            #don't create this user

            next;

        }

        my $author = create_user( $username, $DisplayName );

#set status--most should be enabled, but a few should be disabled or pending -- enabled is 1, disabled is 2, what is pending? 3?

        my $author_status = 0;

        my $author_status_chances = random_number_times(10);

        if ( $author_status_chances == 1 ) {

            $author_status = 2;

        }
        elsif ( $author_status_chances == 2 ) {

            $author_status = 3;

        }
        else {

            $author_status = 1;

        }

        $author->status($author_status);

        $author->save

          or die $author->errstr;

 #if users are being created for blog, then assign them random role on that blog

        if ( !$blog_id ) {

            #get all blogs in system

            use MT::Blog;

            my @Blogs = MT::Blog->load();

  #assign the user a  on a blog or blogs--some should be sysadmins, but some not

        #for now, just assign them a role on one blog, unless they're a sysadmin

            my $author_sysadmin = random_number_times(10);

            if ( $author_sysadmin == 1 ) {

                $author->is_superuser(1);

            }
            elsif ( $author_sysadmin == 2 ) {

                $author->can_create_blog(1);

            }
            elsif ( $author_sysadmin == 3 ) {

                $author->can_view_log(1);

            }
            elsif ( $author_sysadmin == 4 ) {

                $author->can_manage_plugins(1);

            }
            elsif ( $author_sysadmin == 5 ) {

                $author->can_edit_templates(1);

            }
            else {

       #give them a random role on a random blog, but no system-level privileges

                #pick random blog

                my $blog = $Blogs[ rand( scalar @Blogs ) ];

                #pick random role

                if (MT->version_number < 4) {
                    my $perm = MT::Permission->new;
                    $perm->author_id( $author->id );
                    $perm->blog_id( $blog->id );
                    $perm->set_full_permissions();
                    $perm->save;
                } else {
                    my $role = $Roles[ rand( scalar @Roles ) ];

                    #create the association

                    require MT::Association;

    #define a User - Role - Blog relationship --user has to exist, though, for this to be done

                    MT::Association->link( $author => $role => $blog );
                }
            }

            #save the user again which is slightly inefficient

            $author->save

              or die $author->errstr;

        }
        else {

            #load up the blog object from blog id

            my $blog = MT::Blog->load($blog_id);

            #pick a random role

            if (MT->version_number < 4) {
                my $perm = MT::Permission->new;
                $perm->author_id( $author->id );
                $perm->blog_id( $blog->id );
                $perm->set_full_permissions();
                $perm->save;
            } else {
                my $role = $Roles[ rand( scalar @Roles ) ];

                #create the association for that blog with the random role

                MT::Association->link( $author => $role => $blog );
            }

        }

        #add one to count of users that were created

        $count++;

    }

}

sub create_user {

    my $username = shift;

    my $DisplayName = shift;

    #derive the email from username

    #this is another thing that could be user preference--what domain to use with email addresses

    my $email = $username . '@fozboot.com';

    #then actually create the user

    use MT::Author;

    my $author = MT::Author->new;

    $author->name($username);

    $author->nickname($DisplayName);

    $author->email($email);

    $author->set_password($g_DefaultPassword);

    $author->save

      or die $author->errstr;

    return $author;

}

sub createUsername {

    my $DisplayName = shift;

    #split the name in two

    my @name_elements = split( / /, $DisplayName );

    my $first_initial = lc( substr( $name_elements[ 0 ], 0, 1 ) );

    my $lc_last_name = lc( $name_elements[ 1 ] );

    my $username = $first_initial . $lc_last_name;

    return $username;

}

sub create_user_name {

    my $FirstName = getFirstName();

    my $LastName = getLastName();

    return "$FirstName $LastName";

}

sub getFirstName {

    #probably should allow people to define their own name pools

    my @first_name_pool = qw(

      Chris Brad Nick Mark David Michael Peter Jenny Sarah Lisa Tania Penelope Jim Homer Marge Bart Maggie Montgomery Nelson

      Milhouse Ned Todd Rod Ralph Lindsay Clancy Dale Jessica Helen Tim Matt Jacqueline Patty Selma Abe Kent Barry Charles Kevin

      Maude Parker Miranda Samantha Roxy Amy Steven Melody);

    my $FirstName = $first_name_pool[ rand( scalar @first_name_pool ) ];

    return $FirstName;

}

sub getLastName {

    my @last_name_pool = qw(

      Smith Davis Roberts Hall Nielson Young Lee Frampton Burns Simpson Flanders Wiggum Nagel Weir Garcia Cooper Gross Zachary

      Page Murphy Bouvier Brockman Bonds Hart Nelson);

    my $LastName = $last_name_pool[ rand( scalar @last_name_pool ) ];

    return $LastName;

}

sub findAuthor {

    my $username = shift;

    #try to load author with that nickname
    use MT::Author;
    my $author = MT::Author->load( { name => $username } );

    if ($author) {

        #return 1;
        return $author;

    }
    else {

        return 0;

    }

}

sub create_user_set_for_blog {

    my $blog_id = shift;
    my $numberUsers = shift;
    my $userType = shift;

    #load up the blog
    use MT::Blog;

    my $blog = MT::Blog->load($blog_id);

    #get all roles in the system

    my @Roles;
    if (MT->version_number >= 4) {
        require MT::Role;
        @Roles = MT::Role->load();
    }

    if ($numberUsers)
    {
        trim(\$numberUsers)
    }
    else
    {
        $numberUsers = @Roles;
    }
    if ($userType)
    {
        trim(\$userType)
    }

    # FIXME: create an alternative user set for MT 3.x

    # create $numberUsers, if undefined then a user for each role is created
    if($userType && $userType ne "") # i can't remember which
    {
        require MT::Role;
        my $role = MT::Role->load( { name => $userType } );
        if ($role)
        {
            for ( my $j = 0; $j < $numberUsers; $j++)
            {
                my $username = $g_UserPrefix . $j;
                #get random first name
                my $FirstName = getFirstName();

                my $author = findAuthor($username) ;
                if ( ! $author )
                {
                    $author = create_user( $username, "$FirstName $userType" );
                }
                #create association
                require MT::Association;
                MT::Association->link( $author => $role => $blog );
            }
        }
        else
        {
            #how do i raise an error here?
        }
    }
    else
    {
        foreach my $role (@Roles)
        {
            my $role_name = $role->name;
            my $username = lc($role_name);
            $username =~ s/ //;

            #get random first name
            my $FirstName = getFirstName();

            #create user
            my $author = create_user( $username, "$FirstName $role_name" );

            #create association
            require MT::Association;
            MT::Association->link( $author => $role => $blog );
        }
    }

} #end sub



sub add_categories_to_entries {
  my $blog_id = shift;

  #get all entries for that blog
  my @Entries = MT::Entry->load( { blog_id => $blog_id });

  #iterate through all entries for that blog and add category placements
  foreach my $entry (@Entries) {
    my $entry_id = $entry->id;

    print STDERR "Adding categories to entry $entry_id\n";

    add_categories_to_entry($blog_id, $entry_id);
  }
}

sub add_trackbacks_to_entries {
  my $blog_id = shift;

  #get all entries for that blog
  my @Entries = MT::Entry->load( { blog_id => $blog_id });

  #iterate through all entries for that blog and add pings
  foreach my $entry (@Entries) {
    my $entry_id = $entry->id;

    #add trackbacks to only one quarter of entries
    my $add_ping = random_number_times(4);

    if ($add_ping == 1) {
      print STDERR "Adding trackbacks to entry $entry_id\n";

      add_trackback_to_entry($entry_id);
    }
  }
}

sub add_trackback_to_entry {
  my $entry_id = shift;

  my $entry = MT::Entry->load($entry_id);

  my $tb = $entry->trackback;

  if (!$tb) {
    #set entry to allow pings
    $entry->allows_pings(1);

    $entry->save
      or die $entry->errstr;

    $tb = $entry->trackback;
  }

  my $ping = MT::TBPing->new;

  $ping->blog_id($tb->blog_id);
  $ping->tb_id($tb->id);

  $ping->title('O HAI');
  $ping->excerpt('This is from a TrackBack ping.');
  $ping->source_url('http://www.foo.com/bar');
  $ping->blog_name('FooBarBlog');
  $ping->visible(1);
  $ping->ip('');
  $ping->save
    or die $ping->errstr;

}

sub add_assets_to_blog {
  my $blog_id = shift;
  my $NumberAssets = shift;

  return if MT->version_number < 4;

  require MT::Asset::Image;

  for ( 1..$NumberAssets ) {

    my $asset = MT::Asset::Image->new;

    $asset->blog_id($blog_id);
    $asset->label('Fozboot!');
    $asset->url('http://fozboot.com/booter.jpg');
    $asset->description('This is a picture of the beloved Booter cat.');
    $asset->file_name('booter.jpg');

    $asset->save
      or die $asset->errstr;

  }
}

sub create_blogs {
    my $NumberBlogs = shift;
    my $AddUser = shift;

    my $role;

    if (MT->version_number >= 4 && $AddUser) {
      require MT::Role;
      $role = MT::Role->load( { name => 'Blog Administrator' });
    }

    #create the blogs
    if ($NumberBlogs) {
      for ( 1..$NumberBlogs ) {
        #generate random blog name - to do
        my $BlogName = random_blog_name();

        my $blog_id = create_blog ($BlogName, '', 'mt_blog', 1, 1);

        #create user to be administrator of that blog, if necessary
        if ($AddUser) {
          #create user
          my $username = createUsername($BlogName);

          my $author = create_user($username, $BlogName);

          #make them admin on that blog
          #$author = MT::Author->load($author_id);

          if (MT->version_number >= 4) {
            require MT::Role;

            #my $role = MT::Role->load(1);
            my $blog = MT::Blog->load($blog_id);

            require MT::Association;

            MT::Association->link( $author => $role => $blog );
          }
        }
      }
    }
}

sub create_custom_fields_for_blog {
    my $app = shift;

    my $blog_id = $app->{ query }->param('blog_id');

    add_custom_fields_to_blog($blog_id);
}

sub add_custom_fields_to_blog {
    my ($blog_id) = @_;

    eval { require CustomFields::Field };

    #for each object in the system, create all possible blog-level custom fields for that object--first, for entries

    #get all object types supported in blog context

    my $customfield_objs = MT->app->registry('customfield_objects');

    #get all custom field types

    my $customfield_types = MT->app->registry('customfield_types');

    foreach my $key ( keys %$customfield_objs ) {

        my $context = $customfield_objs->{ $key }->{ context };

        next if $context eq "system";

        $context = "blog" if $context eq "all";

        #create custom fields of all types for that object

        foreach my $type_key ( keys %$customfield_types ) {

            create_custom_field( $blog_id, $key, $type_key, $context );

        }

    }

}

sub create_custom_field {

    my $blog_id = shift;

    my $obj_type = shift;

    my $field_type = shift;

    my $context = shift;

    #$field_type =~ s/./ /;

    my $field_name =
      ucfirst($context) . ucfirst($obj_type) . ucfirst($field_type) . "Field";

    my $field = CustomFields::Field->new;

    $field->blog_id($blog_id);

    $field->name($field_name);

    $field->description("This field was created by MTBooter.");

    $field->obj_type($obj_type);

    $field->type($field_type);

    $field->required(0);

    $field->tag("booter");

    #if radio buttons or drop down, need to populate field options

    if ( ( $field_type eq "select" ) || ( $field_type eq "radio" ) ) {

        $field->options("booter, biddle, trizzle");

    }

    $field->save or die $field->errstr;

    # Dirify to tag name

    my $tag = MT::Util::dirify( $field->name );

    $field->tag($tag);

    $field->save or die $field->errstr;

}

sub make_fake_tinyurl {
    return join q{}, 'http://tinyurl.com/', map { tr/WXYZ[\\]^_`/0-9/; $_ } map { chr(87 + int rand 35) } (1..5);
}

sub add_cf_data_to_entry {

    my $blog_id = shift;

    my $entry_id = shift;

    my $entry;
    if (ref $entry_id) {
        $entry = $entry_id;
        $entry_id = $entry->id;
    }
    else {
        $entry = MT->model('entry')->load($entry_id);
    }

    #get all entry custom fields
    eval {
        require CustomFields::Field;
        require CustomFields::Util;
    };

    my %terms;

    $terms{ blog_id } = $blog_id;

    $terms{ obj_type } = "entry";

    my @Fields = CustomFields::Field->load( \%terms );

    #iterate through them and add data for all field types that can easily have data added to them programatically

    my $meta = CustomFields::Util::get_meta($entry);

    my $plugin   = MT::Plugin::MTBooter->instance;
    my $config   = $plugin->get_config_hash();
    my $seedtext = $config->{ SeedText };

    my $sentence_wabby = Acme::Wabby->new(
        min_len             => 3,
        max_len             => 10,
        punctuation         => [ ".", "?", "!", "..." ],
        case_sensitive      => 0,
        hash_file           => "./wabbyhash.dat",
        list_file           => "./wabbylist.dat",
        autosave_on_destroy => 0,
        max_attempts        => 1000
    );
    $sentence_wabby->add($seedtext);

    foreach my $Field (@Fields) {

        my $field_type = $Field->type;
        my $field_basename = $Field->basename;

        next if $meta->{$field_basename};

        # generate some random data and put in that CF for that entry
        # TODO: datetime and asset types
        my $data = $field_type eq 'text'     ? $sentence_wabby->spew
                 : $field_type eq 'url'      ? make_fake_tinyurl()
                 : $field_type eq 'textarea' ? $sentence_wabby->spew
                 : $field_type eq 'checkbox' ? (int(rand 1) ? 1 : 0)
                 :                             undef
                 ;
        if ($field_type eq 'radio' || $field_type eq 'select') {
            my @options = split /\s*,\s*/, $Field->options;
            $data = $options[int rand scalar @options];
        }

        $meta->{$field_basename} = $data
            if defined $data;

    }

    CustomFields::Util::save_meta($entry, $meta)
        or die "Could not save metadata for $entry?!";

}

1;
