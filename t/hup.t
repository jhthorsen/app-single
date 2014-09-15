use strict;
use Test::More;
use Digest::MD5 'md5_hex';
use File::Spec;
use Time::HiRes 'ualarm';

plan skip_all => 'Cannot run without script/single' unless -x 'script/single';

my $info_file = File::Spec->catfile(File::Spec->tmpdir, 'single-too-cool-for-hup-test');
my $env;

{
  local @ARGV = ($0);
  local $ENV{SINGLE_INFO_FILE} = $info_file;
  $env = do 'script/single' or die "Could not compile: $@";
}

is_deeply(
  [ @$env{qw( SINGLE_HUP_SIGNAL SINGLE_ID SINGLE_INFO_FILE )} ],
  [ 'TERM', '1cb0509fffdbf8066dcc9d130bf36e19', $info_file ],
  'correct %ENV',
);

{
  my $restarted = 0;
  my $pid = make_child();

  local $ENV{SINGLE_HUP_SIGNAL} = 'QUIT';
  local $ENV{SINGLE_INFO_FILE} = $info_file;
  local $SIG{ALRM} = sub { diag "kill HUP $$"; kill 'HUP', $$; ualarm 100e3; };
  local *App::single::script::start = sub { ++$restarted == 3 ? 0 : make_child(); };

  open my $FH, '>', $info_file or die $!;
  ok -e $info_file, 'info_file exists';
  ualarm 100e3;
  is App::single::script::run($pid), 42, 'run()';
  is $restarted, 3, 'app got sig hup';
  ok !-e $info_file, 'info_file removed';
}

done_testing;

sub make_child {
  my $pid = fork // die $!;
  return $pid if $pid;
  $SIG{QUIT} = sub { exit 42 };
  sleep 2;
  exit 40;
}
