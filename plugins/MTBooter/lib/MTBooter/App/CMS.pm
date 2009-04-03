package MTBooter::App::CMS;

use strict;
use warnings;

use base qw( MT::App );

use MTBooter::Data;
use MT::Util qw( remove_html dirify encode_html );

#  eval { require CustomFields::Field }; if ($@) { print "It's not installed\n"; }

sub plugin {
    return MT->component('MTBooter');
}

sub show_dialog {

    my $app = shift;

    #init($app);

    my $tmpl = $app->load_tmpl('booter.tmpl');

    my $params;

    #set defaults if they aren't defined

    $params->{ 'NumberEntries' } = "10";
    $params->{ 'NumberPages' } = "0";
    $params->{ 'RateEntries' } = "1";
    $params->{ 'AddComments' } = "1";

    return $app->build_page( $tmpl, $params );

}

sub menu_create_entries {

    my $app = shift;

    my $plugin = MT::Plugin::MTBooter->instance;

    my $config = $plugin->get_config_hash();

    #get parameters from settings

    my $NumberYears = int( $config->{ NumberYears } );

    my $NumberTags = int( $config->{ NumberTags } );

    my $NumberEntries = $app->{ query }->param('NumberEntries');

    my $RateEntries = $app->{ query }->param('RateEntries');

    my $RatingType = $app->{ query }->param('RatingType');

    my $AddComments = $app->{ query }->param('AddComments');

    my $AddCategories = $app->{ query }->param('AddCategories');

    my $AddCFData = $app->{ query }->param('AddCFData');

    my $blog_id = $app->{ query }->param('blog_id');

    my $author_id = $app->{ query }->param('author_id');

    #create the entries

    if ($NumberEntries) {

        create_entries(
            $blog_id,       "Entry",      $NumberEntries,
            $NumberYears, $NumberTags,    $RateEntries, $RatingType,
            $AddComments, $AddCategories, $AddCFData
        );

    }

    my $tmpl = $plugin->load_tmpl('booter.tmpl');

    my $param;

    $param->{ 'success' } =
      $NumberEntries . " entries created successfully! Rock on!";

    $param->{ 'NumberEntries' } = $NumberEntries;

    $param->{ 'NumberYears' } = $NumberYears;

    $param->{ 'NumberTags' } = $NumberTags;

    #how to reload in modal dialog, though? hm, seems to work automatically

    return $app->build_page( $tmpl, $param );

}

#this is not finished yet, just barely begun

sub remove_entries {

    my @Entries = MT::Entry->load();

}

sub menu_create_categories {

    my $app = shift;

    my $plugin = MT::Plugin::MTBooter->instance;

    my $blog_id = $app->{ query }->param('blog_id');
	
    #actaully create the categories

    create_categories($blog_id);

    my $tmpl = $plugin->load_tmpl('booter_confirm.tmpl');

    my $param;

    $param->{ 'confirm_message' } =
      "Your categories have been created successfully.";

    $param->{ 'confirm_link' } = "Categories listing";

    $param->{ 'confirm_mode' } = "list_cat";

    return $app->build_page( $tmpl, $param );

}


sub menu_create_users {

    my $app = shift;

    my $plugin = MT::Plugin::MTBooter->instance;

    my $blog_id = $app->{ query }->param('blog_id');

    #actaully create the users--should allow user to say how many, which means displaying dialog - to do

    create_users(10);

    my $tmpl = $plugin->load_tmpl('booter_confirm.tmpl');

    my $param;

    $param->{ 'confirm_message' } =
      "Your users have been created successfully.";

    $param->{ 'confirm_link' } = "Users listing";

    $param->{ 'confirm_mode' } = "list_user";

    return $app->build_page( $tmpl, $param );

}

sub menu_create_test_blog {

    my $app = shift;

    my $plugin = MT::Plugin::MTBooter->instance;

    #create the blog

    my $blog_id = create_blog(
        $app,
        "Test Blog",
"This is a test blog pre-populated with users, categories, tags, entries and comments.",
        "mt_blog",
        0,
        0
    );

    #create some categories for the blog

    create_categories($blog_id);

    #create entries and comments for the blog

    create_entries( $app, $blog_id, "Entry", 10, 5, 10, 0, 0, 1, 1 );

    #create a set of users for that blog

    create_user_set_for_blog($blog_id);

    my $tmpl = $plugin->load_tmpl('booter_confirm.tmpl');

    my $param;

    $param->{ 'confirm_message' } =
      "Your test blog has been created successfully.";

    $param->{ 'confirm_link' } = "Blog dashboard";

    $param->{ 'confirm_mode' } = "dashboard";

    $param->{ 'blog_id' } = $blog_id;

    return $app->build_page( $tmpl, $param );

}

sub menu_create_user_set {

    my $app = shift;

    my $plugin = MT::Plugin::MTBooter->instance;

    my $blog_id = $app->{ query }->param('blog_id');

    create_user_set_for_blog($blog_id);

    my $tmpl = $plugin->load_tmpl('booter_confirm.tmpl');

    my $param;

    $param->{ 'confirm_message' } =
      "Your user set for this blog has been created.";

    $param->{ 'confirm_link' } = "Manage users";

    $param->{ 'confirm_mode' } = "list_member";

    $param->{ 'blog_id' } = $blog_id;

    return $app->build_page( $tmpl, $param );

}

sub menu_create_custom_fields {
    my $app = shift;
	
    my $plugin = MT::Plugin::MTBooter->instance;

    my $blog_id = $app->{ query }->param('blog_id');
	
	my $tmpl = $plugin->load_tmpl('booter_confirm.tmpl');

    my $param;
	
	eval { require CustomFields::Field }; 
	
	if ($@) { 
	  $param->{ 'confirm_message' } =
      "Custom Fields are not available in this version of Movable Type.";	 
      $param->{ 'confirm_link' } = "Dashboard"; 
	  $param->{ 'confirm_mode' } = "dashboard";	   
	} else {
      create_custom_fields_for_blog($app);
	  
	  $param->{ 'confirm_message' } =
      "Custom Fields for this blog have been created.";
      $param->{ 'confirm_link' } = "Custom Fields";
      $param->{ 'confirm_mode' } = "list_field";
	}
	
    $param->{ 'blog_id' } = $blog_id;	

    return $app->build_page( $tmpl, $param );
}


sub menu_manage_template_mappings {
    my $app = shift;

    my $plugin = MT::Plugin::MTBooter->instance;

    my $blog_id = $app->{ query }->param('blog_id');

    my $mapping_list = make_mapping_list($blog_id);

    my $tmpl = $plugin->load_tmpl('list_template_mappings.tmpl');

    my $param;

 #http://localhost/mt-test/MT-4.1-en/mt.cgi?__mode=list&_type=template&blog_id=1

    $param->{ 'status_message' } = "Here are your blog's template mappings.";
    $param->{ 'mapping_list' }   = $mapping_list;
    $param->{ 'confirm_link' }   = "Templates";
    $param->{ 'confirm_mode' }   = "list_template";
    $param->{ 'blog_id' }        = $blog_id;

    return $app->build_page( $tmpl, $param );
}

sub make_mapping_list {
    my $blog_id = shift;

    use MT::TemplateMap;

    my $html =
"<table width=\"400\" class=\"entry-listing-table compact\" cellpadding=\"10\" cellspacing=\"10\">";

    $html .= "<td><b>Archive Type</b></td>";
    $html .= "<td><b>File Template</b></td>";
    $html .= "<td><b>Preferred?</b></td>";
    $html .= "<td>&nbsp;</td>";

    my @TemplateMaps = MT::TemplateMap->load( { blog_id => $blog_id } );

    foreach my $TemplateMap (@TemplateMaps) {

        $html .= "<tr class=\"odd\">";

        my $archive_type  = $TemplateMap->archive_type;
        my $template_id   = $TemplateMap->template_id;
        my $file_template = $TemplateMap->file_template;
        my $is_preferred  = $TemplateMap->is_preferred;

        $file_template = "Default" if $file_template eq '';

        my $edit_link =
"<a href=\"mt.cgi?__mode=view&_type=template&id=$template_id&blog_id=$blog_id\" target=\"_top\">Edit</a>";

        ##$file_template = html_entities($file_template);

        #require CGI;
        #my $file_template_esc = CGI::html_entities( $file_template );

        $html .= "<td>$archive_type</td>";
        $html .= "<td>$file_template</td>";
        $html .= "<td>$is_preferred</td>";
        $html .= "<td>$edit_link</td>";

        $html .= "</tr>";

    }

    $html .= "</table>";

    return $html;
}

sub menu_create_baseline_blog {
    my $app = shift;

    my $plugin = MT::Plugin::MTBooter->instance;

    #create the blog
    my $blog_id = create_blog(
        $app,
        "Baseline Blog",
        "This is a blog with the baseline dataset for performance testing.",
        "mt_blog", 0, 0
    );

    #populate it with entries -- do 500 at a time, due to cgi time-out issues
    create_entries( $app, $blog_id, "Entry", 400, 0, 0, 0, 0, 0, 0 );

    #determine whether to redirect or not
    #if ($continue_redirect) {

    #reload the mt app
    #my $url = "";

    #return $app->redirect($url);

    #} else {

    my $tmpl = $plugin->load_tmpl('booter_.tmpl');

    my $param;

    $param->{ 'confirm_message' } =
"A blog with the baseline dataset has been created with 400 entries. Please add more entries as required. To be honest, this feature hasn't really been fully implemented yet.";
    $param->{ 'confirm_link' } = "Blog Listing";
    $param->{ 'confirm_mode' } = "list_blog";

    return $app->build_page( $tmpl, $param );

    #}
}

sub menu_add_categories {
    my $app = shift;

    my $plugin = MT::Plugin::MTBooter->instance;
	
    my $blog_id = $app->{ query }->param('blog_id');

    add_categories_to_entries($blog_id);

    my $tmpl = $plugin->load_tmpl('booter_confirm.tmpl');

    my $param;

    $param->{ 'confirm_message' } =
      "Categories have been added to this blog's entries.";

    $param->{ 'confirm_link' } = "Entries";

    $param->{ 'confirm_mode' } = "list_entries";

    $param->{ 'blog_id' } = $blog_id;

    return $app->build_page( $tmpl, $param );
}

sub menu_add_trackbacks {
    my $app = shift;

    my $plugin = MT::Plugin::MTBooter->instance;
	
    my $blog_id = $app->{ query }->param('blog_id');

    add_trackbacks_to_entries($blog_id);

    my $tmpl = $plugin->load_tmpl('booter_confirm.tmpl');

    my $param;

    $param->{ 'confirm_message' } =
      "Trackbacks have been added to this blog's entries.";

    $param->{ 'confirm_link' } = "Trackbacks";

    $param->{ 'confirm_mode' } = "list_pings";

    $param->{ 'blog_id' } = $blog_id;

    return $app->build_page( $tmpl, $param );
}

sub menu_add_assets {
    my $app = shift;

    my $plugin = MT::Plugin::MTBooter->instance;
	
    my $blog_id = $app->{ query }->param('blog_id');

    add_assets_to_blog($blog_id, 5);

    my $tmpl = $plugin->load_tmpl('booter_confirm.tmpl');

    my $param;

    $param->{ 'confirm_message' } =
      "Assets have been added to this blog.";

    $param->{ 'confirm_link' } = "Assets";

    $param->{ 'confirm_mode' } = "list_assets";

    $param->{ 'blog_id' } = $blog_id;

    return $app->build_page( $tmpl, $param );
}

sub show_blogs_dialog {
    my $app = shift;

    my $tmpl = $app->load_tmpl('booter_create_blogs.tmpl');

    my $params;

    #set defaults if they aren't defined
    $params->{ 'NumberBlogs' } = "5";
    $params->{ 'AddUser' } = "1";

    return $app->build_page( $tmpl, $params );
}

sub menu_create_blogs {
    my $app = shift;

    my $plugin = MT::Plugin::MTBooter->instance;

    my $config = $plugin->get_config_hash();

    #get parameters from settings
    my $NumberBlogs = $app->{ query }->param('NumberBlogs');
    my $AddUser = $app->{ query }->param('AddUser');
    my $author_id = $app->{ query }->param('author_id');
	
	create_blogs($NumberBlogs, $AddUser);

    my $tmpl = $plugin->load_tmpl('booter_create_blogs.tmpl');

    my $param;

    $param->{ 'success' } =
      $NumberBlogs . " blogs created successfully!";

    $param->{ 'NumberBlogs' } = $NumberBlogs;
	$param->{ 'AddUser' } = $AddUser;

    return $app->build_page( $tmpl, $param );
}

sub menu_manage_module_caches {
    my $app = shift;

    my $plugin = MT::Plugin::MTBooter->instance;

    my $blog_id = $app->{ query }->param('blog_id');
	
	my $cache_list;
	my $status_message;
	
	if (MT->version_number >= 4.15) {
      $cache_list = make_module_cache_list($blog_id);
	  $status_message = "Here are your blog's cached modules.";
	} else {
	  $cache_list = "";
	  $status_message = "This feature isn't relevant for versions of MT before 4.15.";
	}

    my $tmpl = $plugin->load_tmpl('list_module_caches.tmpl');

    my $param;

    $param->{ 'status_message' } = $status_message;
    $param->{ 'cache_list' }   = $cache_list;
    $param->{ 'confirm_link' }   = "Templates";
    $param->{ 'confirm_mode' }   = "list_template";
    $param->{ 'blog_id' }        = $blog_id;

    return $app->build_page( $tmpl, $param );
}

sub make_module_cache_list {
    my $blog_id = shift;
	
    use MT::Session;
	use MT::Template;

    my $html =
"<table width=\"600\" border=\"1\" bordercolor=\"red\" cellpadding=\"10\" cellspacing=\"10\">";

    $html .= "<tr>";

    $html .= "<th class=\"category\"><b>Module</b></th>";
	$html .= "<th><b>Start</b></th>";
	$html .= "<th><b>Expire</b></th>";
    $html .= "<th><b>Exp. Type</b></th>";
    $html .= "<th><b>Interval</b></th>";
	$html .= "<th><b>Event Type</b></th>";
	$html .= "<th><b>Use Cache</b></th>";
    $html .= "<th>&nbsp;</th>";
	
	$html .= "</tr>";

    my @CachedModules = MT::Session->load( { kind => 'CO' } );
	
    foreach my $CachedModule (@CachedModules) {

        $html .= "<tr class=\"odd\">";

        my $session_id  = $CachedModule->id;
		
		#determine the name of the module from the session id
		my @booter = split(/::/, $session_id);
		my $module_name = $booter[3];
		
		#retrieve the template record using the name
		my $template_module = MT::Template->load( { name => $module_name } );
		
		my $cache_session_start = $CachedModule->start;
		
		#use DateTime::Format::Epoch;
		#my $cache_session_start_dt = DateTime->from_epoch(epoch => $cache_session_start);
		my $cache_session_start_lt = scalar(localtime($cache_session_start));
		
		my $cache_expiration_interval = "";
		my $cache_expire_type = "";
		my $cache_expire_event = "";
		my $use_cache = "";
		my $template_id = 0;
		my $cache_expire_time = "";
		my $edit_link = "";
		
		if (defined($template_module)) {
		
		  $cache_expiration_interval = $template_module->meta('cache_expire_interval');	
		  $cache_expire_type = $template_module->meta('cache_expire_type');	
		  $cache_expire_event = $template_module->meta('cache_expire_event');
		  $use_cache = $template_module->meta('use_cache');
		
		  $template_id = $template_module->id;
	
		  if ($cache_expiration_interval) {
		    $cache_expire_time = $cache_session_start + $cache_expiration_interval;
		  
		    $cache_expire_time = scalar(localtime($cache_expire_time));
		  } else {
		    $cache_expire_time = "N/A";
		  }
		
		  $edit_link =
"<a href=\"mt.cgi?__mode=view&_type=template&id=$template_id&blog_id=$blog_id\" target=\"_top\">Edit</a>";

        } else {
		  $cache_expiration_interval = "N/A";
		}
		
        $html .= "<td bgcolor=\"#dddddd\">$module_name</td>";
		$html .= "<td bgcolor=\"#dddddd\">$cache_session_start_lt</td>";
		$html .= "<td bgcolor=\"#dddddd\">$cache_expire_time</td>";
		$html .= "<td bgcolor=\"#dddddd\">$cache_expire_type</td>";
        $html .= "<td bgcolor=\"#dddddd\">$cache_expiration_interval</td>";
		$html .= "<td bgcolor=\"#dddddd\">$cache_expire_event</td>";
		$html .= "<td bgcolor=\"#dddddd\">$use_cache</td>";
		$html .= "<td bgcolor=\"#dddddd\">$edit_link</td>";

        $html .= "</tr>";		
    }	
	
	$html .= "</table>";

    return $html;
}	

1;
