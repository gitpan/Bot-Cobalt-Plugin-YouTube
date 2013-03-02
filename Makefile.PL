
use strict;
use warnings;

use 5.012001;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "YouTube plugin for Bot::Cobalt",
  "AUTHOR" => "Jon Portnoy <avenj\@cobaltirc.org>",
  "BUILD_REQUIRES" => {
    "Test::More" => "0.88"
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Bot-Cobalt-Plugin-YouTube",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Bot::Cobalt::Plugin::YouTube",
  "PREREQ_PM" => {
    "Bot::Cobalt" => 0,
    "Carp" => 0,
    "HTML::TokeParser" => "3.69",
    "HTTP::Request" => 0,
    "URI::Escape" => 0,
    "strictures" => 1
  },
  "VERSION" => "0.003000",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



