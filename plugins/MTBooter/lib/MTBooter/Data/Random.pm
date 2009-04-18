
package MTBooter::Data::Random;

use strict;
use warnings;

use base qw( Exporter Class::ErrorHandler );
use vars qw( @EXPORT );

<<<<<<< HEAD:plugins/MTBooter/lib/MTBooter/Data/Random.pm
@EXPORT = qw(random_date get_random_tags random_rating random_user random_comment random_number_times 
=======
@EXPORT = qw(random_date get_random_tags random_rating random_user random_comment random_number_times
>>>>>>> c82a22ee38599b7675ad7348845c75ea7a21a10d:plugins/MTBooter/lib/MTBooter/Data/Random.pm
random_top_level_category random_category random_subcategory random_blog_name);

sub random_date {
    my $years = shift;

    my @date = localtime( time - int( rand( $years * 365 * 24 * 60 * 60 ) ) );
    return sprintf(
        "%04d%02d%02d%02d%02d%02d",
        $date[ 5 ] + 1900,
        $date[ 4 ] + 1,
        $date[ 3 ],
        $date[ 2 ],
        $date[ 1 ],
        $date[ 0 ]
    );
}

sub get_random_tags {
    my @tags;
    my $count     = shift;
    my @word_pool = qw(
      booter biddle trizzle alcina morgana bubba fozboot cat cats kitties persephone aggamemnon cute lolcat ICANHAZ laddering adminisdribble ebrandgelist t-patcher flying-k bogof docu-soap mattressing crunch if-by-whiskey fast-on skip bolt-ons banked sleepwork snatiation drunkalog olf chessically heel kino epiphany-risk game step-on horseracism baghouse skeet prop sit-ski pink drawling hundo freeskier outboarding run-off crop interiorscaping chicken-winging munitionette lysdexia gigachurch monster glass omega-block bumping money-good 00s-rock 1976 1981 1982-86 1986-87 1999-2000 2005 2006 2007 60srock 70s-rock 70srock 80s 80srock 9/11 90s-rock 98.5 abrasive addictive adolescence AdrianBelew air guitar album rock AlexLifeson alienation alt.country altalara alternative altrock americana andy annoying AOR artrock athensga authentic Awesome axl rose babies baby babymix bachelorparty beatles best biblical bigfive birth bobmould bootleg break-up breakup BritHipHop britpop bruce BtS canada canonical cars Carsten catchy cheezy chickrock classic classic rock classic-rock classicrock cold war college collegerock complex covers crappy crazy crazyhorse creepy crips crossover crunk currentevents dance dating DavidBryne dayton DBT desert-rock di dirgelike dirtysouth djchall dotcom driving drrty drrty-south drrtydrrty drums dumb e-40 early 80s early80s early90s eclectic electronic english epic featured femaleleadsinger first freshmanyear friday friendship funk funky funny GangofFour gangsta gayrock gbv GeddyLee getpsyched goth grand greatest grooving growing up grunge guitars guitarsolo gunners gypsy hairbands hairmetal handel hunt lieberso hard-rock hardrock hi high school highschool hip-hop hit single hype hyphie hyphy hypnotic indie infectious infidelity inspirational insprirational jagged jay farrar jefftweedy JimmyPage JoeMahoney jonanderson jose verde joseverde JoshHomme kick-ass kickass kome Kraftwerk kroq KYUSS late80s Lee literate live105 livedead livemusic lo-fi lofi longsongs lotr loud lovegonebad lush lyrics marathon mashups math-rock mathrock maynard mcool metal mid80s mid80srock MikeCooley mmj moses mournful NeilPeart new jersey newjersey newmusic nmh-esque no depression nodepression numetal NWoSR nyc oh canada ohcanada ohio OK oy pacificnorthwest paloalto partying PattersonHood petetownshend PhilCollins phood pop poppy post-punk powerstation progressive progrock prom punk punkrock pwn pwndy pwnt rap rapping regretful remix return to form rhcp rich RichardManuel RickDanko riotgrrl RobertPlant RobertPollard RobMalone robot pop ROCK rocking romantic sad science fiction screw seattle sexy shaolin short shredding sinuous skunky slammin slideguitar sludgerock snoop dogg so-cal soaring socal solo Somewhere Europe soundtrack southern southernrock spandex spooky stoner-metal stoney story-tellers stryliar suburbia sucky tennesee the doors theband This song... tolkien tool top25 transcendent trippy ucsc umlauts UncleTupelo under-rated unstoppable v-town vapor album vocals vu weird weirdpop whitefunk wild wistful work wutang yayarea yes ylt youth zep zeppelin-esque 2008 action streams advertising apperceptive application design battlestar-galactica bear stearns billing design layouts boomer codename comments community competition competitive competitors concept condenast custom fields design discussion djchall dynamic publishing engineering epic facebook FAIL fbz feed financial services flux friending google analytics hackathon hacks hp inchoate intranet jakob nielsen javascript layouts marketing miscellany mobile motion project movable type mt mt4.2 MTBooter mtbooter mtfogger mtos mtos4.11 mystery box nifty performance logging performance testing plugins postmortem presentations product product-design qa release retrospective sakk security social-networking statistics status update tag clouds tags tbwa templates testplan themes theproduct tp typepad typepad usability user interface weekly status weeklystatus wiki wordpress worklog xml yui
    );

    for ( my $i = 0 ; $i < $count ; $i++ ) {
        push @tags, $word_pool[ rand( scalar @word_pool ) ];
    }
    return @tags;
}

sub random_rating {
    my $RatingType = shift;

    my $RandomRating = 0;

    if ( $RatingType eq "binary" ) {
        my @ratings = qw(0 100);

        $RandomRating = $ratings[ rand( scalar @ratings ) ];
    }
    elsif ( $RatingType eq "trinary" ) {
        my @ratings = qw(0 50 100);

        $RandomRating = $ratings[ rand( scalar @ratings ) ];
    }
    elsif ( $RatingType eq "fivestar" ) {
        my @ratings = qw(0 20 40 60 80 100);

        $RandomRating = $ratings[ rand( scalar @ratings ) ];
    }
    elsif ( $RatingType eq "onetoten" ) {
        my @ratings = qw(0 10 20 30 40 50 60 70 80 90 100);

        $RandomRating = $ratings[ rand( scalar @ratings ) ];
    }
    else {
        $RandomRating = int (rand(100) + .5);
    }
    return $RandomRating;
}

sub random_user {
    require MT::Author;

    my @Authors = MT::Author->load();

    return $Authors[ rand( scalar @Authors ) ];
}

sub random_comment {
    require MT::Comment;
    my ($blog_id, $entry_id, $author_id, $author_display_name, $comment_parent_id) = @_;
<<<<<<< HEAD:plugins/MTBooter/lib/MTBooter/Data/Random.pm
	
    my @comment_texts = ();
    my $comment = MT::Comment->new;
	
=======

    my @comment_texts = ();
    my $comment = MT::Comment->new;

>>>>>>> c82a22ee38599b7675ad7348845c75ea7a21a10d:plugins/MTBooter/lib/MTBooter/Data/Random.pm
    $comment->blog_id($blog_id);
    $comment->entry_id($entry_id);

    #right now only creates comments by registered users, but should also create ones from anonymous users
    my $not_anon_comment = random_number_times(5);

    require Acme::Wabby;

    my $wabby = Acme::Wabby->new;

    #get seed text from settings
    my $plugin = MT::Plugin::MTBooter->instance;

    my $seedtext = $plugin->get_config_value ('SeedText', 'system');

    $wabby->add($seedtext);
    @comment_texts = ( $wabby->spew );
    my $comment_text = $comment_texts[ rand( scalar @comment_texts ) ];
<<<<<<< HEAD:plugins/MTBooter/lib/MTBooter/Data/Random.pm
	
=======

>>>>>>> c82a22ee38599b7675ad7348845c75ea7a21a10d:plugins/MTBooter/lib/MTBooter/Data/Random.pm
    if ( $not_anon_comment != 1 ) {
        $comment->commenter_id($author_id);
        $comment->author($author_display_name);
    }
    else {
        $comment->author("Anon Imus");
    }

    $comment->text($comment_text);
    my $comment_visible = random_number_times(1);
    $comment->visible($comment_visible);

    #since we don't do date-based display of comments, I think it's okay to have them all be at the same time (that also prevents comments from having created on dates that would be before the entry date, which would be weird

    #my $comment_created_on = random_date(1);

    #$comment->created_on($comment_created_on);

    if ((MT->version_number >= 4) && $comment_parent_id) {

        $comment->parent_id($comment_parent_id);

    }

    #then junk filter the comment

    require MT::JunkFilter;

    MT::JunkFilter->filter($comment);

    $comment->save

      or die $comment->errstr;

    my $comment_id = $comment->id;
<<<<<<< HEAD:plugins/MTBooter/lib/MTBooter/Data/Random.pm
	
=======

>>>>>>> c82a22ee38599b7675ad7348845c75ea7a21a10d:plugins/MTBooter/lib/MTBooter/Data/Random.pm
    my $comment_replies = random_number_times(1);

    #some comments should have replies--but only published ones

    if ( $comment_visible && $comment_replies ) {

        #get number of replies

        my $number_replies = random_number_times(5);

        for ( my $i = 0 ; $i < $number_replies ; $i++ ) {

            my $RandomUser = random_user();

            my $comment_reply_author_id = $RandomUser->id;

            my $author_display_name = $RandomUser->nickname;

            #create random comment

            random_comment( $blog_id, $entry_id, $comment_reply_author_id,
                $author_display_name, $comment_id);

        }

    }

}

sub random_number_times {

    my $number_times_max = shift;

    my $NumberTimes = rand($number_times_max);

    $NumberTimes = int( $NumberTimes + .5 );

    return $NumberTimes;

}

sub random_top_level_category {
    my ($blog_id) = @_;

    require MT::Category;

    my @Categories = MT::Category->top_level_categories($blog_id);

    return $Categories[ rand( scalar @Categories ) ];
}

sub random_category {
    #pick random category from all belonging to that blog

    my $blog_id = shift;

    use MT::Category;

    my @Categories = MT::Category->load( { blog_id => $blog_id } );

    return $Categories[ rand( scalar @Categories ) ];
}

sub random_subcategory {
    my $category_id = shift;

    if ( !$category_id ) {

        die("Doh--no category_id in random_category");

    }

    require MT::Category;

    my $Category = MT::Category->load($category_id);

    #get all sub-categories of that category

    my @SubCategories = $Category->children_categories();

    return $SubCategories[ rand( scalar @SubCategories ) ];
}

sub random_blog_name {
    require Acme::Wabby;

    my $wabby = Acme::Wabby->new(
            min_len             => 1,
            max_len             => 5,
            punctuation         => [''],
            case_sensitive      => 1,
            hash_file           => "./wabbyhash.dat",
            list_file           => "./wabbylist.dat",
            autosave_on_destroy => 0,
            max_attempts        => 1000
    );

    #get seed text from settings
    my $plugin = MT::Plugin::MTBooter->instance;

    my $seedtext = $plugin->get_config_value ('SeedText', 'system');

    $wabby->add($seedtext);
<<<<<<< HEAD:plugins/MTBooter/lib/MTBooter/Data/Random.pm
	
    my $blog_name = ( $wabby->spew );
	
	#$blog_name = ucfirst($blog_name);
	$blog_name = uc($blog_name);
    $blog_name=~ s/(\w+)/\u\L$1/g;
	
	$blog_name .= " Blog";
=======

    my $blog_name = ( $wabby->spew );

    #$blog_name = ucfirst($blog_name);
    $blog_name = uc($blog_name);
    $blog_name=~ s/(\w+)/\u\L$1/g;

    $blog_name .= " Blog";
>>>>>>> c82a22ee38599b7675ad7348845c75ea7a21a10d:plugins/MTBooter/lib/MTBooter/Data/Random.pm

    return $blog_name;
}

1;