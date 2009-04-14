# MTBooter - A plugin for Movable Type.
# Copyright (c) 2007 Six Apart.

package MT::Plugin::MTBooter;

use strict;
use base qw( MT::Plugin );

our $VERSION = '0.14.1';

my $dickens = "It was the best of times, it was the worst of times,
it was the age of wisdom, it was the age of foolishness,
it was the epoch of belief, it was the epoch of incredulity,
it was the season of Light, it was the season of Darkness,
it was the spring of hope, it was the winter of despair,
we had everything before us, we had nothing before us,
we were all going direct to Heaven, we were all going direct
the other way--in short, the period was so far like the present
period, that some of its noisiest authorities insisted on its
being received, for good or for evil, in the superlative degree
of comparison only.

There were a king with a large jaw and a queen with a plain face,
on the throne of England; there were a king with a large jaw and
a queen with a fair face, on the throne of France.  In both
countries it was clearer than crystal to the lords of the State
preserves of loaves and fishes, that things in general were
settled for ever.

It was the year of Our Lord one thousand seven hundred and
seventy-five.  Spiritual revelations were conceded to England at
that favoured period, as at this.  Mrs. Southcott had recently
attained her five-and-twentieth blessed birthday, of whom a
prophetic private in the Life Guards had heralded the sublime
appearance by announcing that arrangements were made for the
swallowing up of London and Westminster.  Even the Cock-lane
ghost had been laid only a round dozen of years, after rapping
out its messages, as the spirits of this very year last past
(supernaturally deficient in originality) rapped out theirs.
Mere messages in the earthly order of events had lately come to
the English Crown and People, from a congress of British subjects
in America:  which, strange to relate, have proved more important
to the human race than any communications yet received through
any of the chickens of the Cock-lane brood.

France, less favoured on the whole as to matters spiritual than
her sister of the shield and trident, rolled with exceeding
smoothness down hill, making paper money and spending it.
Under the guidance of her Christian pastors, she entertained
herself, besides, with such humane achievements as sentencing
a youth to have his hands cut off, his tongue torn out with
pincers, and his body burned alive, because he had not kneeled
down in the rain to do honour to a dirty procession of monks
which passed within his view, at a distance of some fifty or
sixty yards.  It is likely enough that, rooted in the woods of
France and Norway, there were growing trees, when that sufferer
was put to death, already marked by the Woodman, Fate, to come
down and be sawn into boards, to make a certain movable framework
with a sack and a knife in it, terrible in history.  It is likely
enough that in the rough outhouses of some tillers of the heavy
lands adjacent to Paris, there were sheltered from the weather
that very day, rude carts, bespattered with rustic mire, snuffed
about by pigs, and roosted in by poultry, which the Farmer, Death,
had already set apart to be his tumbrils of the Revolution.
But that Woodman and that Farmer, though they work unceasingly,
work silently, and no one heard them as they went about with
muffled tread:  the rather, forasmuch as to entertain any suspicion
that they were awake, was to be atheistical and traitorous.

In England, there was scarcely an amount of order and protection
to justify much national boasting.  Daring burglaries by armed
men, and highway robberies, took place in the capital itself
every night; families were publicly cautioned not to go out of
town without removing their furniture to upholsterers' warehouses
for security; the highwayman in the dark was a City tradesman in
the light, and, being recognised and challenged by his fellow-
tradesman whom he stopped in his character of the Captain,
gallantly shot him through the head and rode away; the mail was
waylaid by seven robbers, and the guard shot three dead, and then
got shot dead himself by the other four, in consequence of the
failure of his ammunition: after which the mail was robbed in
peace; that magnificent potentate, the Lord Mayor of London, was
made to stand and deliver on Turnham Green, by one highwayman,
who despoiled the illustrious creature in sight of all his
retinue; prisoners in London gaols fought battles with their
turnkeys, and the majesty of the law fired blunderbusses in among
them, loaded with rounds of shot and ball; thieves snipped off
diamond crosses from the necks of noble lords at Court
drawing-rooms; musketeers went into St. Giles's, to search for
contraband goods, and the mob fired on the musketeers, and the
musketeers fired on the mob, and nobody thought any of these
occurrences much out of the common way.  In the midst of them,
the hangman, ever busy and ever worse than useless, was in
constant requisition; now, stringing up long rows of miscellaneous
criminals; now, hanging a housebreaker on Saturday who had been
taken on Tuesday; now, burning people in the hand at Newgate by
the dozen, and now burning pamphlets at the door of Westminster Hall;
to-day, taking the life of an atrocious murderer, and to-morrow of a
wretched pilferer who had robbed a farmer's boy of sixpence.

All these things, and a thousand like them, came to pass in
and close upon the dear old year one thousand seven hundred
and seventy-five.  Environed by them, while the Woodman and the
Farmer worked unheeded, those two of the large jaws, and those
other two of the plain and the fair faces, trod with stir enough,
and carried their divine rights with a high hand.  Thus did the
year one thousand seven hundred and seventy-five conduct their
Greatnesses, and myriads of small creatures--the creatures of this
chronicle among the rest--along the roads that lay before them.

I see that child who lay upon her bosom and who bore my name, a man
winning his way up in that path of life which once was mine.  I see
him winning it so well, that my name is made illustrious there by the
light of his.  I see the blots I threw upon it, faded away.  I see
him, fore-most of just judges and honoured men, bringing a boy of my
name, with a forehead that I know and golden hair, to this place--
then fair to look upon, with not a trace of this day's disfigurement
--and I hear him tell the child my story, with a tender and a faltering
voice.

It is a far, far better thing that I do, than I have ever done;
it is a far, far better rest that I go to than I have ever known. Dotcom.";

my $plugin = MT::Plugin::MTBooter->new({
    key             => 'MTBooter',
    id              => 'MTBooter',
    name            => "MTBooter",
    version         => $VERSION,
    description     => "<MT_TRANS phrase=\"QA/debugging tool for Movable Type\">",
    author_name     => "Chris Ernest Hall",
    author_link     => "http://djchall.vox.com/",
    plugin_link     => "http://djchall.com/plugins/",
    doc_link        => "",
    system_config_template => ( MT->version_number < 4 ? 'booter_config_mt3.tmpl' : 'booter_config.tmpl' ),
    settings => new MT::PluginSettings([
            ['NumberYears', { Default => 5 }],
            ['NumberTags', { Default => 5 }],
            ['SeedText', { Default => $dickens }]
    ])
});

MT->add_plugin($plugin);

sub init_registry {
  my $plugin = shift;

  $plugin->registry({
    applications=> {
      cms => {
        menus => {
          'create:booter' => {
            label => 'Entries',
            dialog => 'show_dialog',
            order => 301,
            args => { _type => "show_dialog" },
            permission => 'administer_blog',
            view => "blog",
          },
          'create:booter3' => {
            label => 'Categories',
            dialog => 'menu_create_categories',
            order => 302,
            args => { _type => "menu_create_categories" },
            permission => 'administer_blog',
            view => "blog",
          },
          'create:booter2' => {
            label => 'Demo Site',
            dialog => 'create_demo',
            args => { _type => "create_demo" },
            order => 301,
            permission => 'administer',
            view => "system",
          },
          'create:booter5' => {
            label => 'Test Blog',
            dialog => 'menu_create_test_blog',
            args => { _type => "menu_create_test_blog" },
            order => 302,
            permission => 'administer',
            view => "system",
          },
          'create:booter9' => {
            label => 'Baseline Blog',
            dialog => 'menu_create_baseline_blog',
            args => { _type => "menu_create_baseline_blog" },
            order => 303,
            permission => 'administer',
            view => "system",
          },
          'create:booter4' => {
            label => 'Users',
            dialog => 'menu_create_users',
            order => 304,
            args => { _type => "menu_create_users" },
            permission => 'administer',
            view => "system",
          },
          'create:booter12' => {
            label => 'Blogs',
            dialog => 'show_blogs_dialog',
            order => 305,
            args => { _type => "show_blogs_dialog" },
            permission => 'administer',
            view => "system",
          },
          'create:booter6' => {
            label => 'User Set',
            dialog => 'menu_create_user_set',
            order => 306,
            args => { _type => "menu_create_user_set" },
            permission => 'administer',
            view => "blog",
          },
          'create:booter7' => {
            label => 'Add Categories',
            dialog => 'menu_add_categories',
            order => 307,
            args => { _type => "menu_add_categories" },
            permission => 'administer',
            view => "blog",
          },
          'create:booter8' => {
            label => 'Add Trackbacks',
            dialog => 'menu_add_trackbacks',
            order => 308,
            args => { _type => "menu_add_trackbacks" },
            permission => 'administer',
            view => "blog",
          },
          'create:booter10' => {
            label => 'Add Assets',
            dialog => 'menu_add_assets',
            order => 309,
            args => { _type => "menu_add_assets" },
            permission => 'administer',
            view => "blog",
          },
          'manage:booter11' => {
            label => 'Template Mappings',
            dialog => 'menu_manage_template_mappings',
            order => 10000,
            args => { _type => "menu_manage_template_mappings" },
            permission => 'administer',
            view => "blog",
          },
          'manage:booter14' => {
            label => 'Module Caches',
            dialog => 'menu_manage_module_caches',
            order => 11000,
            args => { _type => "menu_manage_module_caches" },
            permission => 'administer',
            view => "blog",
          },
          'create:booter15' => {
            label => 'Custom Field Set',
            dialog => 'menu_create_custom_fields',
            order => 310,
            args => { _type => "menu_create_custom_fields" },
            permission => 'administer',
            view => "blog",
          },
            'create:booter16' => {
            label => 'Create User Set',
            dialog => 'show_create_userset_dialog',
            order => 311,
            args => { _type => "show_create_userset_dialog" },
            permission => 'administer',
            view => "blog",
          },
        },
      },
    },
     methods => {
        show_dialog => '$MTBooter::MTBooter::App::CMS::show_dialog',
        menu_create_entries => '$MTBooter::MTBooter::App::CMS::menu_create_entries',
        create_demo => '$MTBooter::MTBooter::App::CMS::create_demo',
        menu_create_test_blog => '$MTBooter::MTBooter::App::CMS::menu_create_test_blog',
        menu_create_categories => '$MTBooter::MTBooter::App::CMS::menu_create_categories',
        menu_create_users => '$MTBooter::MTBooter::App::CMS::menu_create_users',
        show_blogs_dialog => '$MTBooter::MTBooter::App::CMS::show_blogs_dialog',
        menu_create_blogs => '$MTBooter::MTBooter::App::CMS::menu_create_blogs',
        menu_create_user_set => '$MTBooter::MTBooter::App::CMS::menu_create_user_set',
        menu_add_categories => '$MTBooter::MTBooter::App::CMS::menu_add_categories',
        menu_add_trackbacks => '$MTBooter::MTBooter::App::CMS::menu_add_trackbacks',
        menu_add_assets => '$MTBooter::MTBooter::App::CMS::menu_add_assets',
        menu_create_custom_fields => '$MTBooter::MTBooter::App::CMS::menu_create_custom_fields',
        menu_manage_template_mappings => '$MTBooter::MTBooter::App::CMS::menu_manage_template_mappings',
        menu_manage_module_caches => '$MTBooter::MTBooter::App::CMS::menu_manage_module_caches',
        menu_create_baseline_blog => '$MTBooter::MTBooter::App::CMS::menu_create_baseline_blog',
        show_create_userset_dialog => '$MTBooter::MTBooter::App::CMS::show_create_userset_dialog',
     },
  });

}

sub init_app {
    my $plugin = shift;
    $plugin->SUPER::init_app(@_);
    my ($app) = @_;

    return unless $app->isa('MT::App::CMS');
}

sub instance { $plugin }

1;
